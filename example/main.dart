import 'package:single_bloc_base/single_bloc_base.dart';

// ignore_for_file: unused_local_variable
Future<void> main() async {
  print("---------Simple Bloc---------");
  const simpleBloc = ExampleBloc();
  await simpleBloc.dispose();

  print("---------Simple Init---------");
  const simpleInit = ExampleInit();
  await simpleInit.init();

  print("---------Init Bloc---------");
  const initializableBloc = ExampleBlocWithInit();
  await initializableBloc.init();
  await initializableBloc.dispose();

  print("--------Hook Bloc----------");
  final hookBloc = ExampleHookBloc();
  await hookBloc.dispose();

  final hookBloc2 = ExampleHookBloc();
  await hookBloc2.dispose();

  print("---------Bagged Bloc---------");
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
  final MyOtherBloc otherBloc = MyOtherBloc(onInit: HookBloc.disposeBloc);
}

class MyOtherBloc extends BlocBase {
  MyOtherBloc({void Function(BlocBase) onInit}) {
    onInit(this);
  }

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
