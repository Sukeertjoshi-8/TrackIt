import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime newDate) {
    state = newDate;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(() {
  return SelectedDateNotifier();
});
