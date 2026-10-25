import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SavorLensApp());
}

class AppColors {
  static const cream = Color(0xFFFFF7ED);
  static const peach = Color(0xFFFFE4C7);
  static const mint = Color(0xFFD1FAE5);
  static const green = Color(0xFF16A34A);
  static const deepGreen = Color(0xFF14532D);
  static const orange = Color(0xFFF97316);
  static const ink = Color(0xFF1F2937);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cream, peach, mint],
  );
}

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: child,
      ),
    );
  }
}

class SavorLensApp extends StatelessWidget {
  const SavorLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SavorLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class Dish {
  const Dish(this.name, this.asset, this.origin, this.blurb);

  final String name;
  final String asset;
  final String origin;
  final String blurb;
}

class DishSection {
  const DishSection(this.title, this.subtitle, this.thumb, this.dishes);

  final String title;
  final String subtitle;
  final String thumb;
  final List<Dish> dishes;
}

const List<DishSection> sections = [
  DishSection(
    'South Asia',
    'Pakistan • India • Bangladesh • Nepal • Sri Lanka',
    'assets/images/biryani.jpg',
    [
      Dish('Biryani', 'assets/images/biryani.jpg', 'Pakistan • India • Bangladesh',
          'Fragrant basmati rice layered with spiced meat and slow-cooked together.'),
      Dish('Chicken Karahi', 'assets/images/karahi.jpg', 'Pakistan • India',
          'Chicken cooked quickly in a wok-style pan with tomatoes, ginger and green chilies.'),
      Dish('Daal', 'assets/images/daal.jpg', 'Pakistan • India • Bangladesh • Nepal',
          'Lentils simmered until soft and finished with a sizzling spice tempering.'),
      Dish('Nihari', 'assets/images/nihari.jpg', 'Pakistan • India',
          'Slow-cooked meat stew in a rich spiced gravy, traditionally a breakfast dish.'),
      Dish('Samosa', 'assets/images/samosa.jpg', 'South Asia and beyond',
          'Crisp pastry triangles filled with spiced potato or minced meat.'),
      Dish('Seekh Kabab', 'assets/images/seekh_kabab.jpg', 'Pakistan • India',
          'Spiced minced meat shaped on skewers and grilled over a flame.'),
      Dish('Haleem', 'assets/images/haleem.jpg', 'Pakistan • India • Bangladesh',
          'A slow-cooked porridge of meat, wheat and lentils, topped with fried onions and ginger.'),
      Dish('Paratha', 'assets/images/paratha.jpg', 'Pakistan • India • Bangladesh',
          'Flaky, layered flatbread cooked on a griddle with ghee or oil.'),
      Dish('Gulab Jamun', 'assets/images/gulab_jamun.jpg', 'India • Pakistan • Bangladesh',
          'Soft milk-based sweet balls, fried golden and soaked in rose-scented sugar syrup.'),
    ],
  ),
  DishSection(
    'East and Southeast Asia',
    'Japan • China • Thailand',
    'assets/images/sushi.jpg',
    [
      Dish('Sushi', 'assets/images/sushi.jpg', 'Japan',
          'Vinegared rice paired with fish, vegetables or seaweed.'),
      Dish('Ramen', 'assets/images/ramen.jpg', 'Japan',
          'Wheat noodles in a savory broth with toppings like egg.'),
      Dish('Gyoza (Dumplings)', 'assets/images/dumplings.jpg', 'Japan • China',
          'Pan-fried dumplings with a crisp base and a savory filling.'),
      Dish('Pad Thai', 'assets/images/pad_thai.jpg', 'Thailand',
          'Stir-fried rice noodles with a sweet and sour tamarind sauce.'),
    ],
  ),
  DishSection(
    'Europe',
    'Italy • France • and more',
    'assets/images/pizza.jpg',
    [
      Dish('Pizza', 'assets/images/pizza.jpg', 'Italy',
          'Baked flatbread topped with tomato sauce and cheese.'),
      Dish('Lasagna', 'assets/images/lasagna.jpg', 'Italy',
          'Layers of pasta baked with meat sauce and cheese.'),
      Dish('Pancakes', 'assets/images/pancakes.jpg', 'Europe • North America',
          'Soft griddle cakes served with fruit or syrup.'),
    ],
  ),
  DishSection(
    'The Americas',
    'Mexico • United States',
    'assets/images/tacos.jpg',
    [
      Dish('Tacos', 'assets/images/tacos.jpg', 'Mexico',
          'Soft tortillas folded around meat, vegetables and fresh toppings.'),
      Dish('Burger', 'assets/images/burger.jpg', 'United States',
          'A grilled patty in a bun with cheese and fresh toppings.'),
      Dish('Fried Chicken', 'assets/images/fried_chicken.jpg', 'United States',
          'Chicken coated and fried until golden and crispy.'),
    ],
  ),
  DishSection(
    'Middle East and fresh',
    'Levant • Mediterranean • everywhere',
    'assets/images/shawarma.jpg',
    [
      Dish('Shawarma', 'assets/images/shawarma.jpg', 'Middle East',
          'Spiced meat shaved from a rotating spit and wrapped in flatbread.'),
      Dish('Hummus', 'assets/images/hummus.jpg', 'Middle East',
          'Creamy chickpea and sesame dip, served with bread.'),
      Dish('Salad', 'assets/images/salad.jpg', 'Worldwide',
          'Fresh raw vegetables, light and nutritious.'),
    ],
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Hero()),
            for (final s in sections) ...[
              _sectionHeader(s),
              _dishGrid(s.dishes),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Text(
                  'Food photos from Pixabay contributors (Pixabay Content License). Full credits in the README.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.ink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

SliverToBoxAdapter _sectionHeader(DishSection s) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                s.thumb,
                fit: BoxFit.cover,
                cacheWidth: 200,
                errorBuilder: (context, error, stack) =>
                    Container(color: AppColors.peach),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepGreen,
                  ),
                ),
                Text(
                  s.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.ink.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
    ),
  );
}

