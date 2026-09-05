part of 'Views.dart';

/// common body container widget
class BodyContainer extends StatelessWidget {
  /// child of the container
  final Widget? child;

  /// height of the container
  final double ?height;

/// constructor
  const BodyContainer({super.key, this.child,this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
