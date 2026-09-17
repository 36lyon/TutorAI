import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const TutorAiApp());
}

class TutorAiApp extends StatelessWidget {
  const TutorAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutorAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6CDF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
      ),
      home: const TutorShell(),
    );
  }
}

class TutorShell extends StatefulWidget {
  const TutorShell({super.key});

  @override
  State<TutorShell> createState() => _TutorShellState();
}

class _TutorShellState extends State<TutorShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    LearnScreen(),
    PracticeScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE5EEFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.extension_outlined),
            selectedIcon: Icon(Icons.extension_rounded),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3F8FF), Color(0xFFFBFDFF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HomeHero(),
              const SizedBox(height: 12),
              _FeatureStrip(onSnap: () => _openSnap(context)),
              const SizedBox(height: 10),
              _AskTutorCard(onTap: () => _openAskTutor(context)),
              const SizedBox(height: 14),
              const _LearningSection(),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Continue Learning', action: 'See all'),
              const SizedBox(height: 10),
              SizedBox(
                height: 106,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    const courses = [
                      _CourseData('Mathematics', 'Algebra', 0.72, Icons.calculate_rounded, Color(0xFF8F56FF)),
                      _CourseData('Science', 'Human Body', 0.64, Icons.science_rounded, Color(0xFF18B76A)),
                      _CourseData('English', 'Reading & Comprehension', 0.81, Icons.menu_book_rounded, Color(0xFFFF4F6D)),
                    ];
                    return _CourseCard(data: courses[index]);
                  },
                ),
              ),
              const SizedBox(height: 18),
              const _SectionHeader(title: 'Recommended for You', action: 'See all'),
              const SizedBox(height: 10),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    const items = [
                      _RecommendationData(Icons.track_changes_rounded, 'Take a Quiz', 'Test your knowledge', Color(0xFFFFEBCB)),
                      _RecommendationData(Icons.event_note_rounded, 'Exam Prep', 'Get ready to excel', Color(0xFFE2EEFF)),
                      _RecommendationData(Icons.lightbulb_rounded, 'Daily Learning', 'New topic for you', Color(0xFFFFE1F0)),
                      _RecommendationData(Icons.emoji_events_rounded, 'Achievements', 'Earn badges & rewards', Color(0xFFDDF8E8)),
                    ];
                    return _RecommendationCard(data: items[index]);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openSnap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SnapQuestionScreen()),
    );
  }

  void _openAskTutor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AskTutorAIScreen()),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hero artwork sits on the right and never covers the greeting text.
          Positioned(
            right: -4,
            top: 7,
            width: 198,
            height: 212,
            child: IgnorePointer(
              child: Image.asset(
                'assets/tutor_ai_hero.png',
                fit: BoxFit.contain,
                alignment: Alignment.topRight,
                errorBuilder: (_, __, ___) => const _HeroFallback(),
              ),
            ),
          ),

          // Reference-style graduation cap + TutorAI wordmark.
          Positioned(
            left: 5,
            top: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 44,
                  height: 32,
                  child: CustomPaint(
                    painter: _GraduationCapPainter(),
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Tutor',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14213D),
                  ),
                ),
                const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D6EFD),
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            left: 58,
            top: 43,
            child: Text(
              'Learn Smarter. Achieve Brighter.',
              style: TextStyle(
                fontSize: 10.8,
                color: Color(0xFF365486),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Greeting is placed above the artwork layer and is fully visible.
          const Positioned(
            left: 7,
            top: 99,
            width: 186,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                'Good evening! 👋',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF14213D),
                ),
              ),
            ),
          ),

          // Full question is guaranteed to remain visible, with no microphone here.
          const Positioned(
            left: 7,
            top: 136,
            width: 215,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                'What would you like to learn today?',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.8,
                  color: Color(0xFF52637A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Notification stays in the top-right corner.
          Positioned(
            right: 1,
            top: 6,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _softShadow(),
              ),
              child: const Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF132A4F),
                      size: 27,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 1,
                    child: CircleAvatar(
                      radius: 8.5,
                      backgroundColor: Color(0xFFEF476F),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search bar remains below the greeting; its microphone is inside the bar.
          Positioned(
            left: 2,
            right: 2,
            bottom: 0,
            child: _SearchCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SnapQuestionScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GraduationCapPainter extends CustomPainter {
  const _GraduationCapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF1769E0);
    final blueDark = Paint()..color = const Color(0xFF0D56C7);
    const gold = Color(0xFFFFC83D);
    final goldPaint = Paint()..color = gold;

    final cx = size.width * 0.42;
    final cy = size.height * 0.43;

    final diamond = Path()
      ..moveTo(cx, size.height * 0.12)
      ..lineTo(size.width * 0.92, cy)
      ..lineTo(cx, size.height * 0.72)
      ..lineTo(size.width * 0.08, cy)
      ..close();
    canvas.drawPath(diamond, blue);

    final board = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.24,
        size.height * 0.55,
        size.width * 0.42,
        size.height * 0.24,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(board, blueDark);

    final tasselLine = Paint()
      ..color = gold
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.72, cy),
      Offset(size.width * 0.72, size.height * 0.73),
      tasselLine,
    );
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.79), 3.2, goldPaint);
    canvas.drawLine(
      Offset(size.width * 0.69, size.height * 0.80),
      Offset(size.width * 0.75, size.height * 0.80),
      tasselLine,
    );
  }

  @override
  bool shouldRepaint(covariant _GraduationCapPainter oldDelegate) => false;
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 112,
            width: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFDDEAFF),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.person_rounded, size: 70, color: Color(0xFF4D80D8)),
          ),
          const SizedBox(width: 8),
          Container(
            height: 90,
            width: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F1FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 56, color: Color(0xFF4D80D8)),
          ),
        ],
      ),
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  final VoidCallback onSnap;
  const _FeatureStrip({required this.onSnap});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _FeatureData(
        'assets/tutorai_icons/snap_camera.png',
        'Snap a\nQuestion',
        'Take a photo and\nget step-by-step help',
        const [Color(0xFFDDEEFF), Color(0xFFCBE2FF)],
        Color(0xFFE7F1FF),
      ),
      _FeatureData(
        'assets/tutorai_icons/ask_voice.png',
        'Ask by\nVoice',
        'Speak your\nquestion',
        const [Color(0xFFFFE7F0), Color(0xFFFFD5E5)],
        Color(0xFFFFD9EA),
      ),
      _FeatureData(
        'assets/tutorai_icons/study_notes.png',
        'Study My\nNotes',
        'Upload notes,\nPDF or textbook',
        const [Color(0xFFE1FBF0), Color(0xFFCFF3E5)],
        Color(0xFFD4F8ED),
      ),
      _FeatureData(
        'assets/tutorai_icons/practice_brain.png',
        'Practice',
        'Get questions\nand improve',
        const [Color(0xFFF1E8FF), Color(0xFFE2D4FF)],
        Color(0xFFE7D8FF),
      ),
      _FeatureData(
        'assets/tutorai_icons/my_progress.png',
        'My Progress',
        'Track your\nlearning journey',
        const [Color(0xFFFFF1D8), Color(0xFFFFE5B2)],
        Color(0xFFFFE9C4),
      ),
    ];

    return SizedBox(
      height: 154,
      child: Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(
              child: _FeatureCard(
                data: cards[i],
                onTap: i == 0
                    ? onSnap
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlaceholderScreen(
                              title: cards[i].title.replaceAll('\n', ' '),
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AskTutorCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AskTutorCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE9F0FF), Color(0xFFF3E9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1822446B),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Image.asset(
                    'assets/tutor_ai_hero.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE3ECFF),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Color(0xFF2563EB),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask TutorAI',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF14213D),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Ask anything, get a patient step-by-step tutor.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.2,
                        height: 1.3,
                        color: Color(0xFF52637A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x302563EB),
                      blurRadius: 9,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Open',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final String iconAsset;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color haloColor;

  const _FeatureData(
    this.iconAsset,
    this.title,
    this.subtitle,
    this.colors,
    this.haloColor,
  );
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  final VoidCallback onTap;
  const _FeatureCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.colors,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: data.colors.last.withValues(alpha: 0.30),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.haloColor,
                ),
                child: Center(
                  child: Image.asset(
                    data.iconAsset,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.02,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF14213D),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 7.5,
                  height: 1.05,
                  color: Color(0xFF52637A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shadowColor: const Color(0x222563EB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF49658D)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ask anything or snap a question...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF78869A), fontSize: 14.5),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 38,
                width: 38,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE7F0FF)),
                child: const Icon(Icons.mic_rounded, color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningSection extends StatelessWidget {
  const _LearningSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 650;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: _LearningBanner()),
              SizedBox(width: 10),
              Expanded(child: _ProgressCard()),
            ],
          );
        }
        return const Column(
          children: [
            _LearningBanner(),
            SizedBox(height: 12),
            _ProgressCard(),
          ],
        );
      },
    );
  }
}

class _LearningBanner extends StatelessWidget {
  const _LearningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 166,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3F87), Color(0xFF1469D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x332563EB), blurRadius: 18, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Small Steps', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                Text('Big Results', style: TextStyle(color: Color(0xFF69E4FF), fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 5),
                Text('Learn today for a brighter tomorrow.', style: TextStyle(color: Colors.white70, fontSize: 11.2)),
                SizedBox(height: 9),
                _BannerButton(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🏆', style: TextStyle(fontSize: 34)),
              SizedBox(height: 2),
              Text('📚', style: TextStyle(fontSize: 26)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  const _BannerButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: const Text('Keep Learning  →', style: TextStyle(color: Color(0xFF0E3F87), fontWeight: FontWeight.w900, fontSize: 11.5)),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 166,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: _softShadow()),
      child: Row(
        children: [
          SizedBox(
            height: 76,
            width: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 0.74,
                  strokeWidth: 8,
                  backgroundColor: Color(0xFFE7EEF9),
                  valueColor: AlwaysStoppedAnimation(Color(0xFF1C9E70)),
                ),
                const Text('74%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF14213D))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Learning Progress', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF14213D))),
                SizedBox(height: 9),
                _ProgressLine(name: 'Mathematics', value: '78%', progress: 0.78),
                SizedBox(height: 6),
                _ProgressLine(name: 'Science', value: '64%', progress: 0.64),
                SizedBox(height: 6),
                _ProgressLine(name: 'English', value: '71%', progress: 0.71),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String name;
  final String value;
  final double progress;
  const _ProgressLine({required this.name, required this.value, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Color(0xFF53657E)))),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF2C5AA0))),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: const Color(0xFFEAF0F7)),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF14213D)))),
        Text(action, style: const TextStyle(color: Color(0xFF1664DC), fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _CourseData {
  final String title;
  final String topic;
  final double progress;
  final IconData icon;
  final Color color;
  const _CourseData(this.title, this.topic, this.progress, this.icon, this.color);
}

class _CourseCard extends StatelessWidget {
  final _CourseData data;
  const _CourseCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: _softShadow()),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(color: data.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)),
            child: Icon(data.icon, color: data.color, size: 27),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF17243C))),
                const SizedBox(height: 3),
                Text(data.topic, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF66758A))),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(value: data.progress, minHeight: 6, backgroundColor: const Color(0xFFEAF0F7), valueColor: AlwaysStoppedAnimation(data.color)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text('${(data.progress * 100).round()}%', style: TextStyle(color: data.color, fontWeight: FontWeight.w800, fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _RecommendationData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bg;
  const _RecommendationData(this.icon, this.title, this.subtitle, this.bg);
}

class _RecommendationCard extends StatelessWidget {
  final _RecommendationData data;
  const _RecommendationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: data.bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(13)),
            child: Icon(data.icon, color: const Color(0xFF2D65BF), size: 23),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF17243C))),
                const SizedBox(height: 3),
                Text(data.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.2, color: Color(0xFF5A6C83))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AskTutorMessage {
  final String text;
  final bool fromUser;

  const _AskTutorMessage({required this.text, required this.fromUser});
}

class AskTutorAIScreen extends StatefulWidget {
  const AskTutorAIScreen({super.key});

  @override
  State<AskTutorAIScreen> createState() => _AskTutorAIScreenState();
}

