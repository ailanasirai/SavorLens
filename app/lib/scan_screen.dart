import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'dietitian_screen.dart';
import 'main.dart';

const String _api = 'http://localhost:8000';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late final AnimationController _scan;
  Uint8List? _bytes;
  String _fileName = 'meal.jpg';
  bool _analyzing = false;
  bool _showResult = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_analyzing) return;
    try {
      final XFile? file =
      await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _fileName = file.name.isEmpty ? 'meal.jpg' : file.name;
        _showResult = false;
        _result = null;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open the photo. Please try again.')),
      );
    }
  }

  Future<void> _analyze() async {
    if (_bytes == null) return;
    setState(() {
      _analyzing = true;
      _showResult = false;
      _result = null;
      _error = null;
    });
    try {
      final req = http.MultipartRequest('POST', Uri.parse('$_api/predict'));
      req.files.add(
          http.MultipartFile.fromBytes('file', _bytes!, filename: _fileName));
      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 200) {
        throw Exception('Server returned ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _result = data;
        _analyzing = false;
        _showResult = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _showResult = true;
        _error =
        'Could not analyze the photo. Is the backend running on port 8000?';
      });
    }
  }

  void _openDietitians() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DietitianScreen()),
    );
  }

  String _title(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  String _pct(dynamic v) => '${((v as num) * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: FloatingFruits())),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    children: [
                      _header(),
                      const SizedBox(height: 12),
                      Expanded(child: _previewArea()),
                      const SizedBox(height: 16),
                      _buttons(),
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
                text: 'Scan ',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGreen,
                ),
              ),
              TextSpan(
                text: 'your meal',
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

  Widget _previewArea() {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        return GestureDetector(
          onTap: _bytes == null ? _pickPhoto : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.28),
                  blurRadius: 34,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_bytes == null)
                    _placeholder()
                  else
                    Image.memory(_bytes!, fit: BoxFit.cover),
                  if (_analyzing) ...[
                    Container(color: Colors.black.withValues(alpha: 0.25)),
                    AnimatedBuilder(
                      animation: _scan,
                      builder: (context, _) {
                        return Positioned(
                          left: 0,
                          right: 0,
                          top: _scan.value * (h - 8),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4ADE80)
                                      .withValues(alpha: 0.9),
                                  blurRadius: 18,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Analyzing your meal...',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_showResult)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _resultCard()
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.3, end: 0),
                    ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
      },
    );
  }

  Widget _placeholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(Icons.restaurant_menu,
                size: 44, color: AppColors.green),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.12, 1.12),
            duration: 1200.ms,
          ),
          const SizedBox(height: 18),
          Text(
            'Add a photo of your meal',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap here or use the button below',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.ink.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        Expanded(
          child: _GlowButton(
            label: _bytes == null ? 'Choose photo' : 'Change photo',
            icon: Icons.photo_library_rounded,
            colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            glow: AppColors.green,
            onTap: _analyzing ? null : _pickPhoto,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlowButton(
            label: _analyzing ? 'Analyzing...' : 'Analyze',
            icon: Icons.auto_awesome,
            colors: const [Color(0xFFFF8A00), Color(0xFFFF3D68)],
            glow: const Color(0xFFFF5A36),
            loading: _analyzing,
            onTap: (_bytes != null && !_analyzing) ? _analyze : null,
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _resultCard() {
    final r = _result;
    final bool sure = r != null && r['sure'] == true;
    final List top3 = (r?['top3'] as List?) ?? [];

    String headline;
    String sub = '';
    if (_error != null) {
      headline = 'Something went wrong';
      sub = _error!;
    } else if (sure) {
      headline = _title(r!['dish'].toString());
      sub = 'Confidence ${_pct(r['confidence'])}';
    } else {
      headline = 'Not sure about this meal';
      sub = 'Try a clearer photo with the dish in the centre.';
    }

    final others = top3
        .skip(sure ? 1 : 0)
        .take(sure ? 2 : 3)
        .map((e) => '${_title(e['dish'].toString())} ${_pct(e['confidence'])}')
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _chip('AI model v1 (12 dishes)', AppColors.green),
              if (_error == null && !sure)
                _chip('LOW CONFIDENCE', AppColors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.deepGreen,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.ink.withValues(alpha: 0.75),
            ),
          ),
          if (_error == null && others.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sure ? 'Other guesses: $others' : 'Closest guesses: $others',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.ink.withValues(alpha: 0.65),
              ),
            ),
          ],
          if (_error == null) ...[
            const SizedBox(height: 6),
            Text(
              'Nutrition estimates: not measured yet. Test accuracy of model v1: 84.7%.',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontStyle: FontStyle.italic,
                color: AppColors.ink.withValues(alpha: 0.65),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _GlowButton(
            label: 'Book a dietitian',
            icon: Icons.event_available_rounded,
            colors: const [Color(0xFFFF8A00), Color(0xFFFF3D68)],
            glow: const Color(0xFFFF5A36),
            onTap: _openDietitians,
          ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.glow,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final Color glow;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final button = Opacity(
      opacity: enabled || loading ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: LinearGradient(colors: colors),
          boxShadow: enabled || loading
              ? [
            BoxShadow(
              color: glow.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(34),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  else
                    Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!enabled) return button;
    return button
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.04, 1.04),
      duration: 900.ms,
    );
  }
}