import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A generic base view that wires a [GetxController] to a Flutter widget tree.
///
/// Lifecycle callbacks mirror those of the original `travel_mate` architecture
/// so the [Onboarding] screen can be dropped in without changes.
class BaseView<T extends GetxController> extends StatefulWidget {
  const BaseView({
    super.key,
    required this.view,
    this.onInit,
    this.onResumed,
    this.onPaused,
    this.onInternetConnected,
    this.onInternetDisconnected,
    this.onDispose,
  });

  /// The builder that receives [BuildContext] and the resolved [T] view model.
  final Widget Function(BuildContext context, T viewModel) view;

  final Future<void> Function(T viewModel)? onInit;
  final Future<void> Function(T viewModel)? onResumed;
  final void Function(T viewModel)? onPaused;
  final void Function(T viewModel)? onInternetConnected;
  final void Function(T viewModel)? onInternetDisconnected;
  final void Function(T viewModel)? onDispose;

  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends GetxController> extends State<BaseView<T>>
    with WidgetsBindingObserver {
  late final T _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // The GetX Binding registered by AppPages runs before the page builds,
    // so Get.find<T>() is always safe here.
    _viewModel = Get.find<T>();

    // Run the onInit callback after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInit?.call(_viewModel);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.onResumed?.call(_viewModel);
        break;
      case AppLifecycleState.paused:
        widget.onPaused?.call(_viewModel);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onDispose?.call(_viewModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.view(context, _viewModel);
}
