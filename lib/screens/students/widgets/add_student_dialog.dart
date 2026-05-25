import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/student_model.dart';

class AddStudentDialog extends StatefulWidget {
  final Student? student;

  const AddStudentDialog({super.key, this.student});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _rollNumberController;
  late final TextEditingController _gradeController;
  late final TextEditingController _sectionController;
  late final TextEditingController _parentNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _parentEmailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.student?.lastName ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _rollNumberController = TextEditingController(text: widget.student?.rollNumber ?? '');
    _gradeController = TextEditingController(text: widget.student?.grade ?? '');
    _sectionController = TextEditingController(text: widget.student?.section ?? '');
    _parentNameController = TextEditingController(text: widget.student?.parentName ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _parentEmailController = TextEditingController(text: widget.student?.parentEmail ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _rollNumberController.dispose();
    _gradeController.dispose();
    _sectionController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  void _saveStudent() {
    final newStudent = Student(
      id: widget.student?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      rollNumber: _rollNumberController.text.trim(),
      grade: _gradeController.text.trim(),
      section: _sectionController.text.trim(),
      parentName: _parentNameController.text.trim(),
      phone: _phoneController.text.trim(),
      parentEmail: _parentEmailController.text.trim(),
      avatarColor: widget.student?.avatarColor ?? '0xFFE0F7FA',
    );
    Navigator.of(context).pop(newStudent);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enroll New Student', style: AppTextStyles.h2),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField('First Name', _firstNameController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Last Name', _lastNameController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Email', _emailController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Roll Number', _rollNumberController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Grade/Class', _gradeController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Section', _sectionController)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Parent / Guardian Information', style: AppTextStyles.h3),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('Parent Name', _parentNameController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('Phone Number', _phoneController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Parent Email', _parentEmailController),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Student'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: 'Enter $label',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
