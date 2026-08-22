import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/applications_provider.dart';
import '../../jobs/providers/jobs_provider.dart';
import '../../../models/job_model.dart';
import '../../../core/theme/app_theme.dart';

class DeadlineCalendarScreen extends StatefulWidget {
  const DeadlineCalendarScreen({super.key});

  @override
  State<DeadlineCalendarScreen> createState() =>
      _DeadlineCalendarScreenState();
}

class _DeadlineCalendarScreenState
    extends State<DeadlineCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<_CalendarEvent>> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _buildEvents();
  }

  void _buildEvents() {
    final jobs = context.read<JobsProvider>();
    final applications =
        context.read<ApplicationsProvider>();

    _events = {};

    // Job deadlines
    for (final job in [...jobs.jobs, ...jobs.internships]) {
      final day = _normalise(job.deadline);
      _events.putIfAbsent(day, () => []);
      _events[day]!.add(_CalendarEvent(
        title: job.title,
        subtitle: job.companyName,
        type: _EventType.deadline,
        jobId: job.id,
        date: job.deadline,
      ));
    }

    // Applied dates
    for (final app in applications.applications) {
      final day = _normalise(app.appliedAt);
      _events.putIfAbsent(day, () => []);
      _events[day]!.add(_CalendarEvent(
        title: '${app.jobTitle} — Applied',
        subtitle: app.companyName,
        type: _EventType.applied,
        date: app.appliedAt,
      ));
    }
  }

  DateTime _normalise(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  List<_CalendarEvent> _getEventsForDay(DateTime day) =>
      _events[_normalise(day)] ?? [];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : <_CalendarEvent>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Deadline calendar')),
      body: Column(
        children: [
          // Calendar
          TableCalendar<_CalendarEvent>(
            firstDay: DateTime.now()
                .subtract(const Duration(days: 365)),
            lastDay: DateTime.now()
                .add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) =>
                isSameDay(_selectedDay, d),
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: scheme.primary),
              markerDecoration: BoxDecoration(
                color: AppTheme.warning,
                shape: BoxShape.circle,
              ),
              markerSize: 5,
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: scheme.onSurface,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurface,
              ),
            ),
            onDaySelected: (selected, focused) =>
                setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            onPageChanged: (focused) =>
                setState(() => _focusedDay = focused),
          ),

          const Divider(height: 1),

          // Events for selected day
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_rounded,
                            size: 48,
                            color: scheme.onSurfaceVariant
                                .withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('No events on this day',
                            style: TextStyle(
                              color:
                                  scheme.onSurfaceVariant,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedEvents.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) =>
                        _EventCard(
                          event: selectedEvents[i],
                          onTap: selectedEvents[i].jobId !=
                                  null
                              ? () => context.push(
                                  '/job/${selectedEvents[i].jobId}')
                              : null,
                        )
                            .animate()
                            .fadeIn(
                                duration: 250.ms,
                                delay: (i * 50).ms)
                            .slideY(begin: 0.05, end: 0),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _EventType { deadline, applied }

class _CalendarEvent {
  final String title;
  final String subtitle;
  final _EventType type;
  final String? jobId;
  final DateTime date;

  const _CalendarEvent({
    required this.title,
    required this.subtitle,
    required this.type,
    this.jobId,
    required this.date,
  });
}

class _EventCard extends StatelessWidget {
  final _CalendarEvent event;
  final VoidCallback? onTap;

  const _EventCard({required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDeadline = event.type == _EventType.deadline;
    final color =
        isDeadline ? AppTheme.warning : AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: scheme.outline.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 64,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(event.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isDeadline ? 'Deadline' : 'Applied',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}