Widget _dishGrid(List<Dish> items) {
  return SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.15,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, i) => DishCard(dish: items[i])
            .animate()
            .fadeIn(delay: (60 * i).ms, duration: 500.ms)
            .slideY(begin: 0.2, end: 0),
        childCount: items.length,
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: Stack(
        children: [
          const _GlowBlobs(),
          const Positioned.fill(child: IgnorePointer(child: FloatingFruits())),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withValues(alpha: 0.3),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: AppColors.green,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.12, 1.12),
                      duration: 1200.ms,
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Savor',
                            style: GoogleFonts.poppins(
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepGreen,
                            ),
                          ),
                          TextSpan(
                            text: 'Lens',
                            style: GoogleFonts.poppins(
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.3, end: 0)
                        .then()
                        .shimmer(
                      duration: 1800.ms,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Snap your plate. Understand your meal.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: AppColors.ink,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    const SizedBox(height: 32),
                    _ScanButton(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scan screen coming next!'),
                          ),
                        );
                      },
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 900.ms,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Book a dietitian and pay securely with PayPal (sandbox demo)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlobs extends StatelessWidget {
  const _GlowBlobs();

  Widget _blob(Color color) {
    return Container(
      width: 460,
      height: 460,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.1, 1.1),
      duration: 3500.ms,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: -140, top: -100, child: _blob(AppColors.orange)),
          Positioned(right: -160, bottom: -140, child: _blob(AppColors.green)),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A00), Color(0xFFFF3D68)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5A36).withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Scan your meal',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
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

class DishCard extends StatefulWidget {
  const DishCard({super.key, required this.dish});

