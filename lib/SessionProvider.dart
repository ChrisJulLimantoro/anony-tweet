import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Create a class to hold the session data
class SessionProvider extends StatelessWidget {
  final Widget child;
  final Session session;
  final String? id;

  const SessionProvider({
    Key? key,
    required this.session,
    required this.id,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the session data down the widget tree
    return SessionContext(
      session: session,
      id: id ?? '',
      child: child,
    );
  }
}

// Context to hold the session
class SessionContext extends InheritedWidget {
  final Session session;
  final String id;

  SessionContext({
    required this.session,
    required this.id,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(SessionContext oldWidget) {
    return session != oldWidget.session;
  }

  static SessionContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SessionContext>();
  }
}
