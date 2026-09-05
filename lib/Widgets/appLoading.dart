part of 'Widgets.dart';

/// app loading widget
class AppLoadingWidget extends StatelessWidget {
  /// child widget
  final Widget? child;

  /// loading value
  final bool isLoading;

  /// constructor
  const AppLoadingWidget({super.key, this.child, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child ?? Container(),
        
          if (isLoading) ...[
          Positioned.fill(
              child: Align(
            child: Widgets.loader(),
          )),
          const Positioned.fill(
            child: ModalBarrier(
              color: Colors.transparent,
              dismissible: false,
            ),
          ),
        ],
      ],
    );
  }
}
