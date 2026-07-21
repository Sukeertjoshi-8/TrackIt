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
  late bool _requiresProof;
  String _currentTag = '';

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
      _requiresProof = task.requiresProof;
      _currentTag = task.tag;
    } else {
      _selectedCategory = widget.initialCategory;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _requiresProof = false;
      _currentTag = '';
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final deadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final finalTag = _currentTag.trim().isEmpty ? 'Uncategorized' : _currentTag.trim();

    if (widget.existingTask != null) {
      final updatedTask = widget.existingTask!.copyWith(
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        deadline: deadline,
        requiresProof: _requiresProof,
        tag: finalTag,
      );
      ref.read(taskProvider.notifier).updateTask(updatedTask);
    } else {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        progress: 0.0,
        deadline: deadline,
        requiresProof: _requiresProof,
        tag: finalTag,
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
                      // Avoid adding multiple listeners if fieldViewBuilder is rebuilt
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
              SwitchListTile(
                title: const Text('Requires Image Proof'),
                value: _requiresProof,
                onChanged: (val) {
                  setState(() {
                    _requiresProof = val;
                  });
                },
                contentPadding: EdgeInsets.zero,
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