class _AskTutorAIScreenState extends State<AskTutorAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_AskTutorMessage> _messages = [];
  TutorSolution? _currentSolution;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _sending) return;

    setState(() {
      _messages.add(_AskTutorMessage(text: question, fromUser: true));
      _controller.clear();
      _sending = true;
    });

    final conversation = _messages
        .map((message) => '${message.fromUser ? 'Student' : 'TutorAI'}: ${message.text}')
        .toList();

    // Ask TutorAI is a general-purpose tutor chat. It must not force the
    // student's question through the specialist decimal/math lesson engine.
    final backendReply = await _tutorBackend.askStandaloneChat(
      question: question,
      context: _defaultAcademicContext,
      conversation: conversation,
    );

    String reply;
    if (backendReply != null && backendReply.trim().isNotEmpty) {
      reply = backendReply.trim();
    } else if (_currentSolution == null) {
      // Safe offline fallback: use the existing structured tutor engine only
      // when the live AI service is unavailable. This preserves the working
      // math tutor without pretending it is the general AI backend.
      final solution = solveTutorQuestion(question);
      if (!mounted) return;
      _currentSolution = solution;
      reply = _buildStandaloneLessonReply(solution);
    } else {
      reply = _buildStandaloneFollowUp(question, _currentSolution!);
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_AskTutorMessage(text: reply, fromUser: false));
      _sending = false;
    });
  }

  String _buildStandaloneLessonReply(TutorSolution solution) {
    final buffer = StringBuffer();
    buffer.writeln(solution.answer);
    buffer.writeln();
    buffer.writeln(solution.methodSummary);
    if (solution.steps.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Step-by-step:');
      for (var i = 0; i < solution.steps.length && i < 4; i++) {
        final step = solution.steps[i];
        buffer.writeln('${i + 1}. ${step.title}: ${step.body}');
      }
    }
    buffer.writeln();
    buffer.write('Tell me exactly which step or part you do not understand, and I will explain that part again.');
    return buffer.toString();
  }

  String _buildStandaloneFollowUp(String question, TutorSolution solution) {
    final q = question.toLowerCase();
    final match = RegExp(r'(?:step\s*)?(\d+)').firstMatch(q);
    final requested = match == null ? null : int.tryParse(match.group(1)!);

    if (requested != null && requested >= 1 && requested <= solution.steps.length) {
      final step = solution.steps[requested - 1];
      return 'Let’s go back to Step $requested.\n\n${step.body}\n\nWhy we do it:\n${step.why}\n\nTell me the exact word, number, or operation that is still confusing.';
    }

    if (q.contains('another') || q.contains('example')) {
      return 'Here is another example using the same idea:\n\n${solution.example}\n\nTry it yourself, then tell me where you get stuck.';
    }

    if (q.contains('why') || q.contains('how') || q.contains('understand') || q.contains('stuck')) {
      final step = solution.steps.isEmpty ? null : solution.steps.first;
      if (step != null) {
        return 'Let’s slow it down.\n\n${step.body}\n\nWhy:\n${step.why}\n\nIf that is not the part you mean, tell me the exact number or step where you are stuck.';
      }
    }

    return 'I am following your question. Tell me the exact step, word, number, or idea you want me to explain, and I will break that part down for you.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text('Ask TutorAI'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'New chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _currentSolution = null;
                _controller.clear();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const _AskTutorEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _AskTutorBubble(message: message);
                      },
                    ),
            ),
            if (_sending)
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'TutorAI is thinking...',
                        style: TextStyle(
                          color: Color(0xFF5E6D81),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1422446B),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about your schoolwork...',
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Color(0xFFDDE6F2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 52,
                    width: 52,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _send,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Icon(Icons.send_rounded),
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

class _AskTutorEmptyState extends StatelessWidget {
  const _AskTutorEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 128,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE7EEFF), Color(0xFFF1E8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x222563EB),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/tutor_ai_hero.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D6CDF), Color(0xFF8E5CFF)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 9, color: Color(0xFF31B979)),
                SizedBox(width: 6),
                Text(
                  'AI Tutor is ready',
                  style: TextStyle(
                    color: Color(0xFF2B775D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Your AI Tutor is ready',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: Color(0xFF14213D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask a school question, ask why a step works, or tell TutorAI exactly where you are stuck.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFF5E6D81),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                _AskTutorPromptChip(label: 'Explain photosynthesis'),
                _AskTutorPromptChip(label: 'Help me with fractions'),
                _AskTutorPromptChip(label: 'Give me a JAMB question'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AskTutorPromptChip extends StatelessWidget {
  final String label;
  const _AskTutorPromptChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2759A8),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AskTutorBubble extends StatelessWidget {
  final _AskTutorMessage message;
  const _AskTutorBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.fromUser ? const Color(0xFF2563EB) : Colors.white;
    final textColor = message.fromUser ? Colors.white : const Color(0xFF24334B);
    final alignment = message.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.84,
          ),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(message.fromUser ? 18 : 5),
              bottomRight: Radius.circular(message.fromUser ? 5 : 18),
            ),
            border: message.fromUser
                ? null
                : Border.all(color: const Color(0xFFE0E8F3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1022446B),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: textColor,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class SnapQuestionScreen extends StatefulWidget {
  const SnapQuestionScreen({super.key});

  @override
  State<SnapQuestionScreen> createState() => _SnapQuestionScreenState();
}

class _SnapQuestionScreenState extends State<SnapQuestionScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _choosePictureSource() async {
    if (_busy) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DCE8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choose a picture source',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF14213D)),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE2EEFF),
                  child: Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                ),
                title: const Text('Take a Picture', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Use your phone camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFECE6FF),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF7C3AED)),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Select an existing picture'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    await _pickPicture(source);
  }

  Future<void> _pickPicture(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 88);
      if (!mounted) return;
      setState(() => _busy = false);
      if (image != null) {
        _openQuestionComposer(image: image);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(source == ImageSource.camera
            ? 'We could not open the camera. Please try again.'
            : 'We could not open the gallery. Please try again.')),
      );
    }
  }

  void _openQuestionComposer({XFile? image}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionComposerScreen(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: const Text('Snap a Question'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          children: [
            const Text(
              'How would you like to ask?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Color(0xFF14213D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take a picture of your question or type it yourself. TutorAI will explain it step-by-step.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF5E6D81),
              ),
            ),
            const SizedBox(height: 24),
            _QuestionChoiceCard(
              icon: Icons.camera_alt_rounded,
              title: 'Take a Picture',
              subtitle: 'Photograph a homework question, worksheet, or textbook problem.',
              iconBackground: const Color(0xFFE2EEFF),
              iconColor: const Color(0xFF2563EB),
              onTap: _busy ? null : _choosePictureSource,
              busy: _busy,
            ),
            const SizedBox(height: 16),
            _QuestionChoiceCard(
              icon: Icons.keyboard_rounded,
              title: 'Type Your Question',
              subtitle: 'Type a maths, science, English, or any other school question.',
              iconBackground: const Color(0xFFF0E8FF),
              iconColor: const Color(0xFF7C3AED),
              onTap: _busy ? null : () => _openQuestionComposer(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE1E8F4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'TutorAI will identify the question type and teach the solution instead of only giving the answer.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Color(0xFF53637A),
                      ),
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

class _QuestionChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool busy;

  const _QuestionChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDDE6F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1422446B),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: busy && title == 'Take a Picture'
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Icon(icon, color: iconColor, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF14213D),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF5E6D81),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF91A1B8),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionComposerScreen extends StatefulWidget {
  final XFile? image;
  const QuestionComposerScreen({super.key, this.image});

  @override
  State<QuestionComposerScreen> createState() => _QuestionComposerScreenState();
}

class _QuestionComposerScreenState extends State<QuestionComposerScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _analyzing = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type your question before continuing.')),
      );
      return;
    }
    setState(() => _analyzing = true);
    final solution = await solveTutorQuestionWithBackend(question);
    if (!mounted) return;
    setState(() => _analyzing = false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuestionResultScreen(solution: solution)),
    );
  }

  Widget _imagePreview() {
    if (widget.image == null) {
      return Container(
        height: 92,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_rounded, size: 30, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text(
              'Type your question below',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF31557F),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: kIsWeb
            ? Image.network(widget.image!.path, fit: BoxFit.contain)
            : Image.file(File(widget.image!.path), fit: BoxFit.contain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromPhoto = widget.image != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(fromPhoto ? 'Check Your Question' : 'Type Your Question'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
        children: [
          _imagePreview(),
          const SizedBox(height: 18),
          Text(
            fromPhoto ? 'Confirm the question' : 'What would you like to learn?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fromPhoto
                ? 'Type the question you want TutorAI to solve from the picture.'
                : 'Type any school question below. TutorAI will identify the topic and teach it step-by-step.',
            style: const TextStyle(
              color: Color(0xFF5E6D81),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _questionController,
            autofocus: !fromPhoto,
            minLines: 4,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Example: 12.5 + 3.75 = ?',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFDDE6F2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _analyzing ? null : _analyze,
              icon: _analyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_analyzing ? 'Analyzing...' : 'Teach Me Step-by-Step'),
            ),
          ),
        ],
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// TUTORAI BACKEND BRIDGE
// ---------------------------------------------------------------------------
// The app keeps the deterministic local engine as its safety/fallback layer.
// When TUTORAI_BACKEND_URL is supplied at build time, TutorAI asks the secure
// backend first. The backend is responsible for the AI provider key, so no
// provider secret is stored in the mobile application.
//
// Build example:
// flutter run --dart-define=TUTORAI_BACKEND_URL=https://your-backend.example.com
// ---------------------------------------------------------------------------

const String _tutorAiBackendUrl = String.fromEnvironment(
  'TUTORAI_BACKEND_URL',
  defaultValue: '',
);

class TutorAcademicContext {
  final String academicLevel;
  final String examTarget;
  final String subject;
  final String teachingMode;
  final String difficulty;

  const TutorAcademicContext({
    this.academicLevel = 'Auto Detect',
    this.examTarget = 'None',
    this.subject = 'Auto Detect',
    this.teachingMode = 'Teacher Mode',
    this.difficulty = 'Auto Detect',
  });

  Map<String, dynamic> toJson() => {
        'academicLevel': academicLevel,
        'examTarget': examTarget,
        'subject': subject,
        'teachingMode': teachingMode,
        'difficulty': difficulty,
      };
}

class TutorBackendClient {
  const TutorBackendClient();

  bool get isConfigured => _tutorAiBackendUrl.trim().isNotEmpty;

  Uri _uri(String path) {
    final base = _tutorAiBackendUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$base$path');
  }

  Future<TutorSolution?> solve({
    required String question,
    required TutorAcademicContext context,
    TutorSolution? localVerification,
  }) async {
    if (!isConfigured) return null;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    client.idleTimeout = const Duration(seconds: 15);

    try {
      final request = await client.postUrl(_uri('/v1/tutor')).timeout(
        const Duration(seconds: 10),
      );
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode({
        'question': question,
        'academicContext': context.toJson(),
        'localVerification': localVerification == null
            ? null
            : {
                'topic': localVerification.topic,
                'answer': localVerification.answer,
                'supported': localVerification.supported,
              },
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final body = await utf8.decoder.bind(response).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return _solutionFromBackend(decoded);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<String?> askStandaloneChat({
    required String question,
    required TutorAcademicContext context,
    required List<String> conversation,
  }) async {
    if (!isConfigured) {
      debugPrint('TutorAI CHAT ERROR: backend URL is not configured.');
      return null;
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    client.idleTimeout = const Duration(seconds: 15);

    try {
      final uri = _uri('/v1/tutor/chat');
      debugPrint('TutorAI CHAT: POST $uri');

      final request = await client.postUrl(uri).timeout(
        const Duration(seconds: 10),
      );
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode({
        'question': question,
        'academicContext': context.toJson(),
        'conversation': conversation,
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final body = await utf8.decoder.bind(response).join();
      debugPrint('TutorAI CHAT: HTTP ${response.statusCode}');
      debugPrint('TutorAI CHAT RESPONSE: $body');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'TutorAI CHAT ERROR: backend returned HTTP ${response.statusCode}',
        );
        return null;
      }

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final reply = decoded['reply'];
        if (reply is String && reply.trim().isNotEmpty) {
          debugPrint('TutorAI CHAT: real AI reply received.');
          return reply.trim();
        }
      }

      debugPrint(
        'TutorAI CHAT ERROR: response did not contain a usable reply.',
      );
      return null;
    } catch (error, stackTrace) {
      debugPrint('TutorAI CHAT CONNECTION ERROR: $error');
      debugPrint('TutorAI CHAT STACK TRACE: $stackTrace');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<String?> askFollowUp({
    required String question,
    required TutorSolution solution,
    required TutorAcademicContext context,
    required List<String> conversation,
  }) async {
    if (!isConfigured) return null;

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    client.idleTimeout = const Duration(seconds: 15);

    try {
      final request = await client.postUrl(_uri('/v1/tutor/follow-up')).timeout(
        const Duration(seconds: 10),
      );
      request.headers.contentType = ContentType.json;
      request.headers.set('Accept', 'application/json');
      request.write(jsonEncode({
        'question': question,
        'academicContext': context.toJson(),
        'lesson': {
          'question': solution.question,
          'topic': solution.topic,
          'answer': solution.answer,
          'methodSummary': solution.methodSummary,
          'steps': solution.steps
              .map((step) => {
                    'title': step.title,
                    'body': step.body,
                    'why': step.why,
                  })
              .toList(),
        },
        'conversation': conversation,
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final reply = decoded['reply'];
        if (reply is String && reply.trim().isNotEmpty) return reply.trim();
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  TutorSolution? _solutionFromBackend(Map<String, dynamic> root) {
    final payload = root['solution'] is Map
        ? Map<String, dynamic>.from(root['solution'] as Map)
        : root;

    final question = payload['question'];
    final topic = payload['topic'];
    final answer = payload['answer'];
    final methodSummary = payload['methodSummary'];
    final example = payload['example'];
    final supported = payload['supported'];
    final rawSteps = payload['steps'];

    if (question is! String ||
        topic is! String ||
        answer is! String ||
        methodSummary is! String ||
        example is! String ||
        supported is! bool ||
        rawSteps is! List) {
      return null;
    }

    final steps = <TutorStepData>[];
    for (final item in rawSteps) {
      if (item is! Map) return null;
      final map = Map<String, dynamic>.from(item);
      final title = map['title'];
      final body = map['body'];
      final why = map['why'];
      if (title is! String || body is! String || why is! String) return null;
      steps.add(TutorStepData(title: title, body: body, why: why));
    }

    if (steps.isEmpty) return null;

    return TutorSolution(
      question: question,
      topic: topic,
      steps: steps,
      answer: answer,
      methodSummary: methodSummary,
      example: example,
      supported: supported,
    );
  }
}

const TutorBackendClient _tutorBackend = TutorBackendClient();
const TutorAcademicContext _defaultAcademicContext = TutorAcademicContext();

bool _looksLikeMathQuestion(String question) {
  final text = question.trim().toLowerCase();
  if (text.isEmpty) return false;

  // Clear mathematical structures should use the structured lesson endpoint.
  if (RegExp(r'\d').hasMatch(text) &&
      RegExp(r'[+\-*/%=]').hasMatch(text)) {
    return true;
  }

  const mathSignals = <String>[
    'solve for x',
    'solve for y',
    'find x',
    'find y',
    'simultaneous equation',
    'linear equation',
    'quadratic',
    'equation',
    'inequality',
    'fraction',
    'percentage',
    'ratio',
    'proportion',
    'mean',
    'average',
    'probability',
    'permutation',
    'combination',
    'algebra',
    'geometry',
    'trigonometry',
    'calculus',
    'derivative',
    'differentiate',
    'integral',
    'integration',
    'factorise',
    'factorize',
    'simplify',
    'calculate',
    'work out',
    'show that',
  ];

  return mathSignals.any(text.contains);
}

TutorSolution _generalLearningSolution(String question, String reply) {
  final cleanReply = reply.trim();
  return TutorSolution(
    question: question.trim(),
    topic: 'General Learning',
    steps: [
      TutorStepData(
        title: 'Explanation',
        body: cleanReply,
        why: 'TutorAI answers the exact subject and question the student asked, rather than forcing a mathematical method onto a non-mathematical question.',
      ),
    ],
    answer: cleanReply,
    methodSummary: 'TutorAI identified this as a general academic question and explained the topic directly at the student level.',
    example: 'Ask: "Can you give me a simple example?" for a related example.',
    supported: true,
  );
}

Future<TutorSolution> solveTutorQuestionWithBackend(String question) async {
  // General academic questions must not fall back to the local math-only engine.
  // They use the general TutorAI chat route, which supports subjects such as
  // biology, chemistry, physics, English, economics and history.
  if (!_looksLikeMathQuestion(question)) {
    final reply = await _tutorBackend.askStandaloneChat(
      question: question,
      context: _defaultAcademicContext,
      conversation: const <String>[],
    );
    if (reply != null && reply.trim().isNotEmpty) {
      return _generalLearningSolution(question, reply);
    }

    // Never show a mathematical lesson for a non-mathematical question when
    // the live AI service is unavailable.
    return _generalLearningSolution(
      question,
      'TutorAI could not reach the live AI tutor right now. Please check the connection and try the question again.',
    );
  }

  // Mathematical questions keep the structured lesson endpoint and its
  // deterministic local verification/fallback.
  final local = solveTutorQuestion(question);
  final remote = await _tutorBackend.solve(
    question: question,
    context: _defaultAcademicContext,
    localVerification: local.supported ? local : null,
  );
  return remote ?? local;
}

class TutorSolution {
  final String question;
  final String topic;
  final List<TutorStepData> steps;
  final String answer;
  final String methodSummary;
  final String example;
  final bool supported;

  const TutorSolution({
    required this.question,
    required this.topic,
    required this.steps,
    required this.answer,
    required this.methodSummary,
    required this.example,
    required this.supported,
  });
}

class TutorStepData {
  final String title;
  final String body;
  final String why;

  const TutorStepData({
    required this.title,
    required this.body,
    required this.why,
  });
}

class _SimpleFraction {
  final int numerator;
  final int denominator;

  const _SimpleFraction(int n, int d)
      : numerator = d < 0 ? -n : n,
        denominator = d < 0 ? -d : d;

  _SimpleFraction normalized() {
    final g = _gcd(numerator.abs(), denominator.abs());
    return _SimpleFraction(numerator ~/ g, denominator ~/ g);
  }

  double get value => numerator / denominator;

  String get display {
    final f = normalized();
    if (f.denominator == 1) return f.numerator.toString();
    return '${f.numerator}/${f.denominator}';
  }
}

int _gcd(int a, int b) {
  while (b != 0) {
    final t = a % b;
    a = b;
    b = t;
  }
  return a == 0 ? 1 : a.abs();
}

_SimpleFraction _fractionAdd(_SimpleFraction a, _SimpleFraction b) =>
    _SimpleFraction(a.numerator * b.denominator + b.numerator * a.denominator,
        a.denominator * b.denominator).normalized();

_SimpleFraction _fractionSubtract(_SimpleFraction a, _SimpleFraction b) =>
    _SimpleFraction(a.numerator * b.denominator - b.numerator * a.denominator,
        a.denominator * b.denominator).normalized();

_SimpleFraction _fractionMultiply(_SimpleFraction a, _SimpleFraction b) =>
    _SimpleFraction(a.numerator * b.numerator, a.denominator * b.denominator)
        .normalized();

_SimpleFraction _fractionDivide(_SimpleFraction a, _SimpleFraction b) =>
    _SimpleFraction(a.numerator * b.denominator, a.denominator * b.numerator)
        .normalized();

_SimpleFraction? _parseFraction(String text) {
  final m = RegExp(r'^\s*(-?\d+)\s*/\s*(\d+)\s*$').firstMatch(text);
  if (m == null) return null;
  final denominator = int.parse(m.group(2)!);
  if (denominator == 0) return null;
  return _SimpleFraction(int.parse(m.group(1)!), denominator).normalized();
}

String _normalizeQuestion(String raw) {
  var q = raw.trim();
  q = q.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');
  q = q.replaceAll(RegExp(r'\s+'), ' ');
  q = q.replaceAll(RegExp(r'^(what is|calculate|solve|find|work out|please calculate)\s+', caseSensitive: false), '');
  q = q.replaceAll(RegExp(r'\?+$'), '').trim();
  q = q.replaceAllMapped(
    RegExp(r'(?<=\d)\s+(?=\d(?:\s*[+\-*/]\s*|$))'),
    (_) => '.',
  );
  final replacements = <String, String>{
    r'\bplus\b': '+',
    r'\badd(?:ed|ing)?\b': '+',
    r'\bminus\b': '-',
    r'\bsubtract(?:ed|ing)?\b': '-',
    r'\btimes\b': '*',
    r'\bmultipl(?:y|ied|ication)\b': '*',
    r'\bdivided by\b': '/',
    r'\bdivide by\b': '/',
    r'\bpercent\b': '%',
  };
  replacements.forEach((pattern, replacement) {
    q = q.replaceAll(RegExp(pattern, caseSensitive: false), replacement);
  });
  return q.trim();
}


class _AdvancedExpressionResult {
  final double value;
  final List<String> steps;

  const _AdvancedExpressionResult({
    required this.value,
    required this.steps,
  });
}

List<String> _tokenizeMathExpression(String expression) {
  final compact = expression.replaceAll(RegExp(r'\s+'), '');
  final tokens = <String>[];
  var i = 0;
  var expectValue = true;

  while (i < compact.length) {
    final char = compact[i];
    if (RegExp(r'\d|\.',).hasMatch(char)) {
      var j = i;
      var dots = 0;
      while (j < compact.length && RegExp(r'\d|\.').hasMatch(compact[j])) {
        if (compact[j] == '.') dots++;
        j++;
      }
      if (dots > 1) return const [];
      tokens.add(compact.substring(i, j));
      i = j;
      expectValue = false;
      continue;
    }

    if ('+-*/()'.contains(char)) {
      // Convert unary minus into 0 - value so the parser stays simple.
      if ((char == '-' || char == '+') && expectValue) {
        tokens.add('0');
        tokens.add(char);
      } else {
        tokens.add(char);
      }
      i++;
      expectValue = char != ')';
      continue;
    }

    return const [];
  }
  return tokens;
}

double _operatorPrecedence(String op) {
  if (op == '+' || op == '-') return 1;
  if (op == '*' || op == '/') return 2;
  return 0;
}

_AdvancedExpressionResult? _evaluateAdvancedExpression(String expression) {
  final tokens = _tokenizeMathExpression(expression);
  if (tokens.isEmpty) return null;
  final values = <double>[];
  final ops = <String>[];
  final working = <String>[];

  void applyTop() {
    final op = ops.removeLast();
    if (values.length < 2) return;
    final right = values.removeLast();
    final left = values.removeLast();
    double result;
    switch (op) {
      case '+':
        result = left + right;
        break;
      case '-':
        result = left - right;
        break;
      case '*':
        result = left * right;
        break;
      case '/':
        if (right == 0) {
          values
            ..add(left)
            ..add(right);
          return;
        }
        result = left / right;
        break;
      default:
        return;
    }
    values.add(result);
    working.add(
      '${_formatNumber(left)} $op ${_formatNumber(right)} = ${_formatNumber(result)}',
    );
  }

  for (final token in tokens) {
    final number = double.tryParse(token);
    if (number != null) {
      values.add(number);
      continue;
    }
    if (token == '(') {
      ops.add(token);
      continue;
    }
    if (token == ')') {
      while (ops.isNotEmpty && ops.last != '(') {
        applyTop();
      }
      if (ops.isEmpty || ops.last != '(') return null;
      ops.removeLast();
      continue;
    }

    while (ops.isNotEmpty &&
        ops.last != '(' &&
        _operatorPrecedence(ops.last) >= _operatorPrecedence(token)) {
      final before = values.length;
      applyTop();
      if (values.length != before - 1) return null;
    }
    ops.add(token);
  }

  while (ops.isNotEmpty) {
    if (ops.last == '(') return null;
    final before = values.length;
    applyTop();
    if (values.length != before - 1) return null;
  }

  if (values.length != 1 || !values.single.isFinite) return null;
  return _AdvancedExpressionResult(value: values.single, steps: working);
}

TutorSolution _unsupportedSolution(String cleaned) {
  return TutorSolution(
    question: cleaned,
    topic: 'Question Understanding',
    steps: const [
      TutorStepData(
        title: 'Read the question carefully',
        body: 'TutorAI needs the exact wording or a supported mathematical structure before it can teach the solution accurately.',
        why: 'A good tutor should never invent a method when the question is unclear. Accurate teaching starts with understanding exactly what the student was asked.',
      ),
      TutorStepData(
        title: 'Give the question in a clear format',
        body: 'Examples:\n\n12.5 + 3.75\n2(4 + 3)\n1/2 + 1/4\n25% of 80\n2x + 5 = 15\naverage of 12, 18, 20',
        why: 'A clear mathematical structure lets TutorAI identify the method, show the working, and explain why each step is valid.',
      ),
    ],
    answer: 'Need a clearer or currently unsupported question',
    methodSummary: 'TutorAI will only present a worked solution when it can identify the mathematical structure reliably.',
    example: 'Try: 12.5 + 3.75',
    supported: false,
  );
}


// ---------------------------------------------------------------------------
// ADVANCED PEDAGOGICAL ENGINE
// ---------------------------------------------------------------------------

class _ParsedMixedNumber {
  final int whole;
  final int numerator;
  final int denominator;

  const _ParsedMixedNumber(this.whole, this.numerator, this.denominator);

  double get value => whole + numerator / denominator;

  String get display {
    if (numerator == 0) return whole.toString();
    return '$whole $numerator/$denominator';
  }
}

_ParsedMixedNumber? _parseMixedNumber(String text) {
  final m = RegExp(r'^\s*(-?\d+)\s+(\d+)\s*/\s*(\d+)\s*$').firstMatch(text);
  if (m == null) return null;
  final d = int.parse(m.group(3)!);
  if (d == 0) return null;
  return _ParsedMixedNumber(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    d,
  );
}

_SimpleFraction _mixedToImproper(_ParsedMixedNumber n) {
  final sign = n.whole < 0 ? -1 : 1;
  final wholeAbs = n.whole.abs();
  return _SimpleFraction(
    sign * (wholeAbs * n.denominator + n.numerator),
    n.denominator,
  ).normalized();
}

String _explainDifficulty(String topic, int level) {
  if (level <= 1) return 'Foundation';
  if (level == 2) return 'Developing';
  if (level == 3) return 'Secure';
  return 'Challenge';
}

TutorSolution? _advancedTutorPatterns(String cleaned, String expression) {
  final lower = expression.toLowerCase().trim();

  // Mixed-number arithmetic: 1 1/2 + 2 1/4.
  final mixed = RegExp(
    r'^\s*(-?\d+\s+\d+\s*/\s*\d+)\s*([+\-*/])\s*(-?\d+\s+\d+\s*/\s*\d+)\s*$',
  ).firstMatch(expression);
  if (mixed != null) {
    final a = _parseMixedNumber(mixed.group(1)!);
    final b = _parseMixedNumber(mixed.group(3)!);
    final op = mixed.group(2)!;
    if (a != null && b != null && (op != '/' || b.value != 0)) {
      final af = _mixedToImproper(a);
      final bf = _mixedToImproper(b);
      final result = switch (op) {
        '+' => _fractionAdd(af, bf),
        '-' => _fractionSubtract(af, bf),
        '*' => _fractionMultiply(af, bf),
        '/' => _fractionDivide(af, bf),
        _ => _SimpleFraction(0, 1),
      };
      return TutorSolution(
        question: cleaned,
        topic: 'Mixed Number ${op == '+' ? 'Addition' : op == '-' ? 'Subtraction' : op == '*' ? 'Multiplication' : 'Division'}',
        steps: [
          TutorStepData(
            title: 'Understand the mixed numbers',
            body: '${a.display} and ${b.display} each contain a whole-number part and a fractional part.',
            why: 'A mixed number combines whole units with part of another unit. Converting to improper fractions lets us use one consistent fraction rule.',
          ),
          TutorStepData(
            title: 'Convert to improper fractions',
            body: '${a.display} = ${af.display}\n${b.display} = ${bf.display}\n\nFor a mixed number, multiply the whole number by the denominator, add the numerator, then keep the same denominator.',
            why: 'This preserves the value while turning the mixed number into a single fraction that is easier to operate on.',
          ),
          TutorStepData(
            title: 'Perform the fraction operation',
            body: '${af.display} ${op == '/' ? '÷' : op} ${bf.display} = ${result.display}.',
            why: 'Now the problem follows the normal fraction operation rule for $op.',
          ),
          TutorStepData(
            title: 'Interpret the result',
            body: 'The simplified answer is ${result.display}.',
            why: 'Reducing the fraction gives the student the cleanest exact form of the result.',
          ),
        ],
        answer: result.display,
        methodSummary: 'Convert mixed numbers to improper fractions, apply the fraction operation, simplify, then interpret the result.',
        example: '1 1/2 + 2 1/4 = 3 3/4',
        supported: true,
      );
    }
  }

  // Exponents: 2^3, 5 squared, etc.
  final exponent = RegExp(
    r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*(?:\^|to the power of)\s*(\d+)\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (exponent != null) {
    final baseText = exponent.group(1)!;
    final power = int.parse(exponent.group(2)!);
    final base = double.parse(baseText);
    final value = math.pow(base, power).toDouble();
    final repeated = List.filled(power, baseText).join(' × ');
    return TutorSolution(
      question: cleaned,
      topic: 'Exponents and Powers',
      steps: [
        TutorStepData(
          title: 'Identify the base and exponent',
          body: 'Base = $baseText\nExponent = $power',
          why: 'The base is the number being multiplied, while the exponent tells us how many times the base is used as a factor.',
        ),
        TutorStepData(
          title: 'Rewrite as repeated multiplication',
          body: '$baseText^$power = $repeated',
          why: 'An exponent is shorthand for repeated multiplication of the same base.',
        ),
        TutorStepData(
          title: 'Multiply step-by-step',
          body: _formatNumber(base) == baseText
              ? '${_formatNumber(value)} is the result of multiplying the $power factors.'
              : '$repeated = ${_formatNumber(value)}',
          why: 'Each multiplication builds the next power while preserving the exact value.',
        ),
        TutorStepData(
          title: 'Check the size',
          body: 'The exact answer is ${_formatNumber(value)}.',
          why: 'For a positive base greater than 1, increasing the exponent should make the result grow quickly.',
        ),
      ],
      answer: _formatNumber(value),
      methodSummary: 'Identify base and exponent, expand the power into repeated multiplication, calculate, then check the size.',
      example: '3^2 = 9',
      supported: true,
    );
  }

  // Square roots: sqrt 49 / square root of 81.
  final root = RegExp(
    r'^\s*(?:sqrt|square\s+root\s+of)\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (root != null) {
    final radicand = double.parse(root.group(1)!);
    if (radicand < 0) {
      return TutorSolution(
        question: cleaned,
        topic: 'Square Roots',
        steps: const [
          TutorStepData(
            title: 'Check the number inside the root',
            body: 'The principal square root of a negative number is not a real number.',
            why: 'A real number squared is never negative, so no real number can square to a negative value.',
          ),
        ],
        answer: 'No real solution',
        methodSummary: 'For a real square root, the number under the radical must be non-negative.',
        example: 'sqrt 49 = 7',
        supported: true,
      );
    }
    final value = math.sqrt(radicand);
    final rounded = value.roundToDouble();
    final exactSquare = (rounded * rounded - radicand).abs() < 1e-9;
    return TutorSolution(
      question: cleaned,
      topic: 'Square Roots',
      steps: [
        TutorStepData(
          title: 'Understand the question',
          body: 'We are looking for a number that multiplies by itself to make $rootTextFor(radicand).',
          why: 'A square root reverses squaring: √n asks which number has square n.',
        ),
        TutorStepData(
          title: 'Find the matching square',
          body: exactSquare
              ? '${rounded.toInt()} × ${rounded.toInt()} = ${_formatNumber(radicand)}'
              : '√${_formatNumber(radicand)} ≈ ${_formatNumber(value)}',
          why: 'The answer is the number whose square is the value under the root.',
        ),
        TutorStepData(
          title: 'Check by squaring',
          body: '${_formatNumber(value)} × ${_formatNumber(value)} ≈ ${_formatNumber(value * value)}.',
          why: 'Squaring the result should return the original radicand, allowing a direct inverse-operation check.',
        ),
      ],
      answer: _formatNumber(value),
      methodSummary: 'Find the number whose square equals the radicand, then verify by squaring the result.',
      example: 'sqrt 64 = 8',
      supported: true,
    );
  }

  // Greatest common factor / lowest common multiple.
  final gcdMatch = RegExp(
    r'^\s*(?:gcf|greatest\s+common\s+factor|gcd)\s+of\s+(-?\d+)\s*(?:and|,)\s*(-?\d+)\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (gcdMatch != null) {
    final a = int.parse(gcdMatch.group(1)!).abs();
    final b = int.parse(gcdMatch.group(2)!).abs();
    var x = a;
    var y = b;
    while (y != 0) {
      final t = x % y;
      x = y;
      y = t;
    }
    final g = x;
    return TutorSolution(
      question: cleaned,
      topic: 'Greatest Common Factor',
      steps: [
        TutorStepData(
          title: 'Understand GCF',
          body: 'We want the largest whole number that divides both $a and $b with no remainder.',
          why: 'The word “common” means it works for both numbers, and “greatest” means we choose the largest such factor.',
        ),
        TutorStepData(
          title: 'Use the remainder process',
          body: 'Apply the Euclidean algorithm to repeatedly replace the larger number with the remainder until the remainder is 0.\n\nGCF = $g.',
          why: 'Common factors are preserved through the remainder process, so the last non-zero remainder is the greatest common factor.',
        ),
        TutorStepData(
          title: 'Check the factors',
          body: '$g divides $a and $b exactly.',
          why: 'A final factor check confirms that the result is common to both numbers.',
        ),
      ],
      answer: g.toString(),
      methodSummary: 'Use the Euclidean algorithm and verify that the final factor divides both numbers.',
      example: 'GCF of 18 and 24 = 6',
      supported: true,
    );
  }

  final lcmMatch = RegExp(
    r'^\s*(?:lcm|least\s+common\s+multiple)\s+of\s+(-?\d+)\s*(?:and|,)\s*(-?\d+)\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (lcmMatch != null) {
    final a = int.parse(lcmMatch.group(1)!).abs();
    final b = int.parse(lcmMatch.group(2)!).abs();
    if (a != 0 && b != 0) {
      var x = a;
      var y = b;
      while (y != 0) {
        final t = x % y;
        x = y;
        y = t;
      }
      final g = x;
      final lcm = (a ~/ g) * b;
      return TutorSolution(
        question: cleaned,
        topic: 'Least Common Multiple',
        steps: [
          TutorStepData(
            title: 'Understand LCM',
            body: 'We want the smallest positive number that both $a and $b divide exactly.',
            why: 'A common multiple is a shared landing point in the multiples of both numbers.',
          ),
          TutorStepData(
            title: 'Find the common multiple efficiently',
            body: 'Use LCM(a,b) = (a × b) ÷ GCF(a,b).\nGCF($a,$b) = $g.\nSo LCM = ($a × $b) ÷ $g = $lcm.',
            why: 'Dividing by the GCF removes the shared factor that would otherwise be counted twice.',
          ),
          TutorStepData(
            title: 'Check the answer',
            body: '$a × ${lcm ~/ a} = $lcm and $b × ${lcm ~/ b} = $lcm.',
            why: 'Both original numbers must divide the LCM exactly, and no smaller positive common multiple should exist.',
          ),
        ],
        answer: lcm.toString(),
        methodSummary: 'Find the GCF, use LCM = (a × b) ÷ GCF, then verify both numbers divide the result.',
        example: 'LCM of 6 and 8 = 24',
        supported: true,
      );
    }
  }

  // Linear equation with x on both sides: 2x + 5 = x + 12.
  final twoSideEq = RegExp(
    r'^\s*(-?\d*\.?\d*)x\s*([+\-])\s*(-?\d+(?:\.\d+)?)\s*=\s*(-?\d*\.?\d*)x\s*([+\-])\s*(-?\d+(?:\.\d+)?)\s*$',
    caseSensitive: false,
  ).firstMatch(expression.replaceAll(' ', ''));
  if (twoSideEq != null) {
    final aRaw = twoSideEq.group(1)!;
    final bRaw = twoSideEq.group(3)!;
    final cRaw = twoSideEq.group(4)!;
    final dRaw = twoSideEq.group(6)!;
    final a = aRaw.isEmpty || aRaw == '+' ? 1.0 : aRaw == '-' ? -1.0 : double.parse(aRaw);
    final bValue = double.parse(bRaw);
    final b = twoSideEq.group(2)! == '+' ? bValue : -bValue;
    final c = cRaw.isEmpty || cRaw == '+' ? 1.0 : cRaw == '-' ? -1.0 : double.parse(cRaw);
    final dValue = double.parse(dRaw);
    final dSign = twoSideEq.group(5)!;
    final d = dSign == '+' ? dValue : -dValue;
    final combined = a - c;
    final target = d - b;
    if (combined.abs() > 1e-12) {
      final x = target / combined;
      final xText = _formatNumber(x);
      return TutorSolution(
        question: cleaned,
        topic: 'Multi-step Algebra',
        steps: [
          TutorStepData(
            title: 'Understand the balance',
            body: '$a x${b >= 0 ? ' + ' : ' - '}${_formatNumber(b.abs())} = $c x${d >= 0 ? ' + ' : ' - '}${_formatNumber(d.abs())}',
            why: 'Both sides of an equation have the same value, so every operation must preserve that equality.',
          ),
          TutorStepData(
            title: 'Collect the x terms',
            body: 'Subtract ${_formatNumber(c)}x from both sides:\n${_formatNumber(combined)}x${b >= 0 ? ' + ' : ' - '}${_formatNumber(b.abs())} = ${_formatNumber(d)}.',
            why: 'Putting all x terms on one side makes the unknown easier to isolate.',
          ),
          TutorStepData(
            title: 'Move the constant terms',
            body: 'Subtract ${_formatNumber(b)} from both sides:\n${_formatNumber(combined)}x = ${_formatNumber(target)}.',
            why: 'Removing the constant leaves only the x term and its coefficient.',
          ),
          TutorStepData(
            title: 'Divide by the coefficient',
            body: 'x = ${_formatNumber(target)} ÷ ${_formatNumber(combined)} = $xText.',
            why: 'Division undoes multiplication by the coefficient, leaving x by itself.',
          ),
          TutorStepData(
            title: 'Check by substitution',
            body: 'Substitute x = $xText into both original sides and confirm they are equal.',
            why: 'Substitution verifies that the solution works in the original equation, not just the transformed equation.',
          ),
        ],
        answer: 'x = $xText',
        methodSummary: 'Collect x terms, collect constants, isolate x, then verify by substitution.',
        example: '2x + 5 = x + 12 → x = 7',
        supported: true,
      );
    }
  }

  // Geometry: rectangle, square, triangle and circle.
  final rect = RegExp(
    r'^\s*(?:area\s+of\s+)?(?:a\s+)?rectangle\s+(?:with\s+)?(?:length\s+)?(-?(?:\d+(?:\.\d+)?|\.\d+))\s*(?:and|by|x|×)\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (rect != null) {
    final l = double.parse(rect.group(1)!);
    final w = double.parse(rect.group(2)!);
    final area = l * w;
    final perimeter = 2 * (l + w);
    return TutorSolution(
      question: cleaned,
      topic: 'Rectangle Geometry',
      steps: [
        TutorStepData(
          title: 'Identify the measurements',
          body: 'Length = ${_formatNumber(l)}\nWidth = ${_formatNumber(w)}',
          why: 'A rectangle is defined by its length and width.',
        ),
        TutorStepData(
          title: 'Use the area formula',
          body: 'Area = length × width\n= ${_formatNumber(l)} × ${_formatNumber(w)}\n= ${_formatNumber(area)} square units.',
          why: 'A rectangle can be divided into rows of equal unit squares, so multiplying length by width counts the total squares.',
        ),
        TutorStepData(
          title: 'Know the related perimeter',
          body: 'Perimeter = 2(length + width) = ${_formatNumber(perimeter)} units.',
          why: 'Perimeter measures the distance around the rectangle, so both pairs of equal sides are included.',
        ),
        TutorStepData(
          title: 'Check the units',
          body: 'Area uses square units; perimeter uses ordinary units.',
          why: 'Units tell you whether you calculated a surface region or a boundary distance.',
        ),
      ],
      answer: _formatNumber(area),
      methodSummary: 'Multiply length by width for area, and use 2(length + width) for perimeter.',
      example: 'Rectangle 8 by 5 → area 40 square units',
      supported: true,
    );
  }

  final circle = RegExp(
    r'^\s*(?:area\s+of\s+)?(?:a\s+)?circle\s+(?:with\s+)?radius\s*(\d+(?:\.\d+)?)\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (circle != null) {
    final r = double.parse(circle.group(1)!);
    final area = math.pi * r * r;
    final circumference = 2 * math.pi * r;
    return TutorSolution(
      question: cleaned,
      topic: 'Circle Geometry',
      steps: [
        TutorStepData(
          title: 'Identify the radius',
          body: 'Radius = ${_formatNumber(r)}.',
          why: 'The radius is the distance from the centre of the circle to its edge.',
        ),
        TutorStepData(
          title: 'Use the area formula',
          body: 'Area = πr² = π × ${_formatNumber(r)} × ${_formatNumber(r)} ≈ ${_formatNumber(area)} square units.',
          why: 'The area formula πr² measures the surface enclosed by the circle.',
        ),
        TutorStepData(
          title: 'Related circumference check',
          body: 'Circumference = 2πr ≈ ${_formatNumber(circumference)} units.',
          why: 'This provides a related measurement around the boundary and helps keep the radius meaning clear.',
        ),
      ],
      answer: _formatNumber(area),
      methodSummary: 'Square the radius, multiply by π, then check the units. For circumference use 2πr.',
      example: 'Circle radius 7 → area ≈ 153.94 square units',
      supported: true,
    );
  }

  // Simple unit conversions: length and mass.
  final conversion = RegExp(
    r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*(mm|cm|m|km|g|kg)\s+(?:to|into|in)\s+(mm|cm|m|km|g|kg)\s*$',
    caseSensitive: false,
  ).firstMatch(lower);
  if (conversion != null) {
    final amount = double.parse(conversion.group(1)!);
    final from = conversion.group(2)!.toLowerCase();
    final to = conversion.group(3)!.toLowerCase();
    final lengthFactors = <String, double>{'mm': 0.001, 'cm': 0.01, 'm': 1, 'km': 1000};
    final massFactors = <String, double>{'g': 1, 'kg': 1000};
    final factors = lengthFactors.containsKey(from) && lengthFactors.containsKey(to)
        ? lengthFactors
        : massFactors.containsKey(from) && massFactors.containsKey(to)
            ? massFactors
            : null;
    if (factors != null) {
      final base = amount * factors[from]!;
      final result = base / factors[to]!;
      return TutorSolution(
        question: cleaned,
        topic: 'Unit Conversion',
        steps: [
          TutorStepData(
            title: 'Identify the units',
            body: '${_formatNumber(amount)} $from → $to',
            why: 'A conversion changes the unit label while keeping the physical quantity the same.',
          ),
          TutorStepData(
            title: 'Convert through a common base unit',
            body: '${_formatNumber(amount)} $from = ${_formatNumber(base)} ${factors == lengthFactors ? 'metres' : 'grams'}.',
            why: 'Using one common unit prevents mixing incompatible conversion steps.',
          ),
          TutorStepData(
            title: 'Convert to the requested unit',
            body: '${_formatNumber(base)} base units = ${_formatNumber(result)} $to.',
            why: 'The final conversion applies the scale between the base unit and the requested unit.',
          ),
          TutorStepData(
            title: 'Check the direction',
            body: 'Moving to a smaller unit makes the number larger; moving to a larger unit makes the number smaller.',
            why: 'This size check catches reversed conversion factors.',
          ),
        ],
        answer: '${_formatNumber(result)} $to',
        methodSummary: 'Convert to a common base unit, then convert from the base unit to the requested unit.',
        example: '2.5 m to cm = 250 cm',
        supported: true,
      );
    }
  }

  return null;
}

String rootTextFor(double value) => _formatNumber(value);


TutorSolution solveTutorQuestion(String question) {
  final cleaned = question.trim();
  final expression = _normalizeQuestion(cleaned).replaceAll(',', '');

  // Advanced local pedagogy layer. It is intentionally deterministic so the
  // tutor never invents a solution for a structure it does not understand.
  final advancedSolution = _advancedTutorPatterns(cleaned, expression);
  if (advancedSolution != null) return advancedSolution;

  // Percentage increase/decrease: increase 80 by 25%, decrease 80 by 25%.
  final changePercent = RegExp(
    r'^(?:increase|decrease)\s+(-?(?:\d+(?:\.\d+)?|\.\d+))\s+by\s+(-?(?:\d+(?:\.\d+)?|\.\d+))\s*%$',
    caseSensitive: false,
  ).firstMatch(expression);
  if (changePercent != null) {
    final baseText = changePercent.group(1)!;
    final pText = changePercent.group(2)!;
    final base = double.parse(baseText);
    final p = double.parse(pText);
    final delta = base * p / 100;
    final increase = expression.toLowerCase().startsWith('increase');
    final answer = increase ? base + delta : base - delta;
    final answerText = _formatNumber(answer);
    return TutorSolution(
      question: cleaned,
      topic: increase ? 'Percentage Increase' : 'Percentage Decrease',
      steps: [
        TutorStepData(
          title: 'Understand the change',
          body: 'Start with $baseText and change it by $pText%.',
          why: 'A percentage change describes how much the original amount is changed relative to the original amount.',
        ),
        TutorStepData(
          title: 'Find the percentage amount',
          body: '$pText% of $baseText = $pText ÷ 100 × $baseText = ${_formatNumber(delta)}.',
          why: 'We first calculate the size of the change itself. This is the amount that will be added or removed.',
        ),
        TutorStepData(
          title: increase ? 'Add the increase' : 'Subtract the decrease',
          body: increase
              ? '$baseText + ${_formatNumber(delta)} = $answerText.'
              : '$baseText - ${_formatNumber(delta)} = $answerText.',
          why: increase
              ? 'An increase makes the original amount larger, so we add the change.'
              : 'A decrease makes the original amount smaller, so we subtract the change.',
        ),
        TutorStepData(
          title: 'Check the direction',
          body: increase
              ? 'The answer $answerText is greater than $baseText, which matches an increase.'
              : 'The answer $answerText is less than $baseText, which matches a decrease.',
          why: 'Checking the direction catches the common mistake of adding when the question asked for a decrease, or subtracting when it asked for an increase.',
        ),
      ],
      answer: answerText,
      methodSummary: 'Find the percentage amount first, then add it for an increase or subtract it for a decrease, and finally check the direction.',
      example: increase ? '80 increased by 25% = 100' : '80 decreased by 25% = 60',
      supported: true,
    );
  }

  // Percentage relationship: "20 is what percent of 80?"
  final percentOf = RegExp(
    r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s+is\s+what\s+percent\s+of\s+(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$',
    caseSensitive: false,
  ).firstMatch(expression);
  if (percentOf != null) {
    final partText = percentOf.group(1)!;
    final wholeText = percentOf.group(2)!;
    final part = double.parse(partText);
    final whole = double.parse(wholeText);
    if (whole != 0) {
      final percentValue = part / whole * 100;
      final answerText = _formatNumber(percentValue);
      return TutorSolution(
        question: cleaned,
        topic: 'Percentage Relationship',
        steps: [
          TutorStepData(
            title: 'Identify the part and whole',
            body: '$partText is the part and $wholeText is the whole.',
            why: 'Percentage asks how large the part is compared with the whole, with the comparison expressed out of 100.',
          ),
          TutorStepData(
            title: 'Write the fraction',
            body: '$partText ÷ $wholeText = ${_formatNumber(part / whole)}.',
            why: 'Dividing part by whole tells us what fraction of the whole the part represents.',
          ),
          TutorStepData(
            title: 'Convert the fraction to a percentage',
            body: '${_formatNumber(part / whole)} × 100 = $answerText%.',
            why: 'Multiplying by 100 changes the fraction into the equivalent number of parts out of 100.',
          ),
          TutorStepData(
            title: 'Check the answer',
            body: '$answerText% of $wholeText equals $partText.',
            why: 'Reversing the calculation is a direct check that the percentage is consistent with the original numbers.',
          ),
        ],
        answer: '$answerText%',
        methodSummary: 'Divide the part by the whole, then multiply by 100 to express the relationship as a percentage.',
        example: '20 is what percent of 80? → 25%',
        supported: true,
      );
    }
  }

  // Average / mean.
  final average = RegExp(
    r'^(?:average|mean)\s+(?:of\s+)?(.+)$',
    caseSensitive: false,
  ).firstMatch(cleaned.replaceAll('?', '').trim());
  if (average != null) {
    final values = average.group(1)!
        .split(RegExp(r'\s*,\s*|\s+and\s+'))
        .map((v) => double.tryParse(v.trim()))
        .toList();
    if (values.isNotEmpty && values.every((v) => v != null)) {
      final nums = values.cast<double>();
      final sum = nums.fold<double>(0, (a, b) => a + b);
      final result = sum / nums.length;
      final resultText = _formatNumber(result);
      return TutorSolution(
        question: cleaned,
        topic: 'Average / Mean',
        steps: [
          TutorStepData(
            title: 'Identify the numbers',
            body: nums.map(_formatNumber).join(', '),
            why: 'The mean combines all the values into one total and then shares that total equally across the number of values.',
          ),
          TutorStepData(
            title: 'Add all the values',
            body: nums.map(_formatNumber).join(' + ') + ' = ${_formatNumber(sum)}.',
            why: 'The first step in finding a mean is to find the complete total represented by all the values.',
          ),
          TutorStepData(
            title: 'Count the values',
            body: 'There are ${nums.length} values.',
            why: 'The total must be shared equally among every value in the data set, so we divide by the count.',
          ),
          TutorStepData(
            title: 'Divide the total by the count',
            body: '${_formatNumber(sum)} ÷ ${nums.length} = $resultText.',
            why: 'Dividing the total equally gives the value that represents the center of the data set.',
          ),
        ],
        answer: resultText,
        methodSummary: 'Mean = total of all values ÷ number of values.',
        example: 'Average of 10, 20, 30 = 20',
        supported: true,
      );
    }
  }

  // Ratio / proportion: 2:3 = x:12 or 2:3 = 8:x.
  final proportion = RegExp(
    r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*:\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*=\s*(x|-?(?:\d+(?:\.\d+)?|\.\d+))\s*:\s*(x|-?(?:\d+(?:\.\d+)?|\.\d+))\s*$',
    caseSensitive: false,
  ).firstMatch(expression);
  if (proportion != null) {
    final a = double.parse(proportion.group(1)!);
    final b = double.parse(proportion.group(2)!);
    final cToken = proportion.group(3)!;
    final dToken = proportion.group(4)!;
    if ((cToken.toLowerCase() == 'x') ^ (dToken.toLowerCase() == 'x')) {
      late final double x;
      if (cToken.toLowerCase() == 'x') {
        final d = double.parse(dToken);
        x = a * d / b;
      } else {
        final c = double.parse(cToken);
        x = b * c / a;
      }
      final xText = _formatNumber(x);
      return TutorSolution(
        question: cleaned,
        topic: 'Ratio and Proportion',
        steps: [
          TutorStepData(
            title: 'Read the ratio relationship',
            body: '$a:$b = $cToken:$dToken.',
            why: 'A proportion says two ratios describe the same relationship.',
          ),
          TutorStepData(
            title: 'Use cross multiplication',
            body: '$a × $dToken = $b × $cToken.\nThen isolate x by dividing by the remaining known factor.\n\nx = $xText.',
            why: 'Cross multiplication creates two equal products. This lets us turn the ratio relationship into a simple equation that can be solved.',
          ),
          TutorStepData(
            title: 'Check the proportion',
            body: 'Substitute x = $xText back into the ratio and compare the two sides.',
            why: 'A proportion is correct only when both ratios represent the same multiplier.',
          ),
        ],
        answer: 'x = $xText',
        methodSummary: 'Use cross multiplication to turn the proportion into an equation, isolate x, and verify the ratio.',
        example: '2:3 = x:12 → x = 8',
        supported: true,
      );
    }
  }


  // Percentages: 25% of 80, what is 15% of 200, etc.
  final percent = RegExp(
    r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*%\s*(?:of)\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$',
    caseSensitive: false,
  ).firstMatch(expression);
  if (percent != null) {
    final pText = percent.group(1)!;
    final baseText = percent.group(2)!;
    final p = double.parse(pText);
    final base = double.parse(baseText);
    final answer = base * p / 100;
    final answerText = _formatNumber(answer);
    return TutorSolution(
      question: cleaned,
      topic: 'Percentage',
      steps: [
        TutorStepData(
          title: 'Understand the question',
          body: 'We need to find $pText% of $baseText.',
          why: 'The word “of” means we are taking that percentage of the whole amount.',
        ),
        TutorStepData(
          title: 'Convert the percent to a decimal',
          body: '$pText% = $pText ÷ 100 = ${_formatNumber(p / 100)}.',
          why: 'A percent means “out of 100”, so dividing by 100 changes the percentage into a decimal multiplier.',
        ),
        TutorStepData(
          title: 'Multiply by the whole amount',
          body: '${_formatNumber(p / 100)} × $baseText = $answerText.',
          why: 'Multiplying the whole amount by the decimal percentage finds exactly that fraction of the whole.',
        ),
        TutorStepData(
          title: 'Check the size',
          body: '$pText% of $baseText is $answerText. Because $pText% is less than 100%, the answer should be less than $baseText.',
          why: 'A quick size check helps catch a misplaced decimal or an incorrect percentage conversion.',
        ),
      ],
      answer: answerText,
      methodSummary: 'To find a percentage of a number: convert the percent to a decimal, multiply by the whole amount, then check whether the size makes sense.',
      example: '20% of 150 = 30',
      supported: true,
    );
  }

  // Fractions such as 1/2 + 1/4.
  final fractionExpr = RegExp(r'^\s*(-?\d+\s*/\s*\d+)\s*([+\-*/])\s*(-?\d+\s*/\s*\d+)\s*$').firstMatch(expression);
  if (fractionExpr != null) {
    final a = _parseFraction(fractionExpr.group(1)!);
    final b = _parseFraction(fractionExpr.group(3)!);
    final op = fractionExpr.group(2)!;
    if (a != null && b != null && !(op == '/' && b.numerator == 0)) {
      final result = switch (op) {
        '+' => _fractionAdd(a, b),
        '-' => _fractionSubtract(a, b),
        '*' => _fractionMultiply(a, b),
        '/' => _fractionDivide(a, b),
        _ => _SimpleFraction(0, 1),
      };
      final opName = switch (op) {
        '+' => 'addition',
        '-' => 'subtraction',
        '*' => 'multiplication',
        '/' => 'division',
        _ => 'calculation',
      };
      final commonDenominator = a.denominator * b.denominator;
      String working;
      if (op == '+') {
        final leftNumerator = a.numerator * b.denominator;
        final rightNumerator = b.numerator * a.denominator;
        working = '${a.display} + ${b.display}\n= $leftNumerator/$commonDenominator + $rightNumerator/$commonDenominator\n= ${(leftNumerator + rightNumerator)}/$commonDenominator\n= ${result.display}';
      } else if (op == '-') {
        final leftNumerator = a.numerator * b.denominator;
        final rightNumerator = b.numerator * a.denominator;
        working = '${a.display} - ${b.display}\n= $leftNumerator/$commonDenominator - $rightNumerator/$commonDenominator\n= ${(leftNumerator - rightNumerator)}/$commonDenominator\n= ${result.display}';
      } else if (op == '*') {
        working = '${a.display} × ${b.display}\n= ${a.numerator} × ${b.numerator} / (${a.denominator} × ${b.denominator})\n= ${result.display}';
      } else {
        working = '${a.display} ÷ ${b.display}\n= ${a.numerator}/${a.denominator} × ${b.denominator}/${b.numerator}\n= ${result.display}';
      }
      return TutorSolution(
        question: cleaned,
        topic: 'Fraction ${opName[0].toUpperCase()}${opName.substring(1)}',
        steps: [
          TutorStepData(
            title: 'Understand the fraction problem',
            body: 'We are using ${a.display} and ${b.display} with $op.',
            why: 'Fractions represent parts of a whole. The operation tells us how those parts must be combined or compared.',
          ),
          TutorStepData(
            title: op == '*' || op == '/' ? 'Use the fraction rule' : 'Make the denominators compatible',
            body: op == '*' || op == '/'
                ? working
                : 'For $opName, both fractions need the same denominator before we combine them. A common denominator is $commonDenominator.\n\n$working',
            why: op == '*' || op == '/'
                ? 'Multiplying combines numerator and denominator factors. Dividing by a fraction means multiplying by its reciprocal.'
                : 'You can only add or subtract equal-sized fractional pieces. A common denominator makes the pieces the same size.',
          ),
          TutorStepData(
            title: 'Simplify the result',
            body: '${result.numerator}/${result.denominator} simplifies to ${result.display}.',
            why: 'A fraction should be reduced when the numerator and denominator share a common factor so the answer is in simplest form.',
          ),
          TutorStepData(
            title: 'Check the answer',
            body: 'The final answer is ${result.display}. As a decimal it is ${_formatNumber(result.value)}.',
            why: 'The decimal form gives another way to check that the size of the answer is reasonable.',
          ),
        ],
        answer: result.display,
        methodSummary: op == '*' || op == '/'
            ? 'For fraction multiplication or division, use the operation rule, then reduce the answer to simplest form.'
            : 'For fraction addition or subtraction, use a common denominator, combine the numerators, then simplify.',
        example: op == '+' ? '1/2 + 1/4 = 3/4' : op == '-' ? '3/4 - 1/4 = 1/2' : op == '*' ? '2/3 × 3/4 = 1/2' : '1/2 ÷ 1/4 = 2',
        supported: true,
      );
    }
  }

  // Simple linear equations: ax + b = c and x + b = c.
  final equation = RegExp(
    r'^\s*(-?\d*\.?\d*)\s*x\s*([+\-])\s*(-?\d+(?:\.\d+)?)\s*=\s*(-?\d+(?:\.\d+)?)\s*$',
    caseSensitive: false,
  ).firstMatch(expression.replaceAll(' ', ''));
  if (equation != null) {
    final coefficientRaw = equation.group(1)!;
    final a = coefficientRaw.isEmpty || coefficientRaw == '+' ? 1.0 : coefficientRaw == '-' ? -1.0 : double.parse(coefficientRaw);
    final sign = equation.group(2)!;
    final bValue = double.parse(equation.group(3)!);
    final c = double.parse(equation.group(4)!);
    final b = sign == '+' ? bValue : -bValue;
    if (a != 0) {
      final isolateValue = c - b;
      final x = isolateValue / a;
      final xText = _formatNumber(x);
      final equationText = '$coefficientRaw' + 'x $sign $bValue = ${_formatNumber(c)}';
      return TutorSolution(
        question: cleaned,
        topic: 'Algebra',
        steps: [
          TutorStepData(
            title: 'Understand the equation',
            body: 'We want to find the value of x that makes $equationText true.',
            why: 'An equation is a balance. Whatever we do to one side must preserve that balance on the other side.',
          ),
          TutorStepData(
            title: 'Move the constant term',
            body: '$equationText\n\nSubtract ${_formatNumber(b)} from both sides when the constant is positive, or add ${_formatNumber(b.abs())} when it is negative.\n\n$a x = ${_formatNumber(isolateValue)}.',
            why: 'We remove the number that is not attached to x so that x is isolated on its own.',
          ),
          TutorStepData(
            title: 'Divide by the coefficient of x',
            body: 'Divide both sides by ${_formatNumber(a)}:\n\nx = ${_formatNumber(isolateValue)} ÷ ${_formatNumber(a)}\n\nx = $xText',
            why: 'Multiplication by a is undone by division by a. This leaves x by itself without changing the balance.',
          ),
          TutorStepData(
            title: 'Check by substitution',
            body: 'Put x = $xText back into the original equation.\n\n${_formatNumber(a)}($xText) ${b >= 0 ? '+' : '-'} ${_formatNumber(b.abs())} = ${_formatNumber(c)}.\n\nThe two sides match, so x = $xText is correct.',
            why: 'Substitution is the strongest quick check because it tests the value in the original equation.',
          ),
        ],
        answer: 'x = $xText',
        methodSummary: 'For a simple linear equation, isolate the term containing x, then undo its coefficient by dividing, and finally check the value by substitution.',
        example: '2x + 5 = 15 → x = 5',
        supported: true,
      );
    }
  }


  // Multi-step arithmetic using order of operations, including parentheses.
  final hasMultipleOperators = RegExp(r'[+\-*/]').allMatches(expression).length >= 2;
  if (hasMultipleOperators && !expression.contains('x') && !expression.contains(':')) {
    final advanced = _evaluateAdvancedExpression(expression);
    if (advanced != null) {
      final working = advanced.steps.isEmpty
          ? 'Evaluate the expression carefully using the order of operations.'
          : advanced.steps.asMap().entries.map((entry) => 'Step ${entry.key + 1}: ${entry.value}').join('\n');
      return TutorSolution(
        question: cleaned,
        topic: 'Order of Operations',
        steps: [
          TutorStepData(
            title: 'Understand the expression',
            body: 'This question contains more than one operation, so we must follow the order of operations rather than simply calculating from left to right.',
            why: 'Different operations have different priorities. Following a common order makes sure everyone gets the same correct result.',
          ),
          TutorStepData(
            title: 'Work through the priority rules',
            body: 'First solve parentheses, then multiplication/division, then addition/subtraction, working left to right within the same priority.\n\n$working',
            why: 'Multiplication and division are grouped before addition and subtraction so the expression keeps its intended mathematical structure.',
          ),
          TutorStepData(
            title: 'Read the final result',
            body: 'After all of the smaller operations are completed, the expression equals ${_formatNumber(advanced.value)}.',
            why: 'The final value is reached by carrying the result of each completed operation into the next stage.',
          ),
          TutorStepData(
            title: 'Check the calculation',
            body: 'Repeat the operations in the same order and confirm that you reach ${_formatNumber(advanced.value)} again.',
            why: 'Repeating the same order is a simple way to catch an operation that was performed too early or too late.',
          ),
        ],
        answer: _formatNumber(advanced.value),
        methodSummary: 'Use parentheses first, then multiplication/division, then addition/subtraction, and work left to right within each level.',
        example: '2 + 3 × 4 = 14',
        supported: true,
      );
    }
  }

  final arithmetic = RegExp(
    r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*([+\-*/])\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$',
  ).firstMatch(expression);

  if (arithmetic == null) {
    return TutorSolution(
      question: cleaned,
      topic: 'Question Understanding',
      steps: const [
        TutorStepData(
          title: 'Read the question carefully',
          body: 'TutorAI needs a clearer expression or a supported question type before it can teach the solution accurately.',
          why: 'A tutor should not invent a method when the question is unclear. Getting the exact wording right prevents teaching the wrong concept.',
        ),
        TutorStepData(
          title: 'Try a supported format',
          body: 'Examples:\n\n12.5 + 3.75\n1/2 + 1/4\n25% of 80\n2x + 5 = 15',
          why: 'These examples give TutorAI enough mathematical structure to show every step and explain why each step works.',
        ),
      ],
      answer: 'Need a clearer question',
      methodSummary: 'TutorAI will only give a solution when it can identify the mathematical structure reliably.',
      example: 'Try: 25% of 80',
      supported: false,
    );
  }

  final leftText = arithmetic.group(1)!;
  final op = arithmetic.group(2)!;
  final rightText = arithmetic.group(3)!;
  final left = double.parse(leftText);
  final right = double.parse(rightText);
  final leftPlaces = _decimalPlaces(leftText);
  final rightPlaces = _decimalPlaces(rightText);
  final isDecimal = leftPlaces > 0 || rightPlaces > 0;

  if (op == '/' && right == 0) {
    return TutorSolution(
      question: cleaned,
      topic: 'Division',
      steps: const [
        TutorStepData(
          title: 'Check the divisor first',
          body: 'The divisor is 0. Division by zero is undefined, so there is no ordinary numerical answer.',
          why: 'There is no number that you can multiply by 0 to get a nonzero dividend. Dividing by zero would break the meaning of division.',
        ),
      ],
      answer: 'Undefined',
      methodSummary: 'Before dividing, check that the divisor is not zero.',
      example: '8 ÷ 2 = 4',
      supported: true,
    );
  }

  final result = switch (op) {
    '+' => left + right,
    '-' => left - right,
    '*' => left * right,
    '/' => left / right,
    _ => 0.0,
  };
  final resultText = _formatNumber(result);

  if (op == '+') {
    final places = _max(leftPlaces, rightPlaces);
    final l = _padDecimal(leftText, places);
    final r = _padDecimal(rightText, places);
    final aligned = '  $l\n+ $r\n──────\n$resultText';
    return TutorSolution(
      question: cleaned,
      topic: isDecimal ? 'Decimal Addition' : 'Addition',
      steps: [
        TutorStepData(
          title: 'Understand the question',
          body: 'We are combining $leftText and $rightText to find the total.',
          why: 'Addition combines quantities. The answer tells us how much there is altogether.',
        ),
        TutorStepData(
          title: isDecimal ? 'Make the place values visible' : 'Line up the place values',
          body: isDecimal
              ? 'Write equal place values in the same columns. If needed, add trailing zeros without changing the value.\n\n$aligned'
              : 'Place ones under ones, tens under tens, and so on:\n\n$leftText\n+ $rightText',
          why: isDecimal
              ? 'A trailing zero does not change a decimal’s value. It simply makes the tenths and hundredths columns visible so equal-sized units can be added together.'
              : 'Every digit has a place value. Matching columns keep equal-sized units together.',
        ),
        TutorStepData(
          title: 'Add from right to left',
          body: isDecimal ? _decimalAdditionWorkingDetailed(l, r, places, resultText) : _integerAdditionWorking(l, r, resultText),
          why: 'We start with the smallest place. When a column totals 10 or more, the extra ten units are regrouped as 1 unit in the next place.',
        ),
        TutorStepData(
          title: 'Write and check the answer',
          body: '$l\n+ $r\n──────\n$resultText\n\nEstimate the size first, then compare it with the exact result.',
          why: 'A check catches common mistakes such as a missed carry, wrong column, or misplaced decimal point.',
        ),
      ],
      answer: resultText,
      methodSummary: isDecimal
          ? 'Align decimal points, make equal place values visible, add from right to left, regroup when a column reaches 10, and bring the decimal point straight down.'
          : 'Align place values, add from right to left, regroup when a column reaches 10, then check the result.',
      example: isDecimal ? '4.50 + 2.25 = 6.75' : '23 + 15 = 38',
      supported: true,
    );
  }

  if (op == '-') {
    final places = _max(leftPlaces, rightPlaces);
    final l = _padDecimal(leftText, places);
    final r = _padDecimal(rightText, places);
    final aligned = '  $l\n- $r\n──────\n$resultText';
    return TutorSolution(
      question: cleaned,
      topic: isDecimal ? 'Decimal Subtraction' : 'Subtraction',
      steps: [
        TutorStepData(
          title: 'Understand the question',
          body: 'We are taking $rightText away from $leftText. The result tells us what remains or the difference between them.',
          why: 'Subtraction measures a difference or removes one quantity from another.',
        ),
        TutorStepData(
          title: isDecimal ? 'Line up the decimal points' : 'Line up the place values',
          body: isDecimal
              ? 'Write the numbers with their decimal points directly under each other:\n\n$aligned'
              : 'Line up ones, tens, hundreds, and other matching place values in columns.',
          why: isDecimal
              ? 'The decimal point keeps tenths, hundredths, and whole numbers in their correct columns.'
              : 'Subtraction must compare equal-sized place-value units.',
        ),
        TutorStepData(
          title: 'Subtract from right to left',
          body: _subtractionWorking(l, r, resultText, places),
          why: 'If the top digit is smaller, regroup one unit from the place to its left. One unit in a larger place becomes 10 units in the next smaller place.',
        ),
        TutorStepData(
          title: 'Check by adding back',
          body: '$resultText + $rightText = ${_formatNumber(result + right)}.\nThat returns to the original value $leftText.',
          why: 'Addition and subtraction are inverse operations, so adding the difference back should restore the starting number.',
        ),
      ],
      answer: resultText,
      methodSummary: isDecimal
          ? 'Align decimal points, subtract from right to left, regroup when needed, and verify by adding the difference back.'
          : 'Align place values, subtract from right to left, regroup when needed, and verify by adding back.',
      example: isDecimal ? '8.40 - 3.25 = 5.15' : '42 - 17 = 25',
      supported: true,
    );
  }

  if (op == '*') {
    final totalPlaces = leftPlaces + rightPlaces;
    final wholeLeft = (left * pow10(leftPlaces)).round();
    final wholeRight = (right * pow10(rightPlaces)).round();
    final wholeProduct = wholeLeft * wholeRight;
    final decimalPlacement = isDecimal
        ? 'There are $totalPlaces decimal places in the original factors altogether. Count $totalPlaces places from the right in $wholeProduct to get $resultText.'
        : 'Combine the partial products to get $resultText.';
    return TutorSolution(
      question: cleaned,
      topic: isDecimal ? 'Decimal Multiplication' : 'Multiplication',
      steps: [
        TutorStepData(
          title: 'Understand the question',
          body: 'We are multiplying $leftText by $rightText.',
          why: 'Multiplication finds equal groups and also scales one quantity by another.',
        ),
        TutorStepData(
          title: isDecimal ? 'Temporarily remove the decimal points' : 'Multiply the factors',
          body: isDecimal
              ? 'Treat the factors as whole numbers: $wholeLeft × $wholeRight = $wholeProduct.'
              : 'Multiply the digits and build the partial products according to place value.',
          why: isDecimal
              ? 'Whole-number multiplication is easier to perform first. We restore the decimal places afterward based on place value.'
              : 'The standard multiplication method preserves the value of each place and combines the partial products.',
        ),
        TutorStepData(
          title: isDecimal ? 'Restore the decimal point' : 'Combine the partial products',
          body: decimalPlacement,
          why: isDecimal
              ? 'The number of decimal places in the factors tells us where the decimal must go in the product so the size of the answer stays correct.'
              : 'Combining the partial products gives the total product.',
        ),
        TutorStepData(
          title: 'Check the size',
          body: 'Estimate the factors first. The exact product is $resultText, which should be in the same general size range as the estimate.',
          why: 'A size check can reveal a misplaced decimal point or an incorrect multiplication.',
        ),
      ],
      answer: resultText,
      methodSummary: isDecimal
          ? 'Multiply as whole numbers, count all decimal places in the original factors, restore the decimal point, and check the size.'
          : 'Multiply place values carefully, combine partial products, and check the size of the result.',
      example: isDecimal ? '1.2 × 3.0 = 3.6' : '6 × 4 = 24',
      supported: true,
    );
  }

  final movePlaces = rightPlaces;
  final adjustedLeft = movePlaces > 0 ? _formatNumber(left * pow10(movePlaces)) : leftText;
  final adjustedRight = movePlaces > 0 ? _formatNumber(right * pow10(movePlaces)) : rightText;
  return TutorSolution(
    question: cleaned,
    topic: isDecimal ? 'Decimal Division' : 'Division',
    steps: [
      TutorStepData(
        title: 'Understand the question',
        body: 'We are finding how many groups of $rightText fit into $leftText.',
        why: 'Division describes equal sharing or how many times one quantity fits into another.',
      ),
      TutorStepData(
        title: movePlaces > 0 ? 'Make the divisor a whole number' : 'Set up the division',
        body: movePlaces > 0
            ? 'Move the decimal point $movePlaces place${movePlaces == 1 ? '' : 's'} in both numbers:\n$leftText ÷ $rightText becomes $adjustedLeft ÷ $adjustedRight.'
            : 'Set up $leftText ÷ $rightText and work through the quotient one place at a time.',
        why: movePlaces > 0
            ? 'Moving both decimal points the same number of places multiplies both numbers by the same power of 10, so the quotient stays the same.'
            : 'The quotient records how many equal groups of the divisor fit into the dividend.',
      ),
      TutorStepData(
        title: 'Divide step-by-step',
        body: '$adjustedLeft ÷ $adjustedRight = $resultText. Work through the quotient place by place, bringing down digits when necessary.',
        why: 'Each quotient digit tells us how many groups fit into the current part of the dividend.',
      ),
      TutorStepData(
        title: 'Check by multiplying',
        body: '$resultText × $rightText = ${_formatNumber(result * right)}.',
        why: 'Multiplication is the inverse of division, so it can confirm the quotient.',
      ),
    ],
    answer: resultText,
    methodSummary: isDecimal
        ? 'Make the divisor a whole number by moving both decimal points equally, divide, then check by multiplication.'
        : 'Divide one step at a time and confirm the quotient by multiplying it by the divisor.',
    example: isDecimal ? '6.0 ÷ 1.5 = 4' : '24 ÷ 6 = 4',
    supported: true,
  );
}

String _integerAdditionWorking(String left, String right, String result) {
  final a = left.split('').reversed.toList();
  final b = right.split('').reversed.toList();
  final maxLen = _max(a.length, b.length);
  var carry = 0;
  final lines = <String>[];
  for (var i = 0; i < maxLen; i++) {
    final x = i < a.length ? int.parse(a[i]) : 0;
    final y = i < b.length ? int.parse(b[i]) : 0;
    final total = x + y + carry;
    lines.add('Column ${i + 1}: $x + $y${carry > 0 ? ' + carried $carry' : ''} = $total.');
    carry = total >= 10 ? 1 : 0;
    if (carry > 0) lines.add('Because $total is 10 or more, write ${total % 10} and carry 1 to the next column.');
  }
  lines.add('So the completed answer is $result.');
  return lines.join('\n');
}

String _decimalPlaceName(int indexFromDecimal) {
  switch (indexFromDecimal) {
    case 0:
      return 'tenths';
    case 1:
      return 'hundredths';
    case 2:
      return 'thousandths';
    case 3:
      return 'ten-thousandths';
    case 4:
      return 'hundred-thousandths';
    default:
      return 'decimal place ${indexFromDecimal + 1}';
  }
}

String _decimalAdditionWorkingDetailed(String left, String right, int places, String result) {
  final lp = left.split('.');
  final rp = right.split('.');
  final wholeA = int.parse(lp[0]);
  final wholeB = int.parse(rp[0]);
  final fracA = lp.length > 1 ? lp[1] : '0' * places;
  final fracB = rp.length > 1 ? rp[1] : '0' * places;
  final lines = <String>[];
  lines.add('Start at the smallest place value and move left.');
  var carry = 0;
  for (var i = places - 1; i >= 0; i--) {
    final x = int.parse(fracA[i]);
    final y = int.parse(fracB[i]);
    final total = x + y + carry;
    final place = _decimalPlaceName(i);
    lines.add('${place[0].toUpperCase()}${place.substring(1)}: $x + $y${carry > 0 ? ' + carried $carry' : ''} = $total.');
    carry = total >= 10 ? 1 : 0;
    if (carry > 0) {
      lines.add('Write ${total % 10} in the $place place and carry 1 to the next place.');
    } else {
      lines.add('Write $total in the $place place.');
    }
  }
  final wholeTotal = wholeA + wholeB + carry;
  lines.add('Whole numbers: $wholeA + $wholeB${carry > 0 ? ' + carried $carry' : ''} = $wholeTotal.');
  lines.add('Keep the decimal point directly under the decimal points above.');
  lines.add('That gives $result.');
  return lines.join('\n');
}

String _subtractionWorking(String left, String right, String result, int places) {
  final lines = <String>[];
  lines.add('Work from the smallest place value to the left.');
  lines.add('If the top digit is too small, regroup one unit from the column to its left.');
  if (places > 0) lines.add('Because the decimal points are aligned, each decimal column represents the same unit.');
  lines.add('Complete the column subtraction and keep the decimal point in the same column.');
  lines.add('Result: $result.');
  return lines.join('\n');
}

int _decimalPlaces(String value) {
  if (!value.contains('.')) return 0;
  return value.split('.').last.length;
}

double pow10(int places) {
  var value = 1.0;
  for (var i = 0; i < places; i++) value *= 10;
  return value;
}

int _max(int a, int b) => a > b ? a : b;

String _padDecimal(String value, int places) {
  if (places == 0) return value.split('.').first;
  if (!value.contains('.')) return '$value.${'0' * places}';
  final p = value.split('.');
  return '${p[0]}.${p[1].padRight(places, '0')}';
}

String _formatNumber(double value) {
  if (value.isFinite && value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class QuestionResultScreen extends StatefulWidget {
  final TutorSolution solution;
  const QuestionResultScreen({super.key, required this.solution});

  @override
  State<QuestionResultScreen> createState() => _QuestionResultScreenState();
}

class _QuestionResultScreenState extends State<QuestionResultScreen> {
  final TextEditingController _askController = TextEditingController();
  final TextEditingController _practiceController = TextEditingController();
  final TextEditingController _conversationController = TextEditingController();
  final List<String> _tutorReplies = [];
  bool _sending = false;
  int? _lastAskedStep;
  int _deeperExplanationRound = 0;
  String? _understandingStatus;
  bool _practiceChecked = false;
  bool? _practiceCorrect;
  String _practiceFeedback = '';

  @override
  void dispose() {
    _askController.dispose();
    _practiceController.dispose();
    _conversationController.dispose();
    super.dispose();
  }

  Future<void> _askTutor({String? preset, int? stepIndex, TextEditingController? controller}) async {
    final activeController = controller ?? _askController;
    final question = (preset ?? activeController.text).trim();
    if (question.isEmpty) return;
    setState(() => _sending = true);
    final backendReply = await _tutorBackend.askFollowUp(
      question: question,
      solution: widget.solution,
      context: _defaultAcademicContext,
      conversation: List<String>.from(_tutorReplies),
    );
    if (!mounted) return;
    final reply = backendReply ??
        _explainFollowUp(question, widget.solution, stepIndex: stepIndex);
    setState(() {
      _tutorReplies.add('You: $question');
      _tutorReplies.add('TutorAI: $reply');
      activeController.clear();
      _sending = false;
    });
  }

  String _explainFollowUp(String question, TutorSolution solution, {int? stepIndex}) {
    final q = question.toLowerCase();
    final parsedStep = RegExp(r'(?:step\s*)?(\d+)', caseSensitive: false).firstMatch(q);
    final requestedStep = stepIndex ??
        (parsedStep != null ? int.tryParse(parsedStep.group(1)!) : null) ??
        _lastAskedStep;
    if (requestedStep != null && requestedStep >= 1 && requestedStep <= solution.steps.length &&
        (q.contains('why') || q.contains('how') || q.contains('that') || q.contains('this') || q.contains('step'))) {
      _lastAskedStep = requestedStep;
      final step = solution.steps[requestedStep - 1];
      return 'Let’s use Step $requestedStep from your exact question.\n\n**What the step does:**\n${step.body}\n\n**Why we do it:**\n${step.why}\n\n**What changes after this step:**\nThe work becomes one smaller piece of the original problem, which makes the next step easier to perform and check.\n\nIf this is still unclear, tell me which word, number, carry, fraction, or operation is confusing you and I will break that exact part down again.';
    }

    if (q.contains('another') || q.contains('example')) {
      return 'Here is another ${solution.topic.toLowerCase()} example:\n\n${solution.example}\n\nFirst try it using the same method. Then compare your work with the steps you learned. If you get stuck, tell me the exact step where you got stuck.';
    }

    if (q.contains('simpl') || q.contains('easier') || q.contains('slow') || q.contains('still')) {
      return _buildDeeperExplanation(solution, _deeperExplanationRound + 1);
    }

    if (q.contains('why') && solution.topic.toLowerCase().contains('percentage')) {
      final m = RegExp(r'(-?(?:\d+(?:\.\d+)?|\.\d+))\s*%\s*of\s*(-?(?:\d+(?:\.\d+)?|\.\d+))', caseSensitive: false)
          .firstMatch(_normalizeQuestion(solution.question));
      if (m != null) {
        final pText = m.group(1)!;
        final baseText = m.group(2)!;
        final p = double.parse(pText);
        final decimal = _formatNumber(p / 100);
        final answer = _formatNumber(double.parse(baseText) * p / 100);
        return 'Let’s use your exact percentage question: $pText% of $baseText.\n\nA percent means “out of 100”. So $pText% means $pText out of 100.\n\nDivide $pText by 100:\n$pText ÷ 100 = $decimal.\n\nThen multiply the whole amount by that decimal:\n$decimal × $baseText = $answer.\n\nWhy do we do that? Because $pText% is the same as the fraction $pText/100. Multiplying by that fraction takes exactly that part of the whole amount.\n\nSo the answer is $answer, and the decimal conversion is what makes the percentage usable in a multiplication.';
      }
    }

    if (q.contains('why') && solution.topic.toLowerCase().contains('fraction')) {
      final m = RegExp(r'(-?\d+\s*/\s*\d+)\s*([+\-*/])\s*(-?\d+\s*/\s*\d+)', caseSensitive: false)
          .firstMatch(_normalizeQuestion(solution.question));
      if (m != null) {
        final a = _parseFraction(m.group(1)!);
        final b = _parseFraction(m.group(3)!);
        final op = m.group(2)!;
        if (a != null && b != null) {
          if (op == '+' || op == '-') {
            final common = a.denominator * b.denominator;
            final leftNumerator = a.numerator * b.denominator;
            final rightNumerator = b.numerator * a.denominator;
            final combined = op == '+' ? leftNumerator + rightNumerator : leftNumerator - rightNumerator;
            return 'Let’s use your exact fractions: ${a.display} $op ${b.display}.\n\nFor addition or subtraction, the pieces must be the same size before we combine them. That is why we create a common denominator.\n\nUsing $common as a common denominator:\n${a.display} = $leftNumerator/$common\n${b.display} = $rightNumerator/$common\n\nNow both fractions describe pieces of the same size, so we can ${op == '+' ? 'add' : 'subtract'} the numerators:\n$leftNumerator $op $rightNumerator = $combined.\n\nThe denominator stays $common because the size of each piece did not change. Then we simplify the resulting fraction.\n\nThat is the reason for the common denominator — it makes the fractional pieces comparable.';
          }
          if (op == '*') {
            final result = _fractionMultiply(a, b);
            return 'For ${a.display} × ${b.display}, multiply the numerators and multiply the denominators:\n\n${a.numerator} × ${b.numerator} = ${a.numerator * b.numerator}\n${a.denominator} × ${b.denominator} = ${a.denominator * b.denominator}\n\nSo we get ${a.numerator * b.numerator}/${a.denominator * b.denominator}, which simplifies to ${result.display}.\n\nWhy? Multiplying fractions is combining a part of one quantity with a part of another.';
          }
          if (op == '/') {
            final result = _fractionDivide(a, b);
            return 'For ${a.display} ÷ ${b.display}, keep the first fraction, change division to multiplication, and flip the second fraction:\n\n${a.display} × ${b.denominator}/${b.numerator}\n\nThen multiply:\n${a.numerator} × ${b.denominator} / (${a.denominator} × ${b.numerator}) = ${result.display}.\n\nWhy? Dividing by a fraction asks how many groups of that fractional size fit into the first fraction. Multiplying by the reciprocal gives that number of groups.';
          }
        }
      }
    }

    if (q.contains('why') && solution.topic.toLowerCase().contains('algebra')) {
      final m = RegExp(r'(-?\d*\.?\d*)x\s*([+\-])\s*(-?\d+(?:\.\d+)?)\s*=\s*(-?\d+(?:\.\d+)?)', caseSensitive: false)
          .firstMatch(_normalizeQuestion(solution.question).replaceAll(' ', ''));
      if (m != null) {
        final aRaw = m.group(1)!;
        final a = aRaw.isEmpty ? 1.0 : (aRaw == '-' ? -1.0 : double.parse(aRaw));
        final sign = m.group(2)!;
        final bValue = double.parse(m.group(3)!);
        final b = sign == '+' ? bValue : -bValue;
        final c = double.parse(m.group(4)!);
        final isolate = c - b;
        final x = isolate / a;
        if (q.contains('divide') || q.contains('coefficient') || q.contains('2')) {
          return 'Let’s use the exact equation from your question.\n\nThe coefficient of x is ${_formatNumber(a)}. After removing the constant, the equation becomes:\n${_formatNumber(a)}x = ${_formatNumber(isolate)}\n\nWe then divide both sides by ${_formatNumber(a)}:\n${_formatNumber(a)}x ÷ ${_formatNumber(a)} = ${_formatNumber(isolate)} ÷ ${_formatNumber(a)}\n\nx = ${_formatNumber(x)}.\n\nWhy? Multiplication by ${_formatNumber(a)} and division by ${_formatNumber(a)} are inverse operations. Dividing undoes the coefficient so x can stand by itself.\n\nFinally, substitute x = ${_formatNumber(x)} back into the original equation to make sure both sides are equal.';
        }
        return 'An equation is a balance. In your exact equation, we first remove the constant term so the x-term is by itself. Then we undo the coefficient by dividing both sides by the same number. We must perform the same operation on both sides so the balance is preserved.\n\nFor your question, that process leads to x = ${_formatNumber(x)} and substitution confirms the result.';
      }
    }

    if (q.contains('why') && solution.topic.toLowerCase().contains('decimal addition')) {
      final m = RegExp(r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*\+\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$')
          .firstMatch(_normalizeQuestion(solution.question));
      if (m != null) {
        final a = m.group(1)!;
        final b = m.group(2)!;
        final places = _max(_decimalPlaces(a), _decimalPlaces(b));
        final ap = _padDecimal(a, places);
        final bp = _padDecimal(b, places);
        final as = ap.split('.');
        final bs = bp.split('.');
        final aWhole = int.parse(as[0]);
        final bWhole = int.parse(bs[0]);
        final aTenths = int.parse(as[1][0]);
        final bTenths = int.parse(bs[1][0]);
        final aHund = places > 1 ? int.parse(as[1][1]) : 0;
        final bHund = places > 1 ? int.parse(bs[1][1]) : 0;
        final hundredSum = aHund + bHund;
        final carryTenths = hundredSum >= 10 ? 1 : 0;
        final tenthsSum = aTenths + bTenths + carryTenths;
        final carryWhole = tenthsSum >= 10 ? 1 : 0;
        final wholeSubtotal = aWhole + bWhole;
        if (q.contains('15') || q.contains('16') || q.contains('change') || q.contains('become') || q.contains('carry')) {
          final finalWhole = wholeSubtotal + carryWhole;
          final hundredDigit = hundredSum % 10;
          final tenthsDigit = tenthsSum % 10;
          return '''Let's use the exact numbers in your question: $a + $b.

1. Whole-number part:
$aWhole + $bWhole = $wholeSubtotal.
That is only the whole-number subtotal — we are not finished yet.

2. Hundredths:
$aHund + $bHund = $hundredSum.
We keep $hundredDigit hundredths${carryTenths > 0 ? ' and carry 1 into the tenths column' : ''}.

3. Tenths:
$aTenths + $bTenths${carryTenths > 0 ? ' + 1 carried' : ''} = $tenthsSum.
We keep $tenthsDigit tenths${carryWhole > 0 ? ' and carry 1 whole into the ones column' : ''}.

4. Why does $wholeSubtotal become $finalWhole?
Because **10 tenths are equal to 1 whole**. The tenths column produced enough tenths to make one complete whole. That extra whole must move into the ones column.

So:
$wholeSubtotal + 1 = $finalWhole.

The decimal remainder is .${tenthsDigit}${places > 1 ? hundredDigit : 0}.

Therefore the complete answer is **${solution.answer}**.

The key idea is that the number did not randomly change. An extra whole was created from the decimal part through regrouping.''';
        }
        return 'For your exact decimal question, decimal points line up because they keep equal place values together: ones under ones, tenths under tenths, and hundredths under hundredths. A digit changes its value when it moves to a different place, so aligning the decimal points protects the value of every digit.\n\nFor this problem:\n  $ap\n+ $bp\n──────\nThe decimal point stays in the same column while the digits are added.';
      }
    }

    if (q.contains('how') || q.contains('show')) {
      return 'Here is the complete method for **${solution.topic}**:\n\n${solution.methodSummary}\n\nThen work through the lesson in order:\n\n${solution.steps.asMap().entries.map((e) => 'Step ${e.key + 1}: ${e.value.body}').join('\n\n')}';
    }

    if (q.contains('check') || q.contains('correct') || q.contains('right answer')) {
      return "Let’s verify the exact lesson instead of trusting the final number.\n\n${solution.steps.asMap().entries.map((e) => 'Step ${e.key + 1}: ${e.value.title}\n${e.value.body}').join('\n\n')}\n\nFinal answer: ${solution.answer}\n\nThe key check is to use the inverse operation, substitution, estimation, or a place-value check appropriate to this topic.";
    }

    return 'I can explain this exact question, not just give a rule. Tell me the specific part you do not understand — for example, “Why did we carry 1?”, “Why did 15 become 16?”, “Why did we use a common denominator?”, or “Why did we divide by 2?”';
  }

  String _practiceQuestionFor(TutorSolution solution) {
    final topic = solution.topic.toLowerCase();
    if (topic.contains('percentage')) return '20% of 150';
    if (topic.contains('fraction') && topic.contains('addition')) return '1/2 + 1/4';
    if (topic.contains('fraction') && topic.contains('subtraction')) return '3/4 - 1/4';
    if (topic.contains('fraction') && topic.contains('multiplication')) return '2/3 × 3/4';
    if (topic.contains('fraction') && topic.contains('division')) return '1/2 ÷ 1/4';
    if (topic.contains('algebra')) return '2x + 5 = 15';
    if (topic.contains('decimal addition')) return '4.50 + 2.25';
    if (topic.contains('decimal subtraction')) return '8.40 - 3.25';
    if (topic.contains('decimal multiplication')) return '1.2 × 3.0';
    if (topic.contains('decimal division')) return '6.0 ÷ 1.5';
    if (topic.contains('addition')) return '23 + 15';
    if (topic.contains('subtraction')) return '42 - 17';
    if (topic.contains('multiplication')) return '6 × 4';
    if (topic.contains('division')) return '24 ÷ 6';
    return solution.example;
  }

  void _markUnderstanding(String status) {
    setState(() => _understandingStatus = status);
    if (status == 'understand') {
      _tutorReplies.add('TutorAI: Excellent. The next step is practice so you can prove you can do it yourself.');
    } else {
      _deeperExplanationRound += 1;
      _tutorReplies.add('TutorAI: No problem. I will explain the same idea again using smaller pieces, the exact numbers from your question, and a fresh example.');
      _tutorReplies.add('TutorAI: ${_buildDeeperExplanation(widget.solution, _deeperExplanationRound)}');
    }
    setState(() {});
  }

  String _buildDeeperExplanation(TutorSolution solution, int round) {
    if (solution.topic.toLowerCase().contains('decimal addition')) {
      final m = RegExp(r'^\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*\+\s*(-?(?:\d+(?:\.\d+)?|\.\d+))\s*$')
          .firstMatch(_normalizeQuestion(solution.question));
      if (m != null) {
        final a = m.group(1)!;
        final b = m.group(2)!;
        final places = _max(_decimalPlaces(a), _decimalPlaces(b));
        final ap = _padDecimal(a, places);
        final bp = _padDecimal(b, places);
        final as = ap.split('.');
        final bs = bp.split('.');
        final hundredA = places > 1 ? int.parse(as[1][1]) : 0;
        final hundredB = places > 1 ? int.parse(bs[1][1]) : 0;
        final tenthA = int.parse(as[1][0]);
        final tenthB = int.parse(bs[1][0]);
        final hundredSum = hundredA + hundredB;
        final carryTenths = hundredSum >= 10 ? 1 : 0;
        final tenthsSum = tenthA + tenthB + carryTenths;
        final carryWhole = tenthsSum >= 10 ? 1 : 0;
        final wholeSum = int.parse(as[0]) + int.parse(bs[0]) + carryWhole;
        if (round == 1) {
          return 'Slow version:\n\n$ap means ${as[0]} whole, $tenthA tenth${tenthA == 1 ? '' : 's'}, and $hundredA hundredth${hundredA == 1 ? '' : 's'}.\n$bp means ${bs[0]} whole, $tenthB tenth${tenthB == 1 ? '' : 's'}, and $hundredB hundredth${hundredB == 1 ? '' : 's'}.\n\nStart at hundredths, then tenths, then ones. When a place reaches 10, regroup 10 smaller units as 1 unit of the next place.\n\nThat is why the decimal part can create an extra whole number.';
        }
        if (round == 2) {
          return 'Place-value version:\n\nONES | TENTHS | HUNDREDTHS\n${as[0]} | ${tenthA} | $hundredA\n${bs[0]} | ${tenthB} | $hundredB\n\nNow combine matching columns only. If the hundredths column makes 10 or more, carry to tenths. If the tenths column makes 10 or more, carry 1 whole to ones. Your exact answer is ${solution.answer}.';
        }
        return 'Check-your-thinking version:\n\nCould you explain why 10 tenths are the same as 1 whole? That single idea explains every carry from the decimal part into the whole-number part. In this problem, the carries are built from the actual columns above, not guessed.';
      }
    }
    final firstStep = solution.steps.isNotEmpty ? solution.steps.first : null;
    final secondStep = solution.steps.length > 1 ? solution.steps[1] : null;
    return 'Let’s rebuild this lesson in a different way.\n\n'
        '1. Say the question in your own words.\n'
        '${firstStep == null ? '' : '2. Start with: ${firstStep.title}.\n${firstStep.body}\n\nWhy? ${firstStep.why}\n\n'}'
        '${secondStep == null ? '' : '3. Then move to: ${secondStep.title}.\n${secondStep.body}\n\nWhy? ${secondStep.why}\n\n'}'
        '4. Check the final answer: ${solution.answer}.\n\n'
        'If this still does not make sense, tell me the exact word, number, symbol, or step that is confusing you. I will explain that one piece with a simpler example instead of repeating the whole lesson.';
  }

  bool _answersEquivalent(String entered, String expected) {
    final cleanEntered = entered.trim().replaceAll(',', '').replaceAll(' ', '');
    final cleanExpected = expected.trim().replaceAll(',', '').replaceAll(' ', '');
    if (cleanEntered == cleanExpected) return true;

    final normalizedExpected = cleanExpected.startsWith('x=') ? cleanExpected.substring(2) : cleanExpected;
    final ef = _parseFraction(cleanEntered);
    final xf = _parseFraction(normalizedExpected);
    if (ef != null && xf != null) return ef.value == xf.value;

    final en = double.tryParse(cleanEntered);
    final xn = double.tryParse(normalizedExpected);
    return en != null && xn != null && (en - xn).abs() < 1e-9;
  }

  void _checkPractice() {
    final question = _practiceQuestionFor(widget.solution);
    final practiceSolution = solveTutorQuestion(question);
    final entered = _practiceController.text.trim();
    if (entered.isEmpty) return;
    final correct = _answersEquivalent(entered, practiceSolution.answer);
    setState(() {
      _practiceChecked = true;
      _practiceCorrect = correct;
      _practiceFeedback = correct
          ? 'Correct! ${practiceSolution.answer} is right. You used the method successfully. Now explain to yourself why the key step works.'
          : 'Not yet. The correct answer is ${practiceSolution.answer}. ${practiceSolution.steps.first.body}\n\nIf you tell TutorAI exactly where you got stuck, it can explain that step again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final solution = widget.solution;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _ResultCard(
            title: 'Question',
            child: Text(solution.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.35)),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Your lesson plan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(solution.topic, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF14213D))),
                const SizedBox(height: 7),
                const Text('Understand → Learn the method → Work each step → Understand why → Check → Practice', style: TextStyle(color: Color(0xFF53637A), height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Key idea',
            child: Text(
              _keyIdeaForTopic(solution.topic),
              style: const TextStyle(color: Color(0xFF53637A), height: 1.5, fontSize: 14),
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'TutorAI learning coach',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Use the lesson actively: explain the next step in your own words before reading the answer, then use Practice to test independent understanding.',
                  style: TextStyle(color: Color(0xFF53637A), height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _askTutor(preset: 'Teach me the key idea in one very simple sentence, then give me one question to test it.'),
                      icon: const Icon(Icons.psychology_alt_outlined, size: 17),
                      label: const Text('Coach Me'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _askTutor(preset: 'Check my reasoning strategy for this question and tell me what a careful student should watch for.'),
                      icon: const Icon(Icons.fact_check_outlined, size: 17),
                      label: const Text('Check My Reasoning'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Common mistake to avoid',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFB46A00)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _commonMistakeForTopic(solution.topic),
                    style: const TextStyle(color: Color(0xFF53637A), height: 1.5, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Learning objective',
            child: Text(
              _learningObjectiveForTopic(solution.topic),
              style: const TextStyle(color: Color(0xFF53637A), height: 1.5, fontSize: 14),
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'How you know you understand',
            child: Text(
              _masteryCheckForTopic(solution.topic),
              style: const TextStyle(color: Color(0xFF53637A), height: 1.5, fontSize: 14),
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: solution.supported ? 'Detailed step-by-step lesson' : 'Let’s clarify the question',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (solution.supported)
                  for (var i = 0; i < solution.steps.length; i++) ...[
                    _Step(number: '${i + 1}', title: solution.steps[i].title, body: '${solution.steps[i].body}\n\nWhy this works:\n${solution.steps[i].why}', onAsk: () => _askTutor(stepIndex: i + 1, preset: 'Why is Step ${i + 1} like that?')),
                    if (i != solution.steps.length - 1) const Divider(height: 28),
                  ]
                else
                  for (var i = 0; i < solution.steps.length; i++) ...[
                    _Step(number: '${i + 1}', title: solution.steps[i].title, body: '${solution.steps[i].body}\n\nWhy this matters:\n${solution.steps[i].why}'),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Answer',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFE1F8EA), borderRadius: BorderRadius.circular(16)),
              child: Text(solution.answer, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B6B49))),
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'If you are not satisfied with the explanation',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tell TutorAI exactly what is confusing you. It will not simply repeat the same answer — it will change the teaching approach and go deeper.', style: TextStyle(color: Color(0xFF5E6D81), height: 1.45)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(onPressed: () => _markUnderstanding('understand'), icon: const Icon(Icons.check_circle_outline_rounded, size: 18), label: const Text('Yes, I understand')),
                    OutlinedButton.icon(onPressed: () => _markUnderstanding('more'), icon: const Icon(Icons.more_horiz_rounded, size: 18), label: const Text('Explain More')),
                    OutlinedButton.icon(onPressed: () => _askTutor(preset: 'Explain this more simply using the exact numbers.'), icon: const Icon(Icons.menu_book_rounded, size: 18), label: const Text('Simpler')),
                    OutlinedButton.icon(onPressed: () => _askTutor(preset: 'Give me another worked example and explain every step.'), icon: const Icon(Icons.lightbulb_outline_rounded, size: 18), label: const Text('Another Example')),
                  ],
                ),
                if (_understandingStatus != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _understandingStatus == 'understand'
                        ? '✅ Great. Let’s prove it with a short practice question.'
                        : '💡 No problem. I have added a deeper explanation. You can keep asking until it is clear.',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2C4D78)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'What do you not understand?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Write the exact part that is confusing you. For example: “Why did 15 become 16?”, “Why do I need a common denominator?”, or “Why did we divide by 2?”', style: TextStyle(color: Color(0xFF5E6D81), height: 1.45)),
                const SizedBox(height: 10),
                TextField(
                  controller: _askController,
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Tell TutorAI exactly what you do not understand...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFD),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDDE6F2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : () => _askTutor(controller: _askController),
                    icon: _sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.3, color: Colors.white)) : const Icon(Icons.auto_awesome_rounded),
                    label: Text(_sending ? 'Explaining...' : "Explain What I Don't Understand"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Ask TutorAI',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ask anything about the lesson at any time. TutorAI will use the current question and lesson steps as context.', style: TextStyle(color: Color(0xFF5E6D81), height: 1.45)),
                const SizedBox(height: 10),
                TextField(
                  controller: _conversationController,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sending ? null : _askTutor(controller: _conversationController),
                  decoration: InputDecoration(
                    hintText: 'Ask TutorAI a question...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFD),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDDE6F2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : () => _askTutor(controller: _conversationController),
                    icon: _sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.3, color: Colors.white)) : const Icon(Icons.chat_bubble_outline_rounded),
                    label: Text(_sending ? 'Thinking...' : 'Ask Tutor'),
                  ),
                ),
                if (_tutorReplies.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  for (final reply in _tutorReplies) Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: reply.startsWith('TutorAI:') ? const Color(0xFFEAF2FF) : const Color(0xFFF4F5F7), borderRadius: BorderRadius.circular(14)),
                    child: Text(reply, style: const TextStyle(color: Color(0xFF32435D), height: 1.45)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'Practice — show me you understand',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Now solve a similar question yourself. TutorAI will mark the answer, explain mistakes, and let you ask for help again.', style: TextStyle(color: Color(0xFF5E6D81), height: 1.45)),
                const SizedBox(height: 10),
                Text(_practiceQuestionFor(solution), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF14213D))),
                const SizedBox(height: 10),
                TextField(
                  controller: _practiceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: 'Your answer',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFD),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFDDE6F2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(onPressed: _checkPractice, icon: const Icon(Icons.check_rounded), label: const Text('Check My Answer')),
                ),
                if (_practiceChecked) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _practiceCorrect == true ? const Color(0xFFE1F8EA) : const Color(0xFFFFF1F1), borderRadius: BorderRadius.circular(14)),
                    child: Text(_practiceFeedback, style: TextStyle(color: _practiceCorrect == true ? const Color(0xFF1B6B49) : const Color(0xFF9B3030), fontWeight: FontWeight.w700, height: 1.45)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ResultCard(
            title: 'One more example',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(solution.example, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF14213D))),
              const SizedBox(height: 8),
              const Text('Try to explain to yourself why the method works before looking for help.', style: TextStyle(color: Color(0xFF5E6D81), height: 1.4)),
            ]),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ask Another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Practice is ready below. Try it and check your answer.'),
                      ),
                    );
                  },
                  child: const Text('Practice Below →'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ResultCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: _softShadow()),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF14213D))), const SizedBox(height: 12), child]),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final VoidCallback? onAsk;

  const _Step({required this.number, required this.title, required this.body, this.onAsk});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF24334B))),
              const SizedBox(height: 6),
              Text(body, style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF53637A))),
              if (onAsk != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onAsk,
                  icon: const Icon(Icons.help_outline_rounded, size: 16),
                  label: const Text('Ask why'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34), padding: const EdgeInsets.symmetric(horizontal: 10)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


String _keyIdeaForTopic(String topic) {
  final t = topic.toLowerCase();
  if (t.contains('decimal')) return 'Keep matching place values together. Decimal points align the ones, tenths, hundredths, and smaller units so each digit keeps its correct value.';
  if (t.contains('fraction')) return 'A fraction represents part of a whole. Always ask what the numerator counts, what the denominator means, and whether the fractional pieces are the same size.';
  if (t.contains('percentage')) return 'A percentage is a number out of 100. Decide whether the question asks for a percentage of a whole, a percentage change, or a part-as-a-percent relationship.';
  if (t.contains('ratio')) return 'A ratio compares quantities in the same relationship. A proportion means two ratios are equal, so cross multiplication can create an equation.';
  if (t.contains('average')) return 'The mean shares the total equally. Add every value first, then divide by how many values there are.';
  if (t.contains('algebra')) return 'Treat an equation like a balance. Whatever operation you apply to one side must also be applied to the other side.';
  if (t.contains('order')) return 'Operations have a priority. Parentheses come first, then multiplication/division, then addition/subtraction.';
  if (t.contains('addition')) return 'Combine matching place values from right to left and regroup whenever a column reaches 10 or more.';
  if (t.contains('subtraction')) return 'Subtract matching place values from right to left and regroup from the next larger place when necessary.';
  if (t.contains('multiplication')) return 'Multiplication combines equal groups and preserves place value through each partial product.';
  if (t.contains('division')) return 'Division asks how many equal groups fit into the quantity. Use the inverse multiplication check at the end.';
  return 'Focus on what the question is asking, identify the method, work one step at a time, and verify the answer.';
}

String _commonMistakeForTopic(String topic) {
  final t = topic.toLowerCase();
  if (t.contains('decimal')) return 'Do not shift a decimal point casually. Line up place values or move both decimal points by the same number of places when the method requires it.';
  if (t.contains('fraction')) return 'Do not add or subtract denominators directly. For addition and subtraction, the fractional pieces must represent the same-sized parts.';
  if (t.contains('percentage')) return 'Do not confuse the whole, the part, and the percentage. Identify which quantity is the reference whole before calculating.';
  if (t.contains('ratio')) return 'Do not mix the order of the ratio terms. Keep the first quantity matched with the first quantity and the second with the second.';
  if (t.contains('average')) return 'Do not divide too early. Add every value first, then divide by the number of values.';
  if (t.contains('algebra')) return 'Do not move a term across the equals sign without accounting for the operation. Keep the equation balanced.';
  if (t.contains('order')) return 'Do not simply calculate from left to right when multiplication, division, or parentheses are present.';
  return 'Write each step clearly and check the result using an inverse operation or a quick estimate.';
}


String _learningObjectiveForTopic(String topic) {
  final t = topic.toLowerCase();
  if (t.contains('decimal')) return 'By the end, you should be able to identify each decimal place, align matching places, regroup correctly, and explain why the decimal point stays in the same column.';
  if (t.contains('fraction')) return 'By the end, you should be able to describe the numerator and denominator, choose the correct operation rule, simplify the result, and explain why the rule works.';
  if (t.contains('percentage')) return 'By the end, you should be able to identify the whole, the part, and the percentage relationship before choosing a calculation.';
  if (t.contains('ratio')) return 'By the end, you should be able to preserve matching ratio positions, create an equivalent ratio, and solve for an unknown reliably.';
  if (t.contains('average')) return 'By the end, you should be able to calculate a mean and explain why dividing the total by the number of values gives the equal share.';
  if (t.contains('algebra')) return 'By the end, you should be able to preserve balance, isolate the variable systematically, and verify the solution in the original equation.';
  if (t.contains('geometry')) return 'By the end, you should be able to choose the correct formula, substitute measurements with units, and distinguish area from perimeter.';
  if (t.contains('conversion')) return 'By the end, you should be able to choose a common unit, convert in the correct direction, and check whether the final number should be larger or smaller.';
  if (t.contains('exponent')) return 'By the end, you should be able to interpret an exponent as repeated multiplication and connect powers with their size.';
  if (t.contains('square root')) return 'By the end, you should be able to interpret a square root as the inverse of squaring and verify the answer by squaring it.';
  if (t.contains('order')) return 'By the end, you should be able to identify the operation priority and explain why changing the order can change the result.';
  return 'By the end, you should be able to explain the method, perform each step accurately, and verify the answer independently.';
}

String _masteryCheckForTopic(String topic) {
  final t = topic.toLowerCase();
  if (t.contains('decimal')) return 'Can you solve a new decimal question without looking at the worked example, then explain where any carry or regrouping came from?';
  if (t.contains('fraction')) return 'Can you explain why the denominators must match for addition/subtraction, or why the reciprocal appears in division?';
  if (t.contains('percentage')) return 'Can you identify which number is the whole, which is the part, and why the percentage is divided by 100?';
  if (t.contains('ratio')) return 'Can you explain why the same multiplier must be applied to both sides of the ratio?';
  if (t.contains('average')) return 'Can you explain why we divide the total by the number of data values rather than by one of the values?';
  if (t.contains('algebra')) return 'Can you explain why the same operation must be applied to both sides before isolating x?';
  if (t.contains('geometry')) return 'Can you choose the correct formula yourself and state the correct unit for the answer?';
  if (t.contains('order')) return 'Can you say which operation you would perform first and why, before calculating the answer?';
  return 'Can you solve a similar question without help and explain why each step is valid?';
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Learn', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)));
}

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Practice', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)));
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Progress', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)));
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '$title\nComing in the next MVP build',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}

List<BoxShadow> _softShadow() => const [BoxShadow(color: Color(0x1A22446B), blurRadius: 18, offset: Offset(0, 7))];
