import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/student_model.dart';
import 'widgets/student_search_bar.dart';
import 'widgets/student_data_table.dart';
import 'widgets/add_student_dialog.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';
  String? _selectedClass;
  String? _selectedSection;

  void _showAddStudentDialog() async {
    final Student? newStudent = await showDialog<Student>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddStudentDialog(),
    );

    if (newStudent != null) {
      setState(() {
        dummyStudents.insert(0, newStudent); // Add to top of list
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${newStudent.fullName} enrolled successfully!')),
        );
      }
    }
  }

  void _showAddClassDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Class'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'e.g., Grade 11',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  dummyClasses.add(controller.text);
                  _selectedClass = controller.text;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSectionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Section'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'e.g., Section C',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  dummySections.add(controller.text);
                  _selectedSection = controller.text;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editStudent(Student student) async {
    final Student? updatedStudent = await showDialog<Student>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddStudentDialog(student: student),
    );

    if (updatedStudent != null) {
      setState(() {
        final index = dummyStudents.indexWhere((s) => s.id == student.id);
        if (index != -1) {
          dummyStudents[index] = updatedStudent;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${updatedStudent.fullName} updated successfully!')),
        );
      }
    }
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dummyStudents.removeWhere((s) => s.id == student.id);
              });
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${student.fullName} deleted!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student Directory', style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(
                    'Manage, search and filter your student information.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Enroll New Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Search & Filter Bar
          StudentSearchBar(
            classes: dummyClasses,
            sections: dummySections,
            selectedClass: _selectedClass,
            selectedSection: _selectedSection,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onClassChanged: (val) {
              setState(() {
                _selectedClass = val;
              });
            },
            onSectionChanged: (val) {
              setState(() {
                _selectedSection = val;
              });
            },
            onCreateClass: _showAddClassDialog,
            onCreateSection: _showAddSectionDialog,
          ),
          const SizedBox(height: 24),
          
          // Data Table
          StudentDataTable(
            searchQuery: _searchQuery,
            selectedClass: _selectedClass,
            selectedSection: _selectedSection,
            onEdit: _editStudent,
            onDelete: _deleteStudent,
          ),
        ],
      ),
    );
  }
}
