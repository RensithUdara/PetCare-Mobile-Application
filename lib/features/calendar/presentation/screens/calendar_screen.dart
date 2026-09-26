import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../home/presentation/widgets/alerts_bell.dart';
import '../../../pets/presentation/providers/pet_providers.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_snapshot.dart';
import '../providers/calendar_providers.dart';
import '../widgets/calendar_event_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay = dateOnly(ref.read(clockProvider)());
  late DateTime _selectedDay = _focusedDay;
  CalendarFormat _format = CalendarFormat.month;

  void _open(CalendarEvent e) => context.push(eventDetailsRoute(e, fromHome: false));

  @override
  Widget build(BuildContext context) {
    final calendar = ref.watch(filteredCalendarProvider);
    final snapshot = calendar.value ?? CalendarSnapshot.empty;
    final pets = ref.watch(petsProvider).value ?? const [];
    final petFilter = ref.watch(calendarPetFilterProvider);
    final dayEvents = snapshot.eventsOn(_selectedDay);
    final theme = Theme.of(context);
    final today = dateOnly(ref.watch(clockProvider)());

    return Scaffold(
      appBar: BrandAppBar(
        title: 'Calendar',
        actions: [
          if (!isSameDay(_focusedDay, today) || !isSameDay(_selectedDay, today))
            BrandActionButton(
              icon: Icons.today_rounded,
              tooltip: 'Today',
              onPressed: () => setState(() => _focusedDay = _selectedDay = today),
            ),
          const AlertsBellButton(),
        ],
      ),
      floatingActionButton: pets.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(
                AppRoutes.appointmentNew(
                  petId: petFilter ?? (pets.length == 1 ? pets.single.id : null),
                  date: _selectedDay.isBefore(today) ? null : _selectedDay,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Appointment'),
            ),
      body: calendar.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Could not load your calendar.',
          onRetry: () => ref.invalidate(calendarProvider),
        ),
        data: (_) => CustomScrollView(
          slivers: [
            if (pets.length > 1)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final (id, label) in [
                        (null, 'All pets'),
                        for (final p in pets) (p.id, '${p.species.emoji} ${p.name}'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: petFilter == id,
                            onSelected: (_) =>
                                ref.read(calendarPetFilterProvider.notifier).select(id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: TableCalendar<CalendarEvent>(
                firstDay: DateTime(today.year - 5),
                lastDay: DateTime(today.year + 5, 12, 31),
                focusedDay: _focusedDay,
                currentDay: today,
                calendarFormat: _format,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.twoWeeks: '2 weeks',
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                eventLoader: snapshot.eventsOn,
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = dateOnly(selected);
                  _focusedDay = focused;
                }),
                onFormatChanged: (f) => setState(() => _format = f),
                onPageChanged: (focused) => _focusedDay = focused,
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextStyle: theme.textTheme.titleMedium!,
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) => events.isEmpty
                      ? null
                      : Positioned(
                          bottom: 4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final e in events.take(3))
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: e.tone.colorOf(context),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  isSameDay(_selectedDay, today)
                      ? 'Today · ${DateFormat.MMMMd().format(_selectedDay)}'
                      : DateFormat.yMMMMEEEEd().format(_selectedDay),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            if (dayEvents.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  child: Text(
                    pets.isEmpty ? 'Add a pet to start scheduling.' : 'Nothing scheduled.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                sliver: SliverList.separated(
                  itemCount: dayEvents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => CalendarEventTile(
                    event: dayEvents[i],
                    onTap: () => _open(dayEvents[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
