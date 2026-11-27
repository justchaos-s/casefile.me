import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../theme.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200))
    ..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const AuthGate(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, .5, curve: Curves.easeOut));
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                border: Border.all(color: C.red, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fingerprint, size: 44, color: C.red),
            ),
            const SizedBox(height: 22),
            const Text('CASEFILE',
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 8)),
            const SizedBox(height: 8),
            Text('Digital investigation workspace',
                style: mono(12, C.muted)),
            const SizedBox(height: 36),
            // the one animated element: an "evidence loading" line
            SizedBox(
              width: 160,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => LinearProgressIndicator(
                  value: _ctrl.value,
                  minHeight: 2,
                  color: C.red,
                  backgroundColor: C.border,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
