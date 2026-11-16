import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_role_service.dart';
import '../ui/ui.dart';
import 'login_screen.dart';
import 'kepala_bengkel/kb_dashboard_screen.dart';
import 'login_screen.dart';
import 'partman/partman_dashboard_screen.dart';
import 'service_advisor/sa_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final Widget page;
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          page = const Scaffold(
            key: ValueKey('auth-loading'),
            body: PageSkeleton(),
          );
        } else {
          final user = authSnapshot.data;
          page = user == null
              ? const LoginScreen(key: ValueKey('login'))
              : _SignedInRouter(key: ValueKey(user.uid), user: user);
        }

        return _switchPage(page);
      },
    );
  }
}

class _SignedInRouter extends StatefulWidget {
  const _SignedInRouter({super.key, required this.user});

  final User user;

  @override
  State<_SignedInRouter> createState() => _SignedInRouterState();
}

class _SignedInRouterState extends State<_SignedInRouter> {
  late final Future<String?> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = UserRoleService().getRole(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _roleFuture,
      builder: (context, roleSnapshot) {
        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return _switchPage(
            const Scaffold(key: ValueKey('role-loading'), body: PageSkeleton()),
          );
        }

        final Widget page;
        switch (roleSnapshot.data) {
          case 'service_advisor':
            page = const SaDashboardScreen();
            break;
          case 'partman':
            page = const PartmanDashboardScreen();
            break;
          case 'kepala_bengkel':
            page = const KbDashboardScreen();
            break;
          default:
            page = Scaffold(
              backgroundColor: AppColors.canvas,
              body: Column(
                children: [
                  const Expanded(
                    child: AppContent(
                      maxWidth: 480,
                      child: EmptyState(
                        icon: Icons.lock_outline_rounded,
                        title: 'Akun belum memiliki peran',
                        message:
                            'Hubungi admin untuk mendaftarkan akun ini '
                            'dengan peran (role) tertentu.',
                      ),
                    ),
                  ),
                  AppContent(
                    maxWidth: 400,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: AppButton(
                        label: 'Keluar',
                        icon: Icons.logout_rounded,
                        variant: AppButtonVariant.outline,
                        onPressed: () => FirebaseAuth.instance.signOut(),
                      ),
                    ),
                  ),
                ],
              ),
            );
        }

        return _switchPage(
          KeyedSubtree(
            key: ValueKey(roleSnapshot.data ?? 'unknown-role'),
            child: page,
          ),
        );
      },
    );
  }
}

Widget _switchPage(Widget child) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 420),
    reverseDuration: const Duration(milliseconds: 280),
    switchInCurve: AppMotion.out,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: child,
  );
}
