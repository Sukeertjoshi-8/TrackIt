import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/tag_provider.dart';

class AddTaskModal extends ConsumerStatefulWidget {
  final TaskCategory initialCategory;
  final Task? existingTask;
  
  const AddTaskModal({
    super.key, 
    this.initialCategory = TaskCategory.day,
    this.existingTask,
  });

  @override
  ConsumerState<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends ConsumerState<AddTaskModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late TaskCategory _selectedCategory;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
  List<int> selectedDays = [];
  String _currentTag = '';
  
  int durationYears = 0;
  int durationMonths = 0;
  int durationDays = 0;
  DateTime? exactDeadline;
  bool requiresPhotoProof = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      _titleController.text = task.title;
      _descController.text = task.description;
      _selectedCategory = task.category;
      _selectedDate = task.deadline;
      _selectedTime = TimeOfDay.fromDateTime(task.deadline);
      requiresPhotoProof = task.requiresPhotoProof;
      _currentTag = task.tag;
      if (task.frequencyDays != null && task.frequencyDays!.isNotEmpty) {
        selectedDays = task.frequencyDays!.split(',').map(int.parse).toList();
      } else {
        selectedDays = [];
      }
      
      if (task.isParent) {
        _updateDurationFromDeadline(task.deadline);
      } else {
        _updateDeadlineFromDuration();
      }
    } else {
      _selectedCategory = widget.initialCategory;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      requiresPhotoProof = false;
      _currentTag = '';
      selectedDays = [];
      _updateDeadlineFromDuration();
    }
  }

  void _updateDeadlineFromDuration() {
    final now = DateTime.now();
    setState(() {
      exactDeadline = DateTime(
        now.year + durationYears,
        now.month + durationMonths,
        now.day + durationDays,
        23,
        59,
      );
    });
  }

  void _updateDurationFromDeadline(DateTime pickedDate) {
    final now = DateTime.now();
    int years = pickedDate.year - now.year;
    int months = pickedDate.month - now.month;
    int days = pickedDate.day - now.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(pickedDate.year, pickedDate.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;

    setState(() {
      durationYears = years;
      durationMonths = months;
      durationDays = days;
      exactDeadline = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 23, 59);
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  void _submit() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    DateTime finalDeadline;
    if (_selectedCategory == TaskCategory.day) {
      finalDeadline = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    } else {
      finalDeadline = exactDeadline ?? DateTime.now();
    }

    final finalTag = _currentTag.trim().isEmpty ? 'Uncategorized' : _currentTag.trim();
    final isParent = (_selectedCategory == TaskCategory.month || _selectedCategory == TaskCategory.year);
    final freqDays = selectedDays.isNotEmpty ? selectedDays.join(',') : null;

    if (widget.existingTask != null) {
      final updatedTask = widget.existingTask!.copyWith(
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        deadline: finalDeadline,
        requiresPhotoProof: requiresPhotoProof,
        tag: finalTag,
        isParent: isParent,
        frequencyDays: freqDays,
      );
      ref.read(taskProvider.notifier).updateTask(updatedTask);
    } else {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        progress: 0.0,
        deadline: finalDeadline,
        requiresPhotoProof: requiresPhotoProof,
        tag: finalTag,
        isParent: isParent,
        frequencyDays: freqDays,
      );
      ref.read(taskProvider.notifier).addTask(newTask);
    }
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Location / Context',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final tags = ref.watch(tagProvider);
                  return Autocomplete<String>(
                    initialValue: TextEditingValue(text: _currentTag),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return tags;
                      }
                      return tags.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _currentTag = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      textEditingController.removeListener(() {}); 
                      textEditingController.addListener(() {
                        _currentTag = textEditingController.text;
                      });
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Tag (e.g. Coding, Errands)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<TaskCategory>(
                segments: const [
                  ButtonSegment(value: TaskCategory.day, label: Text('Day')),
                  ButtonSegment(value: TaskCategory.month, label: Text('Month')),
                  ButtonSegment(value: TaskCategory.year, label: Text('Year')),
                ],
                selected: {_selectedCategory},
                onSelectionChanged: (Set<TaskCategory> newSelection) {
                  setState(() {
                    _selectedCategory = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              if (_selectedCategory == TaskCategory.month || _selectedCategory == TaskCategory.year) ...[
                const Text('Select Habit Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: [
                    for (int i = 1; i <= 7; i++)
                      FilterChip(
                        label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i - 1]),
                        selected: selectedDays.contains(i),
                        onSelected: (_) => _toggleDay(i),
                        selectedColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF9C27B0),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCategory == TaskCategory.year) ...[
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: durationYears,
                          decoration: InputDecoration(
                            labelText: 'Years',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            for (int i = 0; i <= 10; i++)
                              DropdownMenuItem(value: i, child: Text('$i'))
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                durationYears = val;
                                _updateDeadlineFromDuration();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: durationMonths,
                        decoration: InputDecoration(
                          labelText: 'Months',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          for (int i = 0; i <= 11; i++)
                            DropdownMenuItem(value: i, child: Text('$i'))
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              durationMonths = val;
                              _updateDeadlineFromDuration();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: durationDays,
                        decoration: InputDecoration(
                          labelText: 'Days',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          for (int i = 0; i <= 31; i++)
                            DropdownMenuItem(value: i, child: Text('$i'))
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              durationDays = val;
                              _updateDeadlineFromDuration();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: Color(0xFF9C27B0)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: exactDeadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                        );
                        if (picked != null) {
                          _updateDurationFromDeadline(picked);
                        }
                      },
                    ),
                  ],
                ),
                if (exactDeadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Calculated Deadline: ${DateFormat('MMM dd, yyyy').format(exactDeadline!)}',
                      style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              
              if (_selectedCategory == TaskCategory.day) ...[
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Deadline Date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              _selectedTime = time;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              SwitchListTile(
                title: const Text('Require Photo Proof'),
                subtitle: const Text('Must take a picture to complete task'),
                value: requiresPhotoProof,
                onChanged: (val) {
                  setState(() {
                    requiresPhotoProof = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeTrackColor: const Color(0xFF9C27B0).withValues(alpha: 0.5),
                activeThumbColor: const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Task', 
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
