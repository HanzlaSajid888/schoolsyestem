import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/api/dashboard_api.dart';

class AcademicCalendar extends StatefulWidget {
  const AcademicCalendar({super.key});

  @override
  State<AcademicCalendar> createState() => _AcademicCalendarState();
}

class _AcademicCalendarState extends State<AcademicCalendar> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await DashboardApi.getEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching events: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showManageEventsDialog() {
    showDialog(
      context: context,
      builder: (context) => ManageEventsDialog(
        events: _events,
        onEventsChanged: _fetchEvents,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Academic Calendar',
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                tooltip: 'Manage Events',
                onPressed: _showManageEventsDialog,
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Upcoming events for the current month.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
          else if (_events.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No upcoming events.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _events.length > 3 ? 3 : _events.length, // Show max 3 on dashboard
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final event = _events[index];
                  final date = DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();
                  final month = DateFormat('MMM').format(date).toUpperCase();
                  final day = DateFormat('dd').format(date);
                  return _buildEventItem(month, day, event['title'] ?? '', event['type'] ?? '');
                },
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showManageEventsDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Manage Events'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String month, String day, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                month,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                day,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ManageEventsDialog extends StatefulWidget {
  final List<dynamic> events;
  final VoidCallback onEventsChanged;

  const ManageEventsDialog({super.key, required this.events, required this.onEventsChanged});

  @override
  State<ManageEventsDialog> createState() => _ManageEventsDialogState();
}

class _ManageEventsDialogState extends State<ManageEventsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Event';
  bool _isSaving = false;

  Future<void> _addEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await DashboardApi.addEvent({
        'title': _titleController.text,
        'type': _selectedType,
        'date': _selectedDate.toIso8601String(),
      });
      _titleController.clear();
      widget.onEventsChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteEvent(String id) async {
    try {
      await DashboardApi.deleteEvent(id);
      widget.onEventsChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Events'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Event Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Event Title'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(labelText: 'Type'),
                          items: ['Exam', 'Event', 'Meeting', 'Holiday', 'Other']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _addEvent,
                      child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : const Text('Add Event'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            // List of existing events
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Existing Events:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: widget.events.isEmpty
                  ? const Padding(padding: EdgeInsets.all(16), child: Text('No events found.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.events.length,
                      itemBuilder: (context, index) {
                        final ev = widget.events[index];
                        final date = DateTime.tryParse(ev['date'] ?? '') ?? DateTime.now();
                        return ListTile(
                          title: Text(ev['title'] ?? ''),
                          subtitle: Text('${ev['type']} - ${DateFormat('MMM dd, yyyy').format(date)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteEvent(ev['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
