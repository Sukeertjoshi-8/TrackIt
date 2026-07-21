import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/date_provider.dart';
import '../utils/date_extensions.dart';
import 'task_card.dart';
import 'task_options_modal.dart';

class TimelineView extends ConsumerStatefulWidget {
  const TimelineView({super.key});

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {

  final List<Color> _accentColors = [
    Colors.orange,
    Colors.purple,
    Colors.green,
    Colors.pink,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    final currentSelectedDate = ref.watch(selectedDateProvider);
    final asyncTasks = ref.watch(taskProvider);
    
    return asyncTasks.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading tasks: $err')),
      data: (tasks) {
        // Filter tasks for the selected date
        final dailyTasks = tasks.where((task) {
          return task.category == TaskCategory.day 
              ? task.deadline.isSameDate(currentSelectedDate)
              : task.deadline.isSameDate(currentSelectedDate);
        }).toList();

        // Sort tasks by time
        dailyTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

        return Column(
          children: [
            _buildTopHeader(),
            _buildDateSelector(currentSelectedDate),
            Expanded(
              child: dailyTasks.isEmpty
                  ? const Center(child: Text("No tasks for this day.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: dailyTasks.length,
                      itemBuilder: (context, index) {
                        final task = dailyTasks[index];
                        final isLast = index == dailyTasks.length - 1;
                        final accentColor = _accentColors[index % _accentColors.length];

                        return IntrinsicHeight(
                          child: Container(
                            decoration: index == 1 // Highlight the second item for mockup accuracy
                                ? BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.withValues(alpha: 0.1),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  )
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Time Label
                                SizedBox(
                                  width: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      DateFormat('hh:mm a').format(task.deadline),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                // Timeline Node & Line
                                Column(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(top: 14),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(color: accentColor, width: 2),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          task.progress == 1.0 ? Icons.check : Icons.circle,
                                          size: 10,
                                          color: accentColor,
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: accentColor.withValues(alpha: 0.5),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Task Card
                                Expanded(
                                  child: GestureDetector(
                                    onLongPress: () => showTaskOptionsModal(context, ref, task),
                                    child: TaskCard(
                                      task: task,
                                      accentColor: accentColor,
                                      onProgressTapped: () {
                                        final newProgress = task.progress == 1.0 ? 0.0 : 1.0;
                                        ref.read(taskProvider.notifier).updateProgress(task.id, newProgress);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          Row(
            children: const [
              Icon(Icons.search, size: 24, color: Colors.black87),
              SizedBox(width: 16),
              Icon(Icons.tune, size: 24, color: Colors.black87),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(DateTime selectedDate) {
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Appointment date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              InkWell(
                onTap: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (newDate != null) {
                    ref.read(selectedDateProvider.notifier).updateDate(newDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purple.shade100),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM').format(selectedDate),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.purple.shade300,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.purple.shade300),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              return _buildDateItem(date, selectedDate);
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index + 7));
              return _buildDateItem(date, selectedDate, hideDayLabel: true);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(DateTime date, DateTime selectedDate, {bool hideDayLabel = false}) {
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    return GestureDetector(
      onTap: () {
        ref.read(selectedDateProvider.notifier).updateDate(date);
      },
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.pinkAccent.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            if (!hideDayLabel) ...[
              Text(
                DateFormat('EEE').format(date).substring(0, 3),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
