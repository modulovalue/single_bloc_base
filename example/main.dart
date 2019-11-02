import 'package:single_bloc_base/single_bloc_base.dart';

// ignore_for_file: unused_local_variable
Future<void> main() async {
  const simpleBloc = ExampleBloc();
  await simpleBloc.dispose();

  const simpleInit = ExampleInit();
  await simpleInit.init();

  const initBloc = ExampleBlocWithInit();
  await initBloc.init();
  await initBloc.dispose();

  final hookBloc = ExampleHookBloc();
  await hookBloc.dispose();

  final hookBloc2 = ExampleHookBloc();
  await hookBloc2.dispose();

  final baggedBloc = ExampleBaggedBloc(
    [const ExampleBloc(), ExampleHookBloc()],
    [const ExampleBlocWithInit()],
  );
  await baggedBloc.init();
  await baggedBloc.dispose();
}

class ExampleBloc implements BlocBase {
  const ExampleBloc();

  @override
  Future<void> dispose() async {
    print("ExampleBloc dispose");
  }
}

class ExampleInit implements InitBase {
  const ExampleInit();

  @override
  Future<void> init() async {
    print("ExampleInit dispose");
  }
}

class ExampleBlocWithInit implements InitBloc {
  const ExampleBlocWithInit();

  @override
  Future<void> dispose() async {
    print("ExampleBlocWithInit dispose");
  }

  @override
  Future<void> init() async {
    print("ExampleBlocWithInit init");
  }
}

class ExampleHookBloc extends HookBloc {
  final MyOtherBloc otherBloc = HookBloc.disposeBloc(MyOtherBloc());
}

class MyOtherBloc extends BlocBase {
  MyOtherBloc() {}

  @override
  Future<void> dispose() async {
    print("MyOtherBloc dispose");
  }
}

class ExampleBaggedBloc extends BaggedInitBloc {
  ExampleBaggedBloc(
      Iterable<BlocBase> blocs, Iterable<InitBloc> initializableBlocs) {
    blocs.forEach(bagBloc);
    initializableBlocs.forEach(bagState);
    disposeLater(() => print("dispose me later"));
    initLater(() => print("init me later"));
  }
}
