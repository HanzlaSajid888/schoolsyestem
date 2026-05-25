import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

class StudentSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final List<String> classes;
  final List<String> sections;
  final String? selectedClass;
  final String? selectedSection;
  final ValueChanged<String?>? onClassChanged;
  final ValueChanged<String?>? onSectionChanged;
  final VoidCallback? onCreateClass;
  final VoidCallback? onCreateSection;
  final VoidCallback? onManageSections;

  const StudentSearchBar({
    super.key, 
    this.onSearchChanged,
    required this.classes,
    required this.sections,
    this.selectedClass,
    this.selectedSection,
    this.onClassChanged,
    this.onSectionChanged,
    this.onCreateClass,
    this.onCreateSection,
    this.onManageSections,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: constraints.maxWidth > 800 ? 400 : constraints.maxWidth,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, roll number, or class...',
                hintStyle: AppTextStyles.bodyMedium,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              ),
            ),
            _buildDropdown(
          hint: 'All Classes',
          value: selectedClass,
          items: classes,
          onChanged: onClassChanged,
          onCreateNew: onCreateClass,
        ),
        _buildDropdown(
          hint: 'All Sections',
          value: selectedSection,
          items: sections,
          onChanged: onSectionChanged,
          onCreateNew: onCreateSection,
          onManageItems: onManageSections,
        ),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ),
      ],
    );
      }
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    required VoidCallback? onCreateNew,
    VoidCallback? onManageItems,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(hint),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            )),
            const DropdownMenuItem<String>(
              value: '_CREATE_NEW_',
              child: Text('➕ Create New...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            if (onManageItems != null)
              const DropdownMenuItem<String>(
                value: '_MANAGE_ITEMS_',
                child: Text('➖ Remove Section...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
          ],
          onChanged: (val) {
            if (val == '_CREATE_NEW_') {
              onCreateNew?.call();
            } else if (val == '_MANAGE_ITEMS_') {
              onManageItems?.call();
            } else {
              onChanged?.call(val);
            }
          },
        ),
      ),
    );
  }
}
