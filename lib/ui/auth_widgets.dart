import 'package:flutter/material.dart';

import 'app_theme.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: wide ? 520 : 270),
      padding: EdgeInsets.fromLTRB(30, wide ? 48 : 30, 30, wide ? 48 : 32),
      decoration: const BoxDecoration(color: Color(0xFF202923)),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: -55,
              top: wide ? 30 : 4,
              child: IgnorePointer(
                child: SizedBox(
                  width: wide ? 310 : 210,
                  height: wide ? 310 : 210,
                  child: CustomPaint(painter: _WorkshopMarkPainter()),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amberBright,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PRABU PURA MOTOR   /   KARAWANG',
                      style: TextStyle(
                        color: AppColors.onHeaderMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.55,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: wide ? 76 : 42),
                Container(width: 30, height: 2, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text(
                  'SPK WIP',
                  style: TextStyle(
                    color: AppColors.onHeaderPrimary,
                    fontSize: 43,
                    height: 1,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1.9,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bodi & Cat',
                  style: TextStyle(
                    color: AppColors.onHeaderMuted,
                    fontSize: 17,
                    fontWeight: FontWeight.w300,
                    letterSpacing: .1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data unit dan proses bengkel dalam satu ruang kerja.',
                  style: TextStyle(
                    color: AppColors.onHeaderMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = const Color(0x1FFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(center, size.width * (.2 + i * .105), stroke);
    }
    final line = Paint()
      ..color = const Color(0x29D6AA68)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), line);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginCard extends StatelessWidget {
  const LoginCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(23, 24, 23, 20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8E5DD)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A202522),
          blurRadius: 28,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class LoginGreeting extends StatelessWidget {
  const LoginGreeting({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Masuk',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -.8,
        ),
      ),
      SizedBox(height: 6),
      Text(
        'Gunakan akun kerja Anda untuk melanjutkan.',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: AppColors.textMuted,
        ),
      ),
    ],
  );
}

class CapsLabel extends StatelessWidget {
  const CapsLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.textMuted,
      letterSpacing: 1.15,
    ),
  );
}

InputDecoration emailInputDecoration({bool focused = false}) =>
    _loginInputDecoration(hintText: 'nama@perusahaan.com', focused: focused);

InputDecoration passwordInputDecoration({
  required bool obscure,
  required VoidCallback onToggle,
  bool focused = false,
}) => _loginInputDecoration(
  hintText: 'Masukkan kata sandi',
  focused: focused,
  suffixIcon: IconButton(
    tooltip: obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
    icon: Icon(
      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      color: AppColors.textMuted,
      size: 19,
    ),
    onPressed: onToggle,
  ),
);

InputDecoration _loginInputDecoration({
  required String hintText,
  required bool focused,
  Widget? suffixIcon,
}) => InputDecoration(
  hintText: hintText,
  hintStyle: _inputHintStyle,
  suffixIcon: suffixIcon,
  filled: _inputFilled,
  fillColor: _inputFillColor(focused),
  contentPadding: _inputContentPadding,
  border: _inputBorder(focused: focused),
  enabledBorder: _inputBorder(focused: focused),
  focusedBorder: _inputBorder(focused: true),
  errorBorder: _inputBorder(error: true),
  focusedErrorBorder: _inputBorder(error: true),
);

const _inputHintStyle = TextStyle(color: AppColors.textMuted, fontSize: 13);
const _inputFilled = true;
const _inputContentPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 15);

Color _inputFillColor(bool focused) =>
    focused ? const Color(0xFFFFFEFC) : AppColors.fieldFill;

OutlineInputBorder _inputBorder({bool focused = false, bool error = false}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: error
            ? AppColors.danger
            : focused
            ? AppColors.accentDark
            : AppColors.border,
        width: focused || error ? 1.5 : 1,
      ),
    );

class LoginErrorBanner extends StatelessWidget {
  const LoginErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.dangerSoft,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: AppColors.danger.withValues(alpha: .24)),
    ),
    child: Text(
      message,
      style: const TextStyle(
        color: AppColors.dangerText,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class GradientLoginButton extends StatefulWidget {
  const GradientLoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<GradientLoginButton> createState() => _GradientLoginButtonState();
}

class _GradientLoginButtonState extends State<GradientLoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (hovering) => setState(() => _pressed = hovering),
        onFocusChange: (focused) => setState(() => _pressed = focused),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedScale(
          scale: _pressed ? .985 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pressed ? const Color(0xFF34443A) : AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryDark),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, .12),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      key: ValueKey('spinner'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Row(
                      key: ValueKey('text'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Masuk',
                          style: TextStyle(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            letterSpacing: .25,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.surface,
                          size: 17,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}
