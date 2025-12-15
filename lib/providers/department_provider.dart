import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Department {
  engineering,
  law,
  health,
  language,
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
      case Department.engineering:
        return 'Science de l\'Ingénieur';
      case Department.law:
        return 'Droit';
      case Department.health:
        return 'Santé';
      case Department.language:
        return 'Langue';
    }
  }

  IconData getDepartmentIcon(Department dept) {
    switch (dept) {
      case Department.engineering:
        return Icons.laptop_mac;
      case Department.law:
        return Icons.gavel;
      case Department.health:
        return Icons.favorite;
      case Department.language:
        return Icons.translate;
    }
  }

  Color getDepartmentColor(Department dept) {
    switch (dept) {
      case Department.engineering:
        return const Color(0xFF0444F4); // Blue
      case Department.law:
        return const Color(0xFF8B0000); // Dark red/burgundy
      case Department.health:
        return const Color(0xFFDC143C); // Crimson red
      case Department.language:
        return const Color(0xFF10B981); // Green
    }
  }
}
