import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'approval_screen.dart'; // CHANGED: new import
import 'main.dart';

class Dietitian {
  const Dietitian(this.name, this.focus, this.region, this.languages, this.slot);

  final String name;
  final String focus;
  final String region;
  final String languages;
  final String slot;
}

// Demo profiles only. These are not real people.
const List<Dietitian> demoDietitians = [
  Dietitian('Dr. Amina (demo)', 'Weight management and balanced diets',
      'South Asia', 'Urdu • English', 'Tomorrow, 10:00 AM'),
  Dietitian('Dr. Bilal (demo)', 'Family nutrition and kids diets',
      'South Asia', 'Urdu • Punjabi', 'Tomorrow, 4:00 PM'),
  Dietitian('Dr. Omar (demo)', 'Diabetes-friendly meal planning',
      'Middle East', 'Arabic • English', 'Tomorrow, 2:00 PM'),
  Dietitian('Dr. Sara (demo)', 'Sports and high-protein nutrition',
      'Europe', 'English • French', 'Thursday, 11:00 AM'),
  Dietitian('Dr. Kwame (demo)', 'Budget-friendly healthy eating',
      'Africa', 'English • Swahili', 'Friday, 9:00 AM'),
  Dietitian('Dr. Lucia (demo)', 'Heart-healthy meal planning',
      'Americas', 'Spanish • English', 'Friday, 3:00 PM'),
];

const List<String> regions = [
  'All',
  'South Asia',
  'Middle East',
  'Europe',
  'Africa',
  'Americas',
];

class DietitianScreen extends StatefulWidget {
  const DietitianScreen({super.key});

  @override
  State<DietitianScreen> createState() => _DietitianScreenState();
}

class _DietitianScreenState extends State<DietitianScreen> {
  int _price = 10;
  String _region = 'All';

  List<Dietitian> get _filtered => _region == 'All'
      ? demoDietitians
      : demoDietitians.where((d) => d.region == _region).toList();

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return GradientScaffold(
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: FloatingFruits())),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(6, 14, 6, 30),
                            children: [
                              _coachCard(),
                              const SizedBox(height: 22),
                              _title('Pay what you can'),
                              _subtitle(
                                  'Everyone deserves expert advice. Choose the amount that works for you.'),
                              const SizedBox(height: 12),
                              _tiers(),
                              const SizedBox(height: 22),
                              _title('Find a dietitian'),
                              _subtitle(
                                  'Pick your region. Demo profiles for the hackathon, not real people.'),
                              const SizedBox(height: 12),
                              _regionChips(),
                              const SizedBox(height: 16),
                              if (list.isEmpty)
                                _empty()
                              else
                                for (int i = 0; i < list.length; i++) ...[
                                  _card(list[i])
                                      .animate(key: ValueKey('$_region-$i'))
                                      .fadeIn(
                                      delay: (100 * i).ms,
                                      duration: 450.ms)
                                      .slideY(begin: 0.2, end: 0),
                                  const SizedBox(height: 18),
                                ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.deepGreen,
    ),
  );

  Widget _subtitle(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      fontSize: 12.5,
      color: AppColors.ink.withValues(alpha: 0.7),
    ),
  );

  Widget _header() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.deepGreen),
          ),
        ),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Care ',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGreen,
                ),
              ),
              TextSpan(
                text: 'for you',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  BoxDecoration _glowBox({Gradient? gradient, Color? color}) {
    return BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.orange.withValues(alpha: 0.22),
          blurRadius: 26,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _coachCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glowBox(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.mint],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_rounded,
                  color: AppColors.green, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Free AI Nutrition Coach',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepGreen,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'FREE',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cannot afford a dietitian right now? Chat with our AI coach about your meal, any time. General guidance only, not medical advice.',
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          _glowButton(
            label: 'Chat with AI coach',
            icon: Icons.chat_bubble_rounded,
            colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            glow: AppColors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI coach chat is coming soon.')),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _tiers() {
    return Row(
      children: [
        for (final p in const [5, 10, 15]) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _price = p),
              child: AnimatedContainer(
                duration: 250.ms,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _price == p ? null : Colors.white,
                  gradient: _price == p
                      ? const LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFFF3D68)])
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: (_price == p
                          ? const Color(0xFFFF5A36)
                          : AppColors.orange)
                          .withValues(alpha: _price == p ? 0.45 : 0.18),
                      blurRadius: _price == p ? 22 : 12,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '\$$p',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _price == p ? Colors.white : AppColors.deepGreen,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (p != 15) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _regionChips() {
    return SizedBox(
      height: 46,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          itemCount: regions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final r = regions[i];
            final sel = r == _region;
            return GestureDetector(
              onTap: () => setState(() => _region = r),
              child: AnimatedContainer(
                duration: 250.ms,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: sel ? null : Colors.white,
                  gradient: sel
                      ? const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)])
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: (sel ? AppColors.green : AppColors.orange)
                          .withValues(alpha: sel ? 0.45 : 0.18),
                      blurRadius: sel ? 18 : 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    r,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.deepGreen,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _empty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glowBox(color: Colors.white.withValues(alpha: 0.9)),
      child: Center(
        child: Text(
          'No dietitians in this region yet.\nTry the free AI coach above.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.deepGreen),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.deepGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Dietitian d) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glowBox(color: Colors.white.withValues(alpha: 0.92)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.mint,
                child: Icon(Icons.person_rounded,
                    color: AppColors.green, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    Text(
                      d.focus,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip(Icons.public_rounded, d.region),
              _chip(Icons.translate_rounded, d.languages),
              _chip(Icons.schedule_rounded, d.slot),
            ],
          ),
          const SizedBox(height: 14),
          _glowButton(
            label: 'Select  •  \$$_price',
            icon: Icons.check_circle_rounded,
            colors: const [Color(0xFFFF8A00), Color(0xFFFF3D68)],
            glow: const Color(0xFFFF5A36),
            // CHANGED: opens the approval screen
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ApprovalScreen(
                    dietitianName: d.name,
                    slot: d.slot,
                    price: _price,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _glowButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required Color glow,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}