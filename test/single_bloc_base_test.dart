import 'dart:async';
import 'package:single_bloc_base/single_bloc_base.dart';
import 'package:test/test.dart';

List<String> _events = [];

void main() {
  group("$BlocBase", () {
    // Nothing to test
    final sut = _BlocBase();
    // for coverage, nothing to test
    test("dispose", () async {
      await sut.dispose();
    });
  });

  group("$InitBase", () {
    /// Nothing to test
    final _ = _InitBase();
  });

  group("$InitBloc", () {
    /// Nothing to test
    final _ = _InitBloc();
  });

  group("$BaggedInitBloc", () {
    test("bagState", () async {
      int isDisposed = 0;
      int isInitialized = 0;
      final sut = _TestBaggedInitBlocBase();
      sut.bagState(
        _AnonTestInitBloc(
          () => isDisposed++,
          () => isInitialized++,
        ),
      );

      await sut.init();
      expect(isDisposed, 0);
      expect(isInitialized, 1);
      await sut.dispose();
      expect(isDisposed, 1);
      expect(isInitialized, 1);
    });
    test("bagBloc", () async {
      int isDisposed = 0;
      final sut = _TestBaggedInitBlocBase();
      sut.bagBloc(_BlocBase(() => isDisposed++));

      expect(isDisposed, 0);
      await sut.dispose();
      expect(isDisposed, 1);
    });
    test("disposeLater", () async {
      int isDisposed = 0;
      final _TestBaggedInitBlocBase sut = _TestBaggedInitBlocBase();
      // ignore: invalid_use_of_protected_member
      sut.disposeLater(() => isDisposed++);

      expect(isDisposed, 0);
      await sut.dispose();
      expect(isDisposed, 1);
    });
    test("initLater", () async {
      int isInitialized = 0;
      final _TestBaggedInitBlocBase sut = _TestBaggedInitBlocBase();
      // ignore: invalid_use_of_protected_member
      sut.initLater(() => isInitialized++);

      expect(isInitialized, 0);
      await sut.init();
      expect(isInitialized, 1);
    });
  });

  group("$HookBloc", () {
    test("$_ConstructorCall", () async {
      _events = [];
      final bloc1 = _HookBlocBase1();
      final bloc2 = _HookBlocBase2();

      await bloc1.dispose();
      await bloc2.dispose();

      await pumpEventQueue();
      scheduleMicrotask(() {
        expect(_events, [
          "pre dispose _HookBlocBase1",
          "post dispose _HookBlocBase1",
          "pre dispose _HookBlocBase2",
          "closing _HookBlocBase1",
          "post dispose _HookBlocBase2",
          "closing _HookBlocBase2",
        ]);
      });
    });
    test("disposeSinkLater", () async {
      _events = [];
      final bloc1 = _HookBloc();
      var closed = 0;
      bloc1.disposeSinkLater(_Sink(() => closed++));
      await bloc1.dispose();
      expect(closed, 1);
    });
  });
}

class _BlocBase implements BlocBase {
  final void Function() _dispose;

  _BlocBase([this._dispose]);

  @override
  Future<void> dispose() async => _dispose?.call();
}

class _InitBase extends InitBase {
  @override
  Future<void> init() async {}
}

class _InitBloc extends InitBloc {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}
}

class _AnonTestInitBloc extends InitBloc {
  final void Function() _dispose;
  final void Function() _init;

  _AnonTestInitBloc(this._dispose, this._init);

  @override
  Future<void> dispose() async => _dispose();

  @override
  Future<void> init() async => _init();
}

class _TestBaggedInitBlocBase extends BaggedInitBloc {}

class _HookBloc extends HookBloc {}

class _Sink implements Sink<String> {
  final void Function() _close;

  _Sink(this._close);

  @override
  Future<void> add(String data) async {}

  @override
  void close() => _close();
}

class _HookBlocBase1 extends HookBloc {
  // ignore: close_sinks
  final _ConstructorCall a =
      _ConstructorCall("_HookBlocBase1", HookBloc.disposeSink);

  @override
  Future dispose() async {
    _events.add("pre dispose _HookBlocBase1");
    await super.dispose();
    _events.add("post dispose _HookBlocBase1");
  }
}

class _HookBlocBase2 extends HookBloc {
  // ignore: close_sinks
  final _ConstructorCall a =
      _ConstructorCall("_HookBlocBase2", HookBloc.disposeBloc);

  @override
  Future dispose() async {
    _events.add("pre dispose _HookBlocBase2");
    await super.dispose();
    _events.add("post dispose _HookBlocBase2");
  }
}

class _ConstructorCall extends Sink<dynamic> implements BlocBase {
  final String str;

  _ConstructorCall(this.str, void Function(_ConstructorCall) onInit) {
    onInit(this);
  }

  @override
  void add(dynamic data) {}

  @override
  void close() => _events.add("closing $str");

  @override
  Future<void> dispose() async {
    _events.add("closing $str");
  }
}
