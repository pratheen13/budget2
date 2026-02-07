import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:async';
import 'dart:convert';

/// Metallic gradients
const LinearGradient kSilverGradient = LinearGradient(
  colors: [
    Color(0xFFFDFDFD),
    Color(0xFFD0D0D0),
    Color(0xFF9A9A9A),
    Color(0xFFE8E8E8),
  ],
  stops: [0.0, 0.3, 0.7, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kChromeGradient = LinearGradient(
  colors: [
    Color(0xFFFDFDFD),
    Color(0xFFE5E5E5),
    Color(0xFF8A8A8A),
    Color(0xFFE5E5E5),
    Color(0xFFFDFDFD),
  ],
  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class WeekReport {
  final double spent;
  final double salary;
  final double limit;
  final double extra;
  final double net;
  final DateTime endDate;

  WeekReport({
    required this.spent,
    required this.salary,
    required this.limit,
    required this.extra,
    required this.net,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'spent': spent,
    'salary': salary,
    'limit': limit,
    'extra': extra,
    'net': net,
    'endDate': endDate.toIso8601String(),
  };

  factory WeekReport.fromJson(Map<String, dynamic> json) => WeekReport(
    spent: (json['spent'] ?? 0).toDouble(),
    salary: (json['salary'] ?? 0).toDouble(),
    limit: (json['limit'] ?? 0).toDouble(),
    extra: (json['extra'] ?? 0).toDouble(),
    net: (json['net'] ?? 0).toDouble(),
    endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
  );
}

/// NEW: model for “Gave money to other person”
class GivenMoney {
  final String name;
  final double amount;

  GivenMoney({
    required this.name,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
  };

  factory GivenMoney.fromJson(Map<String, dynamic> json) => GivenMoney(
    name: (json['name'] as String?) ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BudgetFlowApp());
}

class BudgetFlowApp extends StatelessWidget {
  const BudgetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A853),
          brightness: Brightness.dark,
          background: Colors.black,
          surface: const Color(0xFF111111),
        ),
        textTheme: ThemeData.dark()
            .textTheme
            .apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        )
            .copyWith(
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          bodyMedium: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Splash screen with animated logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BudgetHomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(127, 58, 43, 115),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050509),
              Color(0xFF151525),
              Color(0xFF050509),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD4A853),
                          Color(0xFFF4D03F),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A853).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedMetallicText(
                      'BUDGET FLOW',
                      gradient: kChromeGradient,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weekly money, under control',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _progressController;

  // Animated background gradient + blur
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  // STARTING VALUES: all zero for a fresh install
  double weeklyBudgetLimit = 0;
  double sliderValue = 0.0;
  bool autoAdd = true;

  bool isMonoTheme = false;
  double extraFunds = 0;

  double bankBalance = 0;
  double weeklySalary = 0;

  List<double> categoryAmounts = [0, 0, 0, 0];
  List<double> categoryLimits = [0, 0, 0, 0];

  /// 7‑day history of total spent per day for chart (Sun..Sat)
  List<double> weeklyDailySpent = [0, 0, 0, 0, 0, 0, 0];

  Timer? _weeklyTimer;
  int daysUntilReset = 7;
  int hoursRemaining = 24;

  List<WeekReport> weekReports = [];

  bool _showSalaryCredit = false;

  /// NEW: list of “gave money” entries
  List<GivenMoney> givenMoney = [];

  double get totalSpent =>
      categoryAmounts.isEmpty ? 0 : categoryAmounts.reduce((a, b) => a + b);

  double get spentPercentage =>
      weeklyBudgetLimit == 0 ? 0 : (totalSpent / weeklyBudgetLimit).clamp(0.0, 1.0);

  /// NEW: total given to other people
  double get totalGivenMoney =>
      givenMoney.fold(0.0, (p, e) => p + e.amount);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3400),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Background gradient + blur animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );

    _loadState();
    _startWeeklyTimer();
    _animateProgress();
  }

  void _startWeeklyTimer() {
    _weeklyTimer?.cancel();
    _weeklyTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      setState(() {
        hoursRemaining--;
        if (hoursRemaining <= 0) {
          hoursRemaining = 24;
          daysUntilReset--;
          if (daysUntilReset <= 0) {
            _resetWeekly();
            return;
          }
        }
      });
      _saveState();
    });
  }

  void _resetWeekly() {
    final double spentThisWeek = totalSpent;
    final double netThisWeek = weeklySalary - spentThisWeek;

    if (spentThisWeek > 0 || weeklySalary > 0) {
      final report = WeekReport(
        spent: spentThisWeek,
        salary: weeklySalary,
        limit: weeklyBudgetLimit,
        extra: extraFunds,
        net: netThisWeek,
        endDate: DateTime.now(),
      );

      weekReports.insert(0, report);
      if (weekReports.length > 4) {
        weekReports = weekReports.sublist(0, 4);
      }
    }

    final bool willAutoAdd = autoAdd && weeklySalary > 0;

    setState(() {
      if (willAutoAdd) {
        bankBalance += weeklySalary;
        _showSalaryCredit = true;
      }
      categoryAmounts = [0, 0, 0, 0];
      weeklyDailySpent = [0, 0, 0, 0, 0, 0, 0];
      daysUntilReset = 7;
      hoursRemaining = 24;
    });

    if (willAutoAdd) {
      Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _showSalaryCredit = false;
        });
      });
    }

    _animateProgress();
    HapticFeedback.mediumImpact();
    _saveState();
  }

  void _animateProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      bankBalance = prefs.getDouble('bankBalance') ?? bankBalance;
      weeklySalary = prefs.getDouble('weeklySalary') ?? weeklySalary;
      weeklyBudgetLimit =
          prefs.getDouble('weeklyBudgetLimit') ?? weeklyBudgetLimit;
      sliderValue = prefs.getDouble('sliderValue') ?? sliderValue;
      extraFunds = prefs.getDouble('extraFunds') ?? extraFunds;
      autoAdd = prefs.getBool('autoAdd') ?? autoAdd;
      isMonoTheme = prefs.getBool('isMonoTheme') ?? isMonoTheme;

      daysUntilReset = prefs.getInt('daysUntilReset') ?? daysUntilReset;
      hoursRemaining = prefs.getInt('hoursRemaining') ?? hoursRemaining;

      final catStrings = prefs.getStringList('categoryAmounts');
      if (catStrings != null && catStrings.length == categoryAmounts.length) {
        categoryAmounts = catStrings
            .map((e) => double.tryParse(e) ?? 0)
            .toList(growable: false);
      }

      final limitStrings = prefs.getStringList('categoryLimits');
      if (limitStrings != null && limitStrings.length == categoryLimits.length) {
        categoryLimits =
            limitStrings.map((e) => double.tryParse(e) ?? 0).toList(growable: false);
      }

      final dailyStrings = prefs.getStringList('weeklyDailySpent');
      if (dailyStrings != null &&
          dailyStrings.length == weeklyDailySpent.length) {
        weeklyDailySpent = dailyStrings
            .map((e) => double.tryParse(e) ?? 0)
            .toList(growable: false);
      }

      final historyJson = prefs.getString('weekReports');
      if (historyJson != null && historyJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(historyJson);
          weekReports = decoded
              .map((e) => WeekReport.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);
        } catch (_) {
          weekReports = [];
        }
      }

      // NEW: load givenMoney list
      final givenJson = prefs.getString('givenMoney');
      if (givenJson != null && givenJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(givenJson);
          givenMoney = decoded
              .map((e) => GivenMoney.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);
        } catch (_) {
          givenMoney = [];
        }
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bankBalance', bankBalance);
    await prefs.setDouble('weeklySalary', weeklySalary);
    await prefs.setDouble('weeklyBudgetLimit', weeklyBudgetLimit);
    await prefs.setDouble('sliderValue', sliderValue);
    await prefs.setDouble('extraFunds', extraFunds);
    await prefs.setBool('autoAdd', autoAdd);
    await prefs.setBool('isMonoTheme', isMonoTheme);

    await prefs.setInt('daysUntilReset', daysUntilReset);
    await prefs.setInt('hoursRemaining', hoursRemaining);

    await prefs.setStringList(
      'categoryAmounts',
      categoryAmounts.map((e) => e.toString()).toList(),
    );

    await prefs.setStringList(
      'categoryLimits',
      categoryLimits.map((e) => e.toString()).toList(),
    );

    await prefs.setStringList(
      'weeklyDailySpent',
      weeklyDailySpent.map((e) => e.toString()).toList(),
    );

    await prefs.setString(
      'weekReports',
      jsonEncode(weekReports.map((e) => e.toJson()).toList()),
    );

    // NEW: persist givenMoney
    await prefs.setString(
      'givenMoney',
      jsonEncode(givenMoney.map((e) => e.toJson()).toList()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    _bgController.dispose();
    _weeklyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        final t = _bgAnimation.value;

        final baseColors = isMonoTheme
            ? [Colors.black, Colors.black, Colors.black]
            : [
          const Color(0xFF050509),
          const Color(0xFF151525),
          const Color(0xFF050509),
        ];

        final altColors = isMonoTheme
            ? [Colors.black, Colors.black, Colors.black]
            : [
          const Color(0xFF090911),
          const Color(0xFF1E1E30),
          const Color(0xFF090911),
        ];

        final animatedColors = List<Color>.generate(
          3,
              (i) => Color.lerp(baseColors[i], altColors[i], t)!,
        );

        // Pulsing blur sigma for the background only (4–12)
        final blurSigma = 8 + 4 * math.sin(t * 2 * math.pi);

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: Stack(
            children: [
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurSigma,
                    sigmaY: blurSigma,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: animatedColors,
                      ),
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedTitle(),
              const SizedBox(height: 24),
              _buildAnimatedBalanceCard(),
              const SizedBox(height: 24),
              _buildWeeklyProgressSection(),
              const SizedBox(height: 24),
              _buildAnimatedCategoriesSection(),
              const SizedBox(height: 24),
              _buildWeeklyReportButton(),
              const SizedBox(height: 16),
              _buildAnimatedExtraBudgetSection(),
              const SizedBox(height: 24),
              _buildAnimatedBudgetSlider(),
              const SizedBox(height: 24),
              _buildGivenMoneySection(), // NEW SECTION
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -20),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 32),
            const Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedMetallicText(
                    'BUDGET FLOW',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => isMonoTheme = !isMonoTheme);
                HapticFeedback.selectionClick();
                _saveState();
              },
              icon: Icon(
                isMonoTheme
                    ? Icons.brightness_4_rounded
                    : Icons.brightness_7_rounded,
                size: 22,
              ),
              color: Colors.white.withOpacity(0.8),
              tooltip: 'Toggle black & white mode',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBudgetSlider() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 30),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WEEKLY BUDGET LIMIT',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: weeklyBudgetLimit),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return MetallicText(
                      '\$${value.toInt()}',
                      gradient: kSilverGradient,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassContainer(
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4A853),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: const Color(0xFFD4A853),
                    overlayColor: const Color(0xFFD4A853).withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: const _CustomThumbShape(),
                  ),
                  child: Slider(
                    value: sliderValue,
                    onChanged: (value) {
                      setState(() {
                        sliderValue = value;
                        weeklyBudgetLimit = 500 + (value * 1000);
                      });
                      _animateProgress();
                      HapticFeedback.lightImpact();
                      _saveState();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showWeeklyLimitSheet,
                child: const Text(
                  'Set custom weekly limit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bank balance card with static liquid glass capsule on the right
  Widget _buildAnimatedBalanceCard() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 30),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
          ),
        ),
        child: GlassContainer(
          borderRadius: 32,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Left side: text / controls
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MetallicText(
                        'BALANCE',
                        gradient: kChromeGradient,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showWeeklySalarySheet,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${weeklySalary.toInt()} / week',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _showExtraFundsSheet,
                        child: Text(
                          'Extra: \$${extraFunds.toInt()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1 + (_pulseController.value * 0.06),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => autoAdd = !autoAdd);
                                    HapticFeedback.mediumImpact();
                                    _saveState();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: autoAdd
                                          ? const Color(0xFF2D5016)
                                          : const Color(0xFF3C3C3E),
                                      borderRadius:
                                      BorderRadius.circular(999),
                                      border: Border.all(
                                        color: autoAdd
                                            ? const Color(0xFF4ADE80)
                                            : Colors.white24,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: autoAdd
                                                ? const Color(0xFF4ADE80)
                                                : Colors.white38,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'AUTO SALARY',
                                          style: TextStyle(
                                            color: autoAdd
                                                ? const Color(0xFF4ADE80)
                                                : Colors.white54,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Resets in: $daysUntilReset days ${hoursRemaining}h',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                      Colors.white.withOpacity(0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AnimatedOpacity(
                        opacity: _showSalaryCredit ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF4ADE80)
                                  .withOpacity(0.7),
                            ),
                          ),
                          child: Text(
                            '+\$${weeklySalary.toInt()} added',
                            style: const TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right side: static liquid glass balance capsule (tap to edit)
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: bankBalance),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    final formatted = value
                        .toInt()
                        .toString()
                        .replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                    );

                    final fill =
                    (value / (weeklyBudgetLimit + extraFunds + 1))
                        .clamp(0.0, 1.0);

                    return GestureDetector(
                      onTap: _showBankBalanceSheet, // NEW
                      child: GlassContainer(
                        borderRadius: 999,
                        child: SizedBox(
                          width: 150,
                          height: 56,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: const Size(
                                      double.infinity, double.infinity),
                                  painter: _StaticLiquidFillPainter(
                                    progress: fill,
                                    color:
                                    const Color.fromARGB(64, 9, 9, 9),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(999),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.03),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AnimatedMetallicText(
                                    '\$$formatted',
                                    gradient: kChromeGradient,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 30),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WEEKLY SPENDING',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder(
                              tween: Tween<double>(
                                  begin: 0, end: totalSpent),
                              duration: const Duration(
                                  milliseconds: 1500),
                              curve: Curves.easeOutCubic,
                              builder:
                                  (context, value, child) {
                                return MetallicText(
                                  '\$${value.toInt()}',
                                  gradient: kSilverGradient,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of \$${weeklyBudgetLimit.toInt()} spent',
                              style: TextStyle(
                                color: Colors.white
                                    .withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,
                                child:
                                CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 8,
                                  backgroundColor:
                                  Colors.transparent,
                                  valueColor:
                                  AlwaysStoppedAnimation(
                                    Colors.white
                                        .withOpacity(0.1),
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return SizedBox(
                                    width: 90,
                                    height: 90,
                                    child:
                                    CircularProgressIndicator(
                                      value: spentPercentage *
                                          _progressController
                                              .value,
                                      strokeWidth: 8,
                                      backgroundColor:
                                      Colors.transparent,
                                      valueColor:
                                      AlwaysStoppedAnimation(
                                        spentPercentage > 0.9
                                            ? const Color
                                            .fromARGB(
                                            250, 255, 1, 1)
                                            : spentPercentage > 0.7
                                            ? const Color(
                                            0xFFFFA726)
                                            : const Color
                                            .fromARGB(
                                            255,
                                            13,
                                            219,
                                            23),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              TweenAnimationBuilder(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: spentPercentage * 100,
                                ),
                                duration: const Duration(
                                    milliseconds: 1500),
                                curve: Curves.easeOutCubic,
                                builder:
                                    (context, value, child) {
                                  return MetallicText(
                                    '${value.toInt()}%',
                                    gradient: kChromeGradient,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.w700,
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),
                      child: Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.05),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                [_progressController, _waveController],
                              ),
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(
                                    MediaQuery.of(context)
                                        .size
                                        .width *
                                        spentPercentage *
                                        _progressController
                                            .value,
                                    24,
                                  ),
                                  painter: LiquidProgressPainter(
                                    progress: spentPercentage *
                                        _progressController
                                            .value,
                                    waveAnimation:
                                    _waveController
                                        .value,
                                    color: spentPercentage >
                                        0.9
                                        ? const Color
                                        .fromARGB(
                                        255, 255, 0, 0)
                                        : spentPercentage > 0.7
                                        ? const Color(
                                        0xFFFFA726)
                                        : const Color
                                        .fromARGB(
                                        255,
                                        14,
                                        218,
                                        25),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCategoriesSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 30),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CATEGORIES',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: totalSpent),
                  duration:
                  const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return MetallicText(
                      'Total: \$${value.toInt()}',
                      gradient: kSilverGradient,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [
                          FontFeature.tabularFigures()
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildCategoryRow(
                  index: 0,
                  emoji: '🍔',
                  title: 'FOOD',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFEE5A6F)
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryRow(
                  index: 1,
                  emoji: '🏠',
                  title: 'HOME',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4ECDC4),
                      Color(0xFF44A08D)
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryRow(
                  index: 2,
                  emoji: '🛍️',
                  title: 'SHOPPING',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF093FB),
                      Color(0xFFF5576C)
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoryRow(
                  index: 3,
                  emoji: '📦',
                  title: 'OTHER',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4FACFE),
                      Color(0xFF00F2FE)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow({
    required int index,
    required String emoji,
    required String title,
    required Gradient gradient,
  }) {
    final spent = categoryAmounts[index];
    final limit = categoryLimits[index];
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 120),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isMonoTheme
                      ? const LinearGradient(
                    colors: [
                      Color.fromARGB(0, 238, 8, 8),
                      Color(0xFF555555)
                    ],
                  )
                      : gradient,
                  boxShadow: [
                    BoxShadow(
                      color: (isMonoTheme
                          ? const Color(0xFF888888)
                          : gradient.colors.first)
                          .withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GlassContainer(
                  borderRadius: 24,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _showCategoryInputSheet(index, title),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              MetallicText(
                                '\$${spent.toInt()}',
                                gradient: kSilverGradient,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Limit: \$${limit.toInt()}',
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.5),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${(ratio * 100).toInt()}%',
                                style: TextStyle(
                                  color: ratio > 0.9
                                      ? const Color.fromARGB(
                                      255, 235, 4, 4)
                                      : ratio > 0.7
                                      ? const Color(
                                      0xFFFFA726)
                                      : const Color.fromARGB(
                                      255, 3, 230, 33),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(999),
                            child: Container(
                              height: 4,
                              color: Colors.white
                                  .withOpacity(0.08),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: ratio,
                                child: Container(
                                  color: ratio > 0.9
                                      ? const Color.fromARGB(
                                      255, 219, 17, 17)
                                      : ratio > 0.7
                                      ? const Color(
                                      0xFFFFA726)
                                      : const Color.fromARGB(
                                      255, 8, 245, 39),
                                ),
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
      },
    );
  }

  Widget _buildWeeklyReportButton() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showWeeklyReportSheet();
        },
        child: GlassContainer(
          borderRadius: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const MetallicText(
                        'Weekly Report',
                        gradient: kChromeGradient,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View your week and history',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedExtraBudgetSection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 30),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXTRA BUDGET',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showResetConfirmation();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4A853).withOpacity(
                            0.08 + (_pulseController.value * 0.06),
                          ),
                          const Color(0xFFD4A853).withOpacity(0.04),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4A853).withOpacity(
                          0.25 + (_pulseController.value * 0.15),
                        ),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A853).withOpacity(
                            0.05 + (_pulseController.value * 0.05),
                          ),
                          blurRadius: 12,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter:
                        ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient:
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFFD4A853),
                                      Color(0xFFF4D03F),
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4A853)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '🔄',
                                    style:
                                    TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const MetallicText(
                                      'Reset Weekly',
                                      gradient: kChromeGradient,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap to reset categories',
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color:
                                const Color(0xFFD4A853),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ========== NEW “GAVE MONEY” SECTION ==========

  Widget _buildGivenMoneySection() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 30),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GAVE MONEY',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: MetallicText(
                            'People you gave money to',
                            gradient: kSilverGradient,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        MetallicText(
                          '\$${totalGivenMoney.toInt()}',
                          gradient: kSilverGradient,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton.icon(
                          onPressed: _showGiveMoneySheet,
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: Color(0xFFD4A853),
                          ),
                          label: const Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD4A853),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (givenMoney.isEmpty)
                      Text(
                        'No entries yet. Tap Add to record money you gave.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      )
                    else
                      Column(
                        children: givenMoney
                            .asMap()
                            .entries
                            .map((e) {
                          final index = e.key;
                          final entry = e.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: GestureDetector(
                              onTap: () =>
                                  _showEditGivenMoneySheet(
                                      index, entry),
                              onLongPress: () =>
                                  _deleteGivenMoney(index),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.name,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  MetallicText(
                                    '\$${entry.amount.toInt()}',
                                    gradient: kSilverGradient,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.w700,
                                      fontFeatures: [
                                        FontFeature
                                            .tabularFigures()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SHEETS / DIALOGS ==========

  void _showResetConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MetallicText(
                    'RESET WEEKLY BUDGET?',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This will reset all categories to \$0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFD4A853),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            _resetWeekly();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryInputSheet(int index, String title) {
    final controller = TextEditingController(text: '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  MetallicText(
                    '$title BUDGET',
                    gradient: kChromeGradient,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter amount spent on $title',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFD4A853),
                            foregroundColor: Colors.black,
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            final text = controller.text
                                .replaceAll(',', '');
                            final value =
                            double.tryParse(text);
                            if (value != null && value > 0) {
                              setState(() {
                                categoryAmounts[index] +=
                                    value;
                                bankBalance = (bankBalance -
                                    value)
                                    .clamp(0, double.infinity);

                                final todayIndex =
                                    DateTime.now()
                                        .weekday %
                                        7;
                                weeklyDailySpent[
                                todayIndex] +=
                                    value;
                              });
                              _animateProgress();
                              HapticFeedback
                                  .mediumImpact();
                              _saveState();
                              Navigator.of(context).pop();
                            } else {
                              HapticFeedback
                                  .heavyImpact();
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWeeklyLimitSheet() {
    final controller = TextEditingController(
      text: weeklyBudgetLimit.toInt().toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const MetallicText(
                    'WEEKLY LIMIT',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter a custom weekly budget limit',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD4A853),
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text
                            .replaceAll(',', '');
                        final value =
                        double.tryParse(text);
                        if (value != null && value > 0) {
                          setState(() {
                            weeklyBudgetLimit = value;
                            sliderValue =
                                ((weeklyBudgetLimit - 500) /
                                    1000)
                                    .clamp(0.0, 1.0);
                          });
                          _animateProgress();
                          HapticFeedback
                              .mediumImpact();
                          _saveState();
                          Navigator.of(context).pop();
                        } else {
                          HapticFeedback
                              .heavyImpact();
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWeeklyReportSheet() {
    final remaining =
    (weeklyBudgetLimit - totalSpent).clamp(0, double.infinity);
    final netChange = weeklySalary - totalSpent;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const MetallicText(
                      'WEEKLY REPORT',
                      gradient: kChromeGradient,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See this week and your last 4 weeks together',
                      style: TextStyle(
                        color:
                        Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Current week',
                      style: TextStyle(
                        color:
                        Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      child: Padding(
                        padding:
                        const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildReportRow(
                              label: 'Total spent',
                              value: totalSpent,
                              valueColor:
                              const Color(0xFFFFA726),
                            ),
                            _buildReportRow(
                              label: 'Remaining budget',
                              value: remaining.toDouble(),
                              valueColor:
                              const Color(0xFF4ADE80),
                            ),
                            _buildReportRow(
                              label: 'Weekly salary',
                              value: weeklySalary,
                              valueColor:
                              const Color(0xFF93C5FD),
                            ),
                            _buildReportRow(
                              label: 'Extra funds',
                              value: extraFunds,
                              valueColor:
                              const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(height: 6),
                            _buildReportRow(
                              label: 'Net this week',
                              value: netChange,
                              valueColor: netChange >= 0
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFFF6B6B),
                              showSign: true,
                              emphasize: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Day by day spending',
                      style: TextStyle(
                        color:
                        Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GlassContainer(
                      borderRadius: 18,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: WeeklyBarChart(
                          values: weeklyDailySpent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (weekReports.isNotEmpty) ...[
                      Text(
                        'Past weeks',
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(
                          weekReports.length.clamp(0, 4),
                              (index) {
                            final report =
                            weekReports[index];
                            final weekLabel =
                                'Week -${index + 1}';
                            final dateLabel =
                                '${report.endDate.month}/${report.endDate.day}/${report.endDate.year.toString().substring(2)}';

                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                  bottom: 10),
                              child: GlassContainer(
                                borderRadius: 16,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.all(
                                      14),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          MetallicText(
                                            weekLabel,
                                            gradient:
                                            kSilverGradient,
                                            style:
                                            const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight
                                                  .w700,
                                            ),
                                          ),
                                          Text(
                                            dateLabel,
                                            style:
                                            TextStyle(
                                              color: Colors
                                                  .white
                                                  .withOpacity(
                                                  0.5),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: 8),
                                      _buildReportRow(
                                        label: 'Spent',
                                        value:
                                        report.spent,
                                        valueColor:
                                        const Color(
                                            0xFFFFA726),
                                      ),
                                      _buildReportRow(
                                        label: 'Limit',
                                        value:
                                        report.limit,
                                        valueColor: Colors
                                            .white
                                            .withOpacity(
                                            0.9),
                                      ),
                                      _buildReportRow(
                                        label: 'Salary',
                                        value:
                                        report.salary,
                                        valueColor:
                                        const Color(
                                            0xFF93C5FD),
                                      ),
                                      _buildReportRow(
                                        label: 'Net',
                                        value:
                                        report.net,
                                        valueColor: report
                                            .net >=
                                            0
                                            ? const Color(
                                            0xFF4ADE80)
                                            : const Color(
                                            0xFFFF6B6B),
                                        showSign: true,
                                        emphasize: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Text(
                        'No past weeks yet. Finish this week to start building history.',
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.45),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Auto‑saved to this device',
                        style: TextStyle(
                          color:
                          Colors.white.withOpacity(0.35),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.white12,
                          foregroundColor:
                          Colors.white,
                          padding:
                          const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportRow({
    required String label,
    required double value,
    required Color valueColor,
    bool showSign = false,
    bool emphasize = false,
  }) {
    final sign = showSign && value > 0 ? '+' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(
                  emphasize ? 0.8 : 0.6),
              fontSize: emphasize ? 13 : 12,
              fontWeight: emphasize
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
          ),
          MetallicText(
            '$sign\$${value.toInt()}',
            gradient: LinearGradient(
              colors: [
                valueColor.withOpacity(0.9),
                valueColor.withOpacity(0.7),
              ],
            ),
            style: TextStyle(
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize
                  ? FontWeight.w700
                  : FontWeight.w600,
              fontFeatures: const [
                FontFeature.tabularFigures()
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExtraFundsSheet() {
    final controller = TextEditingController(
      text: extraFunds.toInt().toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const MetallicText(
                    'EXTRA FUNDS',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set an additional safety buffer on top of your balance',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD4A853),
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text
                            .replaceAll(',', '');
                        final value =
                        double.tryParse(text);
                        if (value != null && value >= 0) {
                          setState(() {
                            extraFunds = value;
                          });
                          HapticFeedback
                              .mediumImpact();
                          _saveState();
                          Navigator.of(context).pop();
                        } else {
                          HapticFeedback
                              .heavyImpact();
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWeeklySalarySheet() {
    final controller = TextEditingController(
      text: weeklySalary.toInt().toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const MetallicText(
                    'WEEKLY SALARY',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Amount that auto‑adds to your balance each reset',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD4A853),
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text
                            .replaceAll(',', '');
                        final value =
                        double.tryParse(text);
                        if (value != null && value >= 0) {
                          setState(() {
                            weeklySalary = value;
                          });
                          HapticFeedback
                              .mediumImpact();
                          _saveState();
                          Navigator.of(context).pop();
                        } else {
                          HapticFeedback
                              .heavyImpact();
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// NEW: Set custom bank balance
  void _showBankBalanceSheet() {
    final controller = TextEditingController(
      text: bankBalance.toInt().toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const MetallicText(
                    'BANK BALANCE',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set your current bank balance.',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD4A853),
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text
                            .replaceAll(',', '');
                        final value =
                        double.tryParse(text);
                        if (value != null && value >= 0) {
                          setState(() {
                            bankBalance = value;
                          });
                          HapticFeedback
                              .mediumImpact();
                          _saveState();
                          Navigator.of(context).pop();
                        } else {
                          HapticFeedback
                              .heavyImpact();
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// NEW: Add a “gave money” entry
  void _showGiveMoneySheet() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const MetallicText(
                    'GAVE MONEY',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the person name and the amount you gave.',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    textCapitalization:
                    TextCapitalization.words,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD4A853),
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final name =
                        nameController.text.trim();
                        final text = amountController.text
                            .replaceAll(',', '');
                        final amount =
                        double.tryParse(text);

                        if (name.isNotEmpty &&
                            amount != null &&
                            amount > 0) {
                          setState(() {
                            givenMoney = [
                              ...givenMoney,
                              GivenMoney(
                                name: name,
                                amount: amount,
                              ),
                            ];
                            bankBalance = (bankBalance -
                                amount)
                                .clamp(0, double.infinity);
                          });
                          HapticFeedback
                              .mediumImpact();
                          _saveState();
                          Navigator.of(context).pop();
                        } else {
                          HapticFeedback
                              .heavyImpact();
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// NEW: edit “gave money” entry
  void _showEditGivenMoneySheet(int index, GivenMoney entry) {
    final nameController =
    TextEditingController(text: entry.name);
    final amountController =
    TextEditingController(text: entry.amount.toInt().toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom:
            MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: GlassContainer(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const MetallicText(
                    'EDIT ENTRY',
                    gradient: kChromeGradient,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Update the name or amount.',
                    style: TextStyle(
                      color:
                      Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    textCapitalization:
                    TextCapitalization.words,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFD4A853),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor:
                      Colors.white.withOpacity(0.06),
                      hintText: '0',
                      hintStyle: TextStyle(
                        color:
                        Colors.white.withOpacity(0.35),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white
                              .withOpacity(0.18),
                        ),
                      ),
                      focusedBorder:
                      const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Color(0xFFD4A853),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFD4A853),
                        foregroundColor: Colors.black,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final name =
                        nameController.text.trim();
                        final text = amountController.text
                            .replaceAll(',', '');
                        final newAmount =
                        double.tryParse(text);

                        if (name.isNotEmpty &&
                            newAmount != null &&
                            newAmount > 0) {
                          setState(() {
                            // adjust balance: add back old, subtract new
                            bankBalance = (bankBalance +
                                entry.amount -
                                newAmount)
                                .clamp(
                                0, double.infinity);

                            givenMoney[index] = GivenMoney(
                              name: name,
                              amount: newAmount,
                            );
                          });
                          HapticFeedback
                              .mediumImpact();
                          _saveState();
                          Navigator.of(context).pop();
                        } else {
                          HapticFeedback
                              .heavyImpact();
                        }
                      },
                      child: const Text(
                        'Save changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// NEW: delete “gave money” entry
  void _deleteGivenMoney(int index) {
    final entry = givenMoney[index];
    setState(() {
      bankBalance += entry.amount; // add money back
      givenMoney = List.of(givenMoney)..removeAt(index);
    });
    HapticFeedback.mediumImpact();
    _saveState();
  }
}

// ================== PAINTERS & GLASS UI HELPERS ==================

/// Liquid progress painter (weekly bar) with softer glow
class LiquidProgressPainter extends CustomPainter {
  final double progress;
  final double waveAnimation;
  final Color color;

  LiquidProgressPainter({
    required this.progress,
    required this.waveAnimation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveWidth = size.width * progress;
    final waveHeight = 4.0;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i <= waveWidth; i++) {
      final x = i;
      final y = size.height / 2 +
          math.sin((i / 20) + (waveAnimation * 2 * math.pi)) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(waveWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(LiquidProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveAnimation != waveAnimation;
  }
}

/// Static liquid fill for balance capsule (no wave, subtle glow)
class _StaticLiquidFillPainter extends CustomPainter {
  final double progress;
  final Color color;

  _StaticLiquidFillPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final width = size.width * progress;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, size.height),
      const Radius.circular(999),
    );

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.6),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect.outerRect);
    canvas.drawRRect(rect, paint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(rect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _StaticLiquidFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

/// Weekly bar chart (day‑by‑day, color vs average)
class WeeklyBarChart extends StatelessWidget {
  final List<double> values; // length 7, Sun..Sat

  const WeeklyBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _WeeklyBarChartPainter(values),
        child: Container(),
      ),
    );
  }
}

class _WeeklyBarChartPainter extends CustomPainter {
  final List<double> values;
  _WeeklyBarChartPainter(this.values);

  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.fold<double>(0, (p, e) => e > p ? e : p);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    if (maxVal <= 0) {
      for (int i = 0; i < values.length; i++) {
        final barWidth = size.width / (values.length * 1.6);
        final spacing = barWidth * 0.6;
        final x =
            spacing / 2 + i * (barWidth + spacing) + barWidth / 2;
        textPainter.text = TextSpan(
          text: _dayLabels[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - 16),
        );
      }
      return;
    }

    final avg =
        values.reduce((a, b) => a + b) / values.length;
    final barWidth = size.width / (values.length * 1.6);
    final spacing = barWidth * 0.6;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x =
          spacing / 2 + i * (barWidth + spacing) + barWidth / 2;
      final ratio = (values[i] / maxVal).clamp(0.0, 1.0);
      final barHeight = (size.height - 24) * ratio;

      Color baseColor;
      if (values[i] <= avg) {
        baseColor = const Color.fromARGB(255, 33, 219, 39);
      } else if (values[i] <= avg * 1.5) {
        baseColor = const Color.fromARGB(255, 193, 245, 7);
      } else {
        baseColor = const Color.fromARGB(157, 250, 0, 0);
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - barWidth / 2,
          size.height - 20 - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(6),
      );

      paint.shader = LinearGradient(
        colors: [
          baseColor.withOpacity(0.95),
          baseColor.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);

      final glowPaint = Paint()
        ..color = baseColor.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal, 6);
      canvas.drawRRect(rect, glowPaint);

      textPainter.text = TextSpan(
        text: _dayLabels[i],
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

// Glass container with depth and soft glow
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter:
          ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1C1C1E)
                      .withOpacity(0.85),
                  const Color(0xFF1C1C1E)
                      .withOpacity(0.5),
                ],
              ),
              borderRadius:
              BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 0.8,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white
                                .withOpacity(0.18),
                            Colors.white
                                .withOpacity(0.02),
                            Colors.transparent,
                          ],
                          stops: const [
                            0.0,
                            0.35,
                            1.0
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black
                                .withOpacity(0.32),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(32, 32);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final glowPaint = Paint()
      ..color = const Color(0xFFD4A853)
          .withOpacity(0.22 * activationAnimation.value)
      ..maskFilter =
      const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 16, glowPaint);

    final outerPaint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 16, outerPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFD4A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, 16, borderPaint);

    final innerGradient = const RadialGradient(
      colors: [
        Color.fromARGB(255, 230, 225, 213),
        Color.fromARGB(255, 208, 203, 192),
      ],
    );
    final innerPaint = Paint()
      ..shader = innerGradient.createShader(
        Rect.fromCircle(center: center, radius: 8),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, innerPaint);

    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center - const Offset(-3, -3), 3, shinePaint);
  }
}

// Static metallic text with soft shadow
class MetallicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const MetallicText(
      this.text, {
        super.key,
        required this.gradient,
        this.style,
      });

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: Colors.black38,
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: baseStyle.merge(style),
      ),
    );
  }
}

// Animated metallic text with moving light glow
class AnimatedMetallicText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final Duration duration;

  const AnimatedMetallicText(
      this.text, {
        super.key,
        required this.gradient,
        this.style,
        this.duration = const Duration(milliseconds: 2600),
      });

  @override
  State<AnimatedMetallicText> createState() =>
      _AnimatedMetallicTextState();
}

class _AnimatedMetallicTextState
    extends State<AnimatedMetallicText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: Colors.black38,
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ).merge(widget.style);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final width = bounds.width;
            final dx =
                (width * 2) * _controller.value - width;
            return widget.gradient.createShader(
              Rect.fromLTWH(dx, 0, width * 3, bounds.height),
            );
          },
          child: Text(
            widget.text,
            style: baseStyle,
          ),
        );
      },
    );
  }
}
