import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

const String backendUrl = 'http://localhost:8000';

enum _Stage { review, creating, waiting, capturing, done, failed }

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({
    super.key,
    required this.dietitianName,
    required this.slot,
    required this.price,
  });

  final String dietitianName;
  final String slot;
  final int price;

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  _Stage _stage = _Stage.review;
  String? _orderId;
  String? _approveUrl;
  String? _status;
  String? _error;

  Future<void> _createOrder() async {
    setState(() {
      _stage = _Stage.creating;
      _error = null;
    });
    try {
      final res = await http.post(
        Uri.parse('$backendUrl/paypal/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': '${widget.price}.00',
          'description': 'Dietitian consultation',
        }),
      );
      if (res.statusCode != 200) {
        throw Exception('Backend returned ${res.statusCode}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      _orderId = data['order_id']?.toString();
      _approveUrl = data['approve_url']?.toString();
      if (_orderId == null || _approveUrl == null) {
        throw Exception('Unexpected response from backend');
      }
      if (!mounted) return;
      setState(() => _stage = _Stage.waiting);
      await _openPayPal();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.failed;
        _error =
        'Could not create the PayPal order. Is the backend running on port 8000? ($e)';
      });
    }
  }

  Future<void> _openPayPal() async {
    if (_approveUrl == null) return;
    await launchUrl(Uri.parse(_approveUrl!),
        webOnlyWindowName: '_blank');
  }

  Future<void> _capture() async {
    if (_orderId == null) return;
    setState(() => _stage = _Stage.capturing);
    try {
      final res = await http
          .post(Uri.parse('$backendUrl/paypal/capture-order/$_orderId'));
      final data = jsonDecode(res.body);
      final status = data is Map ? data['status']?.toString() : null;
      if (!mounted) return;
      if (res.statusCode == 200 && status == 'COMPLETED') {
        setState(() {
          _status = status;
          _stage = _Stage.done;
        });
      } else {
        setState(() {
          _stage = _Stage.waiting;
          _error =
          'Payment is not completed yet (status: ${status ?? 'unknown'}). Finish the approval in the PayPal tab, then try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.waiting;
        _error = 'Capture failed: $e';
      });
    }
  }

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(context),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _agentCard()
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: 0.15, end: 0),
                                const SizedBox(height: 18),
                                _summaryCard()
                                    .animate()
                                    .fadeIn(delay: 150.ms, duration: 500.ms)
                                    .slideY(begin: 0.15, end: 0),
                                const SizedBox(height: 18),
                                if (_stage == _Stage.waiting ||
                                    _stage == _Stage.capturing)
                                  _waitingCard(),
                                if (_stage == _Stage.done) _doneCard(),
                                if (_error != null) _errorCard(),
                                const SizedBox(height: 12),
                                _safetyNote(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._bottomButtons(),
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

  List<Widget> _bottomButtons() {
    switch (_stage) {
      case _Stage.review:
      case _Stage.failed:
        return [
          _glowButton(
            label: _stage == _Stage.failed
                ? 'Try again'
                : 'Approve and pay \$${widget.price}',
            icon: Icons.verified_rounded,
            colors: const [Color(0xFFFF8A00), Color(0xFFFF3D68)],
            glow: const Color(0xFFFF5A36),
            pulse: true,
            onTap: _createOrder,
          ),
          const SizedBox(height: 12),
          _glowButton(
            label: 'Cancel',
            icon: Icons.close_rounded,
            colors: const [Color(0xFF9CA3AF), Color(0xFF6B7280)],
            glow: const Color(0xFF6B7280),
            onTap: () => Navigator.of(context).pop(),
          ),
        ];
      case _Stage.creating:
        return [
          _glowButton(
            label: 'Creating PayPal order...',
            icon: Icons.hourglass_top_rounded,
            colors: const [Color(0xFFFF8A00), Color(0xFFFF3D68)],
            glow: const Color(0xFFFF5A36),
            onTap: null,
          ),
        ];
      case _Stage.waiting:
      case _Stage.capturing:
        return [
          _glowButton(
            label: _stage == _Stage.capturing
                ? 'Checking payment...'
                : 'I approved in PayPal',
            icon: Icons.check_circle_rounded,
            colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            glow: AppColors.green,
            pulse: _stage == _Stage.waiting,
            onTap: _stage == _Stage.waiting ? _capture : null,
          ),
          const SizedBox(height: 12),
          _glowButton(
            label: 'Open PayPal again',
            icon: Icons.open_in_new_rounded,
            colors: const [Color(0xFFFF8A00), Color(0xFFFF3D68)],
            glow: const Color(0xFFFF5A36),
            onTap: _stage == _Stage.waiting ? _openPayPal : null,
          ),
        ];
      case _Stage.done:
        return [
          _glowButton(
            label: 'Back to home',
            icon: Icons.home_rounded,
            colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            glow: AppColors.green,
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ];
    }
  }

  Widget _header(BuildContext context) {
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
                text: 'Your ',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGreen,
                ),
              ),
              TextSpan(
                text: 'approval',
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

  Widget _agentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glowBox(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.mint],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy_rounded,
              color: AppColors.green, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SavorLens agent',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'I prepared this booking for you. Nothing is charged until you approve it below.',
                  style: GoogleFonts.poppins(
                      fontSize: 12.5, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.orange),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.ink.withValues(alpha: 0.7)),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glowBox(color: Colors.white.withValues(alpha: 0.92)),
      child: Column(
        children: [
          _row(Icons.person_rounded, 'Dietitian', widget.dietitianName),
          const Divider(height: 1),
          _row(Icons.schedule_rounded, 'Time slot', widget.slot),
          const Divider(height: 1),
          _row(Icons.payments_rounded, 'Amount', '\$${widget.price}.00 USD'),
          const Divider(height: 1),
          _row(Icons.lock_outline_rounded, 'Payment', 'PayPal (sandbox)'),
        ],
      ),
    );
  }

  Widget _waitingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _glowBox(color: Colors.white.withValues(alpha: 0.92)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waiting for your PayPal approval',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A PayPal tab opened. Log in with the sandbox buyer account, approve the payment, then come back here and press the green button.',
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Order: $_orderId',
            style: GoogleFonts.poppins(
                fontSize: 11.5, color: AppColors.ink.withValues(alpha: 0.6)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _doneCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: _glowBox(
        gradient: const LinearGradient(
          colors: [Colors.white, AppColors.mint],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 28),
              const SizedBox(width: 8),
              Text(
                'Booking confirmed (sandbox)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.dietitianName}, ${widget.slot}\nPayPal status: $_status\nOrder: $_orderId',
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.ink),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _errorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _error!,
        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF991B1B)),
      ),
    );
  }

  Widget _safetyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo only: this uses the PayPal sandbox, so no real money moves. The dietitian is a demo profile.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.ink),
            ),
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
    required VoidCallback? onTap,
    bool pulse = false,
  }) {
    final enabled = onTap != null;
    final button = Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
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
                  Icon(icon, color: Colors.white, size: 22),
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
    if (!pulse || !enabled) return button;
    return button
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.03, 1.03),
      duration: 900.ms,
    );
  }
}