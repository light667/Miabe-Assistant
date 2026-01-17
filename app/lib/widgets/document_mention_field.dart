import 'package:flutter/material.dart';
import '../utils/resource_utils.dart';
import '../constants/app_theme.dart';

class DocumentMentionField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? helperText;
  final int? maxLines;
  final int? maxLength;
  final Function(String name, String url)? onMentionSelected;

  const DocumentMentionField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.helperText,
    this.maxLines,
    this.maxLength,
    this.onMentionSelected,
  });

  @override
  State<DocumentMentionField> createState() => _DocumentMentionFieldState();
}

class _DocumentMentionFieldState extends State<DocumentMentionField> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Map<String, dynamic> _resourceTree = {};
  List<Map<String, String>> _filteredSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _hideOverlay();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  Future<void> _loadResources() async {
    _resourceTree = await ResourceUtils.getResourceTree();
  }

  void _onTextChanged() {
    final mentionQuery = ResourceUtils.getMentionQuery(
      widget.controller.text,
      widget.controller.selection.baseOffset,
    );

    if (mentionQuery != null) {
      _processMentionQuery(mentionQuery);
    } else {
      _hideOverlay();
    }
  }

  void _processMentionQuery(MentionQuery query) {
    final suggestions = <Map<String, String>>[];
    final segments = query.segments;
    final currentFilter = query.currentQuery.toLowerCase();

    if (segments.isEmpty) {
      // Level 1: Suggest Filières
      for (var filiere in _resourceTree['filieres'] ?? []) {
        final name = filiere['name'] ?? '';
        if (name.toLowerCase().contains(currentFilter)) {
          suggestions.add({
            'type': 'filiere',
            'name': name,
            'displayName': name,
          });
        }
      }
    } else if (segments.length == 1) {
      // Level 2: Suggest Semestres for selected Filière
      final filiereName = segments[0];
      final filiere = (_resourceTree['filieres'] as List?)?.firstWhere(
        (f) => f['name'] == filiereName,
        orElse: () => null,
      );

      if (filiere != null) {
        for (var semestre in filiere['semestres'] ?? []) {
          final name = semestre['name'] ?? '';
          if (name.toLowerCase().contains(currentFilter)) {
            suggestions.add({
              'type': 'semestre',
              'name': name,
              'displayName': name,
            });
          }
        }
      }
    } else if (segments.length >= 2) {
      // Level 3: Suggest PDFs for selected Filière and Semestre
      final filiereName = segments[0];
      final semestreName = segments[1];

      final filiere = (_resourceTree['filieres'] as List?)?.firstWhere(
        (f) => f['name'] == filiereName,
        orElse: () => null,
      );

      if (filiere != null) {
        final semestre = (filiere['semestres'] as List?)?.firstWhere(
          (s) => s['name'] == semestreName,
          orElse: () => null,
        );

        if (semestre != null) {
          for (var matiere in semestre['matieres'] ?? []) {
            final matiereName = matiere['name'] ?? '';
            for (var pdf in matiere['pdfs'] ?? []) {
              final pdfName = pdf['name'] ?? '';
              if (pdfName.toLowerCase().contains(currentFilter)) {
                suggestions.add({
                  'type': 'pdf',
                  'name': pdfName,
                  'displayName': pdfName,
                  'url': pdf['url'] ?? '',
                  'matiere': matiereName,
                });
              }
            }
          }
        }
      }
    }

    setState(() {
      _filteredSuggestions = suggestions.take(10).toList();
      _showSuggestions = _filteredSuggestions.isNotEmpty;
    });

    if (_showSuggestions) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showSuggestions = false;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final res = _filteredSuggestions[index];
                  final isFile = res['type'] == 'pdf';
                  
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isFile ? Icons.picture_as_pdf : Icons.folder_open,
                      color: isFile ? Colors.red : Colors.blue,
                      size: 20,
                    ),
                    title: Text(
                      res['displayName']!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: !isFile ? null : Text(
                      res['matiere'] ?? '',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => _selectMention(res),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectMention(Map<String, String> suggestion) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final textBeforeCursor = text.substring(0, selection.baseOffset);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');
    
    String insertText;
    bool isFinal = suggestion['type'] == 'pdf';

    if (isFinal) {
      insertText = '[@${suggestion['name']}](${suggestion['url']}) ';
    } else {
      // Si c'est une filière ou un semestre, on construit le chemin partiel
      if (suggestion['type'] == 'filiere') {
        insertText = '@${suggestion['name']}/';
      } else { // semestre
        final mentionQuery = ResourceUtils.getMentionQuery(text, selection.baseOffset);
        final currentSegments = mentionQuery?.segments ?? [];
        insertText = '@${currentSegments[0]}/${suggestion['name']}/';
      }
    }

    final newText = text.replaceRange(
      lastAtIndex,
      selection.baseOffset,
      insertText,
    );

    widget.controller.text = newText;
    final newOffset = lastAtIndex + insertText.length;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newOffset),
    );

    if (isFinal) {
      _hideOverlay();
      if (widget.onMentionSelected != null) {
        widget.onMentionSelected!(suggestion['name']!, suggestion['url']!);
      }
    } else {
      // Rester ouvert pour le niveau suivant
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
        child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
      ),
    );
  }
}