  final Dish dish;

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  bool _flipped = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => setState(() => _flipped = !_flipped),
        child: AnimatedScale(
          scale: _hover ? 1.03 : 1.0,
          duration: 200.ms,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _flipped ? 1 : 0),
            duration: 600.ms,
            curve: Curves.easeInOutCubic,
            builder: (context, t, _) {
              final angle = t * math.pi;
              final showBack = angle > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: showBack
                    ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _back(),
                )
                    : _front(),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _shell() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _hover ? 0.2 : 0.1),
          blurRadius: _hover ? 22 : 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _front() {
    return Container(
      decoration: _shell(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.dish.asset,
              fit: BoxFit.cover,
              cacheWidth: 700,
              errorBuilder: (context, error, stack) => Container(
                color: AppColors.peach,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.restaurant,
                  color: AppColors.orange,
                  size: 40,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.62),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 14,
              child: Text(
                widget.dish.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flip,
                  size: 16,
                  color: AppColors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _back() {
    return Container(
      decoration: _shell().copyWith(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.mint],
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dish.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.dish.origin,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.deepGreen,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.dish.blurb,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.ink,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nutrition appears after you scan.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class FruitSpec {
  const FruitSpec(this.asset, this.emoji);

  final String asset;
  final String emoji;
}

const List<FruitSpec> fruits = [
  FruitSpec('assets/images/fruit_apple.jpg', '🍎'),
  FruitSpec('assets/images/fruit_orange.jpg', '🍊'),
  FruitSpec('assets/images/fruit_lemon.jpg', '🍋'),
  FruitSpec('assets/images/fruit_strawberry.jpg', '🍓'),
  FruitSpec('assets/images/fruit_banana.jpg', '🍌'),
  FruitSpec('assets/images/fruit_broccoli.jpg', '🥦'),
  FruitSpec('assets/images/fruit_tomato.jpg', '🍅'),
  FruitSpec('assets/images/fruit_grapes.jpg', '🍇'),
];

class FloatingFruits extends StatelessWidget {
  const FloatingFruits({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        const textHalf = 320.0;
        final free = w / 2 - textHalf;
        if (free < 90) return const SizedBox.shrink();
        return Stack(
          children: [
            for (int i = 0; i < 12; i++) _buildFruit(i, w, h, free),
          ],
        );
      },
    );
  }

  Widget _buildFruit(int i, double w, double h, double free) {
    final size = 58.0 + ((i * 11) % 22);
    final span = math.max(0.0, free - size - 40);
    final rand = ((i * 37) % 100) / 100;
    final isLeft = i.isEven;
    final x = isLeft ? 24 + span * rand : (w - free) + 16 + span * rand;
    final k = i ~/ 2;
    final y = 24 + k * ((h - size - 48) / 5);
    return _FloatingFruit(
      spec: fruits[i % fruits.length],
      x: x,
      y: y,
      size: size,
      durationMs: 5500 + (i * 700) % 3500,
      phase: i * 1.1,
      delayMs: i * 120,
    );
  }
}

class _FloatingFruit extends StatefulWidget {
  const _FloatingFruit({
    required this.spec,
    required this.x,
    required this.y,
    required this.size,
    required this.durationMs,
    required this.phase,
    required this.delayMs,
  });

  final FruitSpec spec;
  final double x;
  final double y;
  final double size;
  final int durationMs;
  final double phase;
  final int delayMs;

  @override
  State<_FloatingFruit> createState() => _FloatingFruitState();
}

class _FloatingFruitState extends State<_FloatingFruit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x,
      top: widget.y,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final a = _c.value * math.pi * 2 + widget.phase;
          return Transform.translate(
            offset: Offset(math.sin(a * 0.5) * 10, math.sin(a) * 14),
            child: Transform.rotate(
              angle: math.sin(a) * 0.12,
              child: Transform.scale(
                scale: 1 + math.sin(a) * 0.04,
                child: _fruit(),
              ),
            ),
          );
        },
      ).animate().fadeIn(delay: widget.delayMs.ms, duration: 700.ms),
    );
  }

  Widget _fruit() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.38),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          widget.spec.asset,
          fit: BoxFit.cover,
          cacheWidth: 200,
          errorBuilder: (context, error, stack) => Center(
            child: Text(
              widget.spec.emoji,
              style: TextStyle(fontSize: widget.size * 0.55),
            ),
          ),
        ),
      ),
    );
  }
}