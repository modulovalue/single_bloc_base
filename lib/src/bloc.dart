import 'dart:async';

import 'package:meta/meta.dart';

/// Base interface for objects that can be disposed.
abstract class BlocBase {
  Future<void> dispose();
}

/// Base interface for objects that can be initialized.
abstract class InitBase {
  Future<void> init();
}

/// Base interface for objects that can be initialized and disposed.
abstract class InitBloc implements BlocBase, InitBase {}

/// Base class for objects that can collect initialization and disposal methods.
class BaggedInitBloc implements InitBloc {
  final List<Future<void> Function()> onInit = [];

  final List<Future<void> Function()> onDispose = [];

  T bagState<T extends InitBloc>(T t) {
    disposeLater(t.dispose);
    initLater(t.init);
    return t;
  }

  T bagBloc<T extends BlocBase>(T t) {
    disposeLater(t.dispose);
    return t;
  }

  void disposeLater(FutureOr<void> Function() dispose) {
    onDispose.add(() async => await dispose());
  }

  void initLater(FutureOr<void> Function() init) {
    onInit.add(() async => await init());
  }

  @override
  @mustCallSuper
  Future<void> init() async {
    await Future.forEach(onInit, (Future<void> Function() a) => a());
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await Future.forEach(onDispose, (Future<void> Function() a) => a());
  }
}

/// Makes initializers disposable by moving the disposal
/// process to the next microtask.
class HookBloc implements BlocBase {
  static HookBloc _context;

  /// You must call [disposeSink] before the constructor is called.
  /// That means calling HookBloc.disposeSink like in the following example:
  ///
  /// ```
  /// final SomeObject object = SomeObject(onInit: HookBloc.disposeSink);
  /// ```
  static T disposeSink<T extends Sink<dynamic>>(T sink) {
    disposeEffect<T>(sink, (a) async => sink.close());
    return sink;
  }

  /// See [disposeSink]
  static T disposeBloc<T extends BlocBase>(T bloc) {
    disposeEffect<T>(bloc, (a) => a.dispose());
    return bloc;
  }

  /// See [disposeSink]
  static T disposeEffect<T>(T t, Future<void> Function(T) effect) {
    scheduleMicrotask(() {
      if (_context != null) {
        _context.disposeLater(() => effect(t));
      } else {
        throw Exception(
            "HookBloc.disposeSink used outside of class member contructor.");
      }
    });
    return t;
  }

  HookBloc() {
    _context = this;
  }

  final List<Future<void> Function()> onDispose = [];

  void disposeSinkLater(Sink sink) {
    onDispose.add(() async => sink.close());
  }

  void disposeLater(void Function() dispose) {
    onDispose.add(() async => dispose());
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    scheduleMicrotask(() async {
      await Future.forEach(onDispose, (Future<void> Function() a) => a());
    });
    scheduleMicrotask(() async {
      _context = null;
    });
  }
}
