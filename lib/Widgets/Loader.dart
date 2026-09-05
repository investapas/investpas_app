part of './Widgets.dart';

/// common loader of app
class Loader extends StatefulWidget {
  /// size of loader
  final double size;
  /// constructor
  const Loader({
    super.key,
    this.size = 50,
  });
  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  late AnimationController rotationController;
  late AnimationController bouncingController;

  late Animation<Offset> bouncingAnimation;
  late Animation<double> shadowAnimation;

  bool touchedFloor = false;

  @override
  void initState() {
    startAnimation();
    super.initState();
  }

  @override
  void dispose() {
    rotationController.dispose();
    bouncingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          bouncingWidget(),
          shadowWidget(),
        ],
      ),
    );
  }

  Widget bouncingWidget() {
    return Transform.translate(
      offset: bouncingAnimation.value,
      child: rotatingWidget(),
    );
  }

  Widget rotatingWidget() {
    return AnimatedBuilder(
      animation: rotationController,
      builder: (BuildContext context, Widget? widget) {
        return  Transform.rotate(
          angle: rotationController.value,
          child: widget,
        );
      },
    );
  }


  Widget shadowWidget() {
    final double shadowOpacity = shadowAnimation.value;
    final Color shadowColor = Colors.black.withAlpha(touchedFloor ? 30 :700);
    final double shadowHeight = touchedFloor ? 0.005 : 0.25;
    final double shadowWidth = widget.size / (touchedFloor ? 5 : 2.5);
    final BoxDecoration shadowDecoration = BoxDecoration(
        color: shadowColor,
        borderRadius: BorderRadius.circular(360),
        boxShadow: <BoxShadow>[BoxShadow(color: shadowColor, blurRadius: 5, spreadRadius: 5)]);

    return AnimatedOpacity(
      duration: shadowDuration,
      opacity: shadowOpacity,
      child: AnimatedContainer(
        height: shadowHeight,
        width: shadowWidth,
        duration: shadowDuration,
        decoration: shadowDecoration,
      ),
    );
  }

  void startAnimation() {
    rotationController = AnimationController(vsync: this, duration: rotationDuration);
    bouncingController = AnimationController(vsync: this, duration: shadowDuration);

    bouncingAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -10.0)).animate(bouncingController);
    shadowAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(curve: const Interval(0.4, 1.0), parent: bouncingController));

    rotationController.addListener(() => setState(() {}));
    bouncingController.addListener(() => setState(() {}));

    rotationController.forward();
    bouncingController.forward();

    rotationController.addStatusListener((AnimationStatus status) async {
      if (status == AnimationStatus.completed) {
        await rotationController.repeat();
      }
    });

    bouncingController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        bouncingController.reverse();
        touchedFloor = !touchedFloor;
      } else if (status == AnimationStatus.dismissed) {
        touchedFloor = !touchedFloor;
        bouncingController.forward(from: 0.0);
      }
    });
  }

  static const Duration shadowDuration = Duration(milliseconds: 1000);
  static const Duration rotationDuration = Duration(milliseconds: 150);
}
