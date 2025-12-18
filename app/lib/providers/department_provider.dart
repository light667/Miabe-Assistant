import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Department {
  lettresLangueArts,          // Lettres, Langue et Arts
  sciencesAgronomiques,        // Sciences Agronomiques
  sciencesEducationFormation,  // Sciences de l'Education et de la Formation
  sciencesEconomiqueGestion,   // Sciences Economiques et de Gestion
  sciencesHommeSociete,        // Sciences de l'Homme et de la Société
  sciencesJuridiquePolitique,  // Sciences Juridiques, Politiques et de l'Administration
  sciencesSante,               // Sciences de la Santé
  sciencesTechnologie,         // Sciences et Technologie
}

class DepartmentProvider extends ChangeNotifier {
  Department? _selectedDepartment;
  bool _isFirstLaunch = true;

  Department? get selectedDepartment => _selectedDepartment;
  bool get isFirstLaunch => _isFirstLaunch;

  DepartmentProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    
    final departmentIndex = prefs.getInt('selectedDepartment');
    if (departmentIndex != null) {
      _selectedDepartment = Department.values[departmentIndex];
    }
    
    notifyListeners();
  }

  Future<void> setDepartment(Department department) async {
    _selectedDepartment = department;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedDepartment', department.index);
    notifyListeners();
  }

  Future<void> markOnboardingComplete() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    notifyListeners();
  }

  Future<void> clearDepartment() async {
    _selectedDepartment = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedDepartment');
    notifyListeners();
  }

  String getDepartmentName(Department dept) {
    switch (dept) {
      case Department.lettresLangueArts:
        return 'Lettres, Langue et Arts';
      case Department.sciencesAgronomiques:
        return 'Sciences Agronomiques';
      case Department.sciencesEducationFormation:
        return 'Sciences de l\'Education et de la Formation';
      case Department.sciencesEconomiqueGestion:
        return 'Sciences Economiques et de Gestion';
      case Department.sciencesHommeSociete:
        return 'Sciences de l\'Homme et de la Société';
      case Department.sciencesJuridiquePolitique:
        return 'Sciences Juridiques, Politiques et de l\'Administration';
      case Department.sciencesSante:
        return 'Sciences de la Santé';
      case Department.sciencesTechnologie:
        return 'Sciences et Technologie';
    }
  }

  IconData getDepartmentIcon(Department dept) {
    switch (dept) {
      case Department.lettresLangueArts:
        return Icons.auto_stories; // Livre/Histoire
      case Department.sciencesAgronomiques:
        return Icons.agriculture; // Agriculture
      case Department.sciencesEducationFormation:
        return Icons.school; // Education
      case Department.sciencesEconomiqueGestion:
        return Icons.business_center; // Affaires/Economie
      case Department.sciencesHommeSociete:
        return Icons.people; // Sociologie
      case Department.sciencesJuridiquePolitique:
        return Icons.gavel; // Justice/Droit
      case Department.sciencesSante:
        return Icons.medical_services; // Santé
      case Department.sciencesTechnologie:
        return Icons.computer; // Technologie
    }
  }

  Color getDepartmentColor(Department dept) {
    switch (dept) {
      case Department.lettresLangueArts:
        return const Color(0xFFE91E63); // Rose/Magenta
      case Department.sciencesAgronomiques:
        return const Color(0xFF4CAF50); // Vert nature
      case Department.sciencesEducationFormation:
        return const Color(0xFF9C27B0); // Violet/Pourpre
      case Department.sciencesEconomiqueGestion:
        return const Color(0xFFFF9800); // Orange
      case Department.sciencesHommeSociete:
        return const Color(0xFF00BCD4); // Cyan
      case Department.sciencesJuridiquePolitique:
        return const Color(0xFF8B0000); // Rouge foncé
      case Department.sciencesSante:
        return const Color(0xFFDC143C); // Crimson rouge
      case Department.sciencesTechnologie:
        return const Color(0xFF0444F4); // Bleu technologie
    }
  }
}
