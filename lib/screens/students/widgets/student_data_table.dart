import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/student_model.dart';

class StudentDataTable extends StatelessWidget {
  final List<Student> students;
  final bool isLoading;
  final String searchQuery;
  final String? selectedClass;
  final String? selectedSection;
  final Function(Student)? onEdit;
  final Function(Student)? onDelete;

  const StudentDataTable({
    super.key, 
    required this.students,
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedClass,
    this.selectedSection,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    }

    final filteredStudents = students.where((student) {
      // Class filter
      if (selectedClass != null && student.grade != selectedClass) {
        return false;
      }
      
      // Section filter
      if (selectedSection != null && student.section != selectedSection) {
        return false;
      }

      // Search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!student.fullName.toLowerCase().contains(query) &&
            !student.rollNumber.toLowerCase().contains(query) &&
            !student.grade.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 1000,
              maxWidth: constraints.maxWidth > 1000 ? constraints.maxWidth : 1000,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.divider)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _buildHeaderCell('STUDENT INFO')),
                        Expanded(flex: 2, child: _buildHeaderCell('ROLL NUMBER')),
                        Expanded(flex: 2, child: _buildHeaderCell('CLASS / SECTION')),
                        Expanded(flex: 2, child: _buildHeaderCell('PARENT INFO')),
                        Expanded(flex: 2, child: _buildHeaderCell('CONTACT')),
                        Expanded(flex: 1, child: _buildHeaderCell('ACTIONS', alignRight: true)),
                      ],
                    ),
                  ),
                  
                  // Table Rows
                  if (filteredStudents.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(48),
                      child: const Center(
                        child: Text('Not available', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ),
                    )
                  else
                    ...filteredStudents.map((student) => _buildDataRow(student)),
                  
                  // Table Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${filteredStudents.length} of ${students.length} students',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeaderCell(String title, {bool alignRight = false}) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
    );
  }

  Widget _buildDataRow(Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Student Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(int.parse(student.avatarColor)),
                  radius: 18,
                  child: Text(
                    student.initials[0], // Assuming we just want the first letter like 'A'
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName, 
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        student.email, 
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Roll Number
          Expanded(
            flex: 2,
            child: Text(student.rollNumber, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ),
          // Class / Section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.grade, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(student.section, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          // Parent Info
          Expanded(
            flex: 2,
            child: Text(student.parentName, style: AppTextStyles.bodyMedium),
          ),
          // Contact
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.phone, 
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        student.parentEmail, 
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  onPressed: () => onEdit?.call(student),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textSecondary),
                  onPressed: () => onDelete?.call(student),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
