import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_filter_provider.dart';
import '../providers/task_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final filterNotifier = ref.read(taskFilterProvider.notifier);
    final asyncTasks = ref.watch(taskProvider);

    // Extract all unique tags
    final Set<String> availableTags = {'Uncategorized'};
    if (asyncTasks.value != null) {
      for (final task in asyncTasks.value!) {
        availableTags.add(task.tag);
      }
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  filterNotifier.clearFilters();
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Hide Completed Tasks'),
            value: filter.hideCompleted,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              filterNotifier.toggleHideCompleted(value);
            },
            activeThumbColor: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tags',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: availableTags.map((tag) {
              final isSelected = filter.selectedTag == tag;
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                selectedColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                onSelected: (selected) {
                  if (selected) {
                    filterNotifier.setTag(tag);
                  } else {
                    filterNotifier.setTag(null);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

void showTaskFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const FilterBottomSheet(),
  );
}
