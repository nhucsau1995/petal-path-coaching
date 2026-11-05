import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'learn_screen.dart';

/// Lesson video + tasks + PDF. The video is a poster with a simulated
/// player (no streaming in the POC).
class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.week});
  final int week;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final lesson = lessons[widget.week - 1];
    final done = ref.watch(lessonProgressProvider).completedWeeks.contains(widget.week);
    final position = _playing ? 0.18 : 0.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackHeader(title: 'Week ${widget.week}', centerTitle: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  GestureDetector(
                    key: const Key('video_player'),
                    onTap: () => setState(() => _playing = !_playing),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(child: Image.asset('assets/images/coach-video.jpg', fit: BoxFit.cover)),
                            const Positioned.fill(child: PhotoScrim()),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(color: AppColors.accentFill, shape: BoxShape.circle),
                              child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white, size: 36),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 16,
                              child: Text(_playing ? '2:10 / 12:04' : '12:04',
                                  style: AppText.caption(color: Colors.white)),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: LinearProgressIndicator(
                                value: position,
                                minHeight: 4,
                                backgroundColor: const Color(0x55FFFFFF),
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TintChip('Lesson ${lesson.week}'),
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${lesson.minutes} min', style: AppText.caption()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(lesson.title, style: AppText.display()),
                  const SizedBox(height: 10),
                  Text(lesson.summary, style: AppText.body(color: AppColors.textSecondary)),
                  const SectionHeader('Tasks'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final (i, t) in lesson.tasks.indexed) ...[
                          if (i > 0) const Divider(height: 1, color: AppColors.border),
                          TaskTile(week: lesson.week, task: t),
                        ],
                      ],
                    ),
                  ),
                  const SectionHeader('Resources'),
                  for (final r in lesson.resources.take(1)) ResourceTile(resource: r),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                key: const Key('mark_complete'),
                label: done ? 'Lesson complete' : 'Mark lesson complete',
                icon: done ? Icons.check_rounded : null,
                onPressed: done
                    ? null
                    : () {
                        ref.read(lessonProgressProvider.notifier).complete(widget.week);
                        showMockSnack(context, 'Lesson ${widget.week} complete. Nice work.');
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
