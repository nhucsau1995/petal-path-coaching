import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'check_in_screen.dart';

/// Sign in. The plan chip picks which demo account (tier) to sign in as.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  Tier _tier = Tier.oneToOne;
  final _email = TextEditingController(text: 'maya@example.com');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Stack(
                children: [
                  Image.asset('assets/images/hero-stretch.jpg', height: 260, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xCC0C1C1F), borderRadius: BorderRadius.circular(999)),
                      child: Text('MINDFUL ROUTINE', style: AppText.caption(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(child: Image.asset('assets/images/logo-mark.png', width: 44, height: 44)),
            const SizedBox(height: 8),
            Center(child: Text('Petal Path', style: AppText.display())),
            const SizedBox(height: 4),
            Center(child: Text('Small steps. Steady growth.', style: AppText.body(color: AppColors.textSecondary))),
            const SizedBox(height: 16),
            Text('Choose a demo plan', style: AppText.caption(), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in [Tier.group, Tier.oneToOne, Tier.membership])
                  ChoiceChip(
                    key: Key('plan_${t.name}'),
                    label: Text(t.label),
                    selected: _tier == t,
                    onSelected: (_) => setState(() => _tier = t),
                    showCheckmark: false,
                    shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.accentTint,
                    labelStyle: AppText.label(
                      color: _tier == t ? AppColors.accentFill : AppColors.textSecondary,
                      weight: _tier == t ? FontWeight.w600 : FontWeight.w500,
                    ),
                    side: BorderSide(color: _tier == t ? AppColors.accentFill : AppColors.border),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email', style: AppText.label(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: AppText.body(),
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                  const SizedBox(height: 16),
                  PrimaryButton(
                    key: const Key('sign_in'),
                    label: 'Sign in',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => ref.read(sessionProvider.notifier).signIn(_tier),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      key: const Key('start_onboarding'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CheckInScreen(
                            title: '1:1 onboarding',
                            questions: onboardingForm,
                            onSubmit: (ref) {
                              ref.read(sessionProvider.notifier).signIn(Tier.oneToOne);
                              ref.read(sessionProvider.notifier).completeOnboarding();
                            },
                          ),
                        ),
                      ),
                      child: Text('New here? Start onboarding', style: AppText.label(color: AppColors.accentFill)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
