import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// One question per step. Used for block check-ins and the 1:1 onboarding
/// form; the questions come from coach-editable content.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, required this.title, required this.questions, required this.onSubmit});

  final String title;
  final List<CheckInQuestion> questions;
  final void Function(WidgetRef ref) onSubmit;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  int _step = 0;
  bool _sent = false;
  final Map<int, String> _choice = {};
  final Map<int, double> _scale = {};
  final Map<int, TextEditingController> _text = {};

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(int i) => _text.putIfAbsent(i, TextEditingController.new);

  bool get _answered {
    final q = widget.questions[_step];
    return switch (q.kind) {
      QuestionKind.choice => _choice.containsKey(_step),
      QuestionKind.text => true,
      QuestionKind.scale => true,
    };
  }

  void _next() {
    if (_step < widget.questions.length - 1) {
      setState(() => _step++);
      return;
    }
    widget.onSubmit(ref);
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    return Scaffold(
      body: SafeArea(
        child: _sent
            ? _Sent(onDone: () => Navigator.of(context).pop())
            : Column(
                children: [
                  BackHeader(title: widget.title),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Step ${_step + 1} of $total', style: AppText.caption()),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: (_step + 1) / total,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            color: AppColors.accentFill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      children: [_question(_step)],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: PrimaryButton(
                      key: const Key('checkin_next'),
                      label: _step == total - 1 ? 'Send to my coach' : 'Next',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _answered ? _next : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _question(int i) {
    final q = widget.questions[i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(q.prompt, style: AppText.oswald(24, 600)),
        const SizedBox(height: 16),
        switch (q.kind) {
          QuestionKind.choice => Column(
              children: [
                for (final o in q.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionButton(
                      key: Key('option_$o'),
                      label: o,
                      selected: _choice[i] == o,
                      onTap: () => setState(() => _choice[i] = o),
                    ),
                  ),
              ],
            ),
          QuestionKind.text => TextField(
              key: const Key('checkin_text'),
              controller: _controller(i),
              minLines: 4,
              maxLines: 6,
              style: AppText.body(),
              decoration: InputDecoration(
                hintText: q.hint,
                hintStyle: AppText.body(color: AppColors.textTertiary),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: const BorderSide(color: AppColors.borderStrong, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  borderSide: const BorderSide(color: AppColors.accentFill, width: 2),
                ),
              ),
            ),
          QuestionKind.scale => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Your answer', style: AppText.label(color: AppColors.textSecondary))),
                      TintChip('${(_scale[i] ?? 7).round()} / 10'),
                    ],
                  ),
                  Slider(
                    key: const Key('checkin_scale'),
                    value: _scale[i] ?? 7,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppColors.accentFill,
                    inactiveColor: AppColors.border,
                    onChanged: (v) => setState(() => _scale[i] = v),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('1, poor', style: AppText.caption())),
                      Text('10, great', style: AppText.caption()),
                    ],
                  ),
                ],
              ),
            ),
        },
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentTint : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: selected ? AppColors.accentFill : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppText.body(color: selected ? AppColors.accentFill : AppColors.textPrimary)
                        .copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.accentFill),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sent extends StatelessWidget {
  const _Sent({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const IconBubble(Icons.check_rounded, size: 72),
          const SizedBox(height: 20),
          Text('Sent to your coach', style: AppText.display(), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Thank you. Your answers are private between you and your coach.',
              style: AppText.body(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 28),
          PrimaryButton(key: const Key('checkin_done'), label: 'Done', onPressed: onDone),
        ],
      ),
    );
  }
}
