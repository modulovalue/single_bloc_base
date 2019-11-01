import 'dart:async';
import 'package:single_bloc_base/single_bloc_base.dart';
import 'package:test/test.dart';

List<String> events = [];

void main() {
  group("$BlocBase", () {
    /// Nothing to test
    final _BlocBase _ = _BlocBase();
  });

  group("$HookBloc", () {
    test("$_ConstructorCall", () async {
      events = [];
      final bloc1 = _HookBlocBase1();
      final bloc2 = _HookBlocBase2();

      await bloc1.dispose();
      await bloc2.dispose();

      await pumpEventQueue();
      scheduleMicrotask(() {
        expect(events, [
          "pre dispose _HookBlocBase1",
          "post dispose _HookBlocBase1",
          "pre dispose _HookBlocBase2",
          "closing _HookBlocBase1",
          "post dispose _HookBlocBase2",
          "closing _HookBlocBase2",
        ]);
      });
    });
  });

  group("$BaggedInitBloc", () {
    test("bagState", () async {
      int isDisposed = 0;
      int isInitialized = 0;
      final _TestBaggedInitBlocBase sut =
          _TestBaggedInitBlocBase();
      // ignore: invalid_use_of_protected_member
      sut.bagState(_AnonTestInitBloc(
          () => isDisposed++, () => isInitialized++));

      await sut.init();
      expect(isDisposed, 0);
      expect(isInitialized, 1);
      await sut.dispose();
      expect(isDisposed, 1);
      expect(isInitialized, 1);
    });
    test("disposeLater", () async {
      int isDisposed = 0;
      final _TestBaggedInitBlocBase sut =
          _TestBaggedInitBlocBase();
      // ignore: invalid_use_of_protected_member
      sut.disposeLater(() => isDisposed++);

      expect(isDisposed, 0);
      await sut.dispose();
      expect(isDisposed, 1);
    });
  });
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

class _BlocBase extends BlocBase {
  @override
  Future<void> dispose() async {}
}

class _HookBlocBase1 extends HookBloc {
  // ignore: close_sinks
  final _ConstructorCall a =
      _ConstructorCall("_HookBlocBase1", HookBloc.disposeSink);

  @override
  Future dispose() async {
    events.add("pre dispose _HookBlocBase1");
    await super.dispose();
    events.add("post dispose _HookBlocBase1");
  }
}

class _HookBlocBase2 extends HookBloc {
  // ignore: close_sinks
  final _ConstructorCall a =
      _ConstructorCall("_HookBlocBase2", HookBloc.disposeSink);

  @override
  Future dispose() async {
    events.add("pre dispose _HookBlocBase2");
    await super.dispose();
    events.add("post dispose _HookBlocBase2");
  }
}

class _ConstructorCall extends Sink<dynamic> {
  final String str;

  _ConstructorCall(this.str, void Function(_ConstructorCall) onInit) {
    onInit(this);
  }

  @override
  void add(dynamic data) {}

  @override
  void close() => events.add("closing $str");
}
