import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class ConsoleLoggingBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) print("Error: $error; Stack Trace: $stackTrace");
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) print("Transition: $transition");
  }
}
