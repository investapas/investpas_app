part of 'Views.dart';

/// common grid view builder
class GriddViewBuilder extends StatelessWidget {
  /// total items and croos axis items
  final int? itemCount, crossAxisCount;

  /// item builder
  final Widget? Function(int index) item;

  /// scroll
  final ScrollPhysics? physics;

  /// shrinkWrap
  final bool shrinkWrap;

  ///is list loading
  final bool isLoading;
  /// empty list subtitle
  final String? emptySubtitle;

  /// constructor
  const GriddViewBuilder(
      {super.key,
      this.itemCount,
      this.crossAxisCount,
      this.emptySubtitle,
      required this.item,
      this.physics,
      this.shrinkWrap = false,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AnimationLimiter(
        child: GridView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount ?? 2,
            ),
            itemCount: 30,
            itemBuilder: (BuildContext context, int index) {
              return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: crossAxisCount ?? 3,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                      verticalOffset: 50,
                      child: ScaleAnimation(
                          duration: const Duration(milliseconds: 275),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10,
                                bottom: 10,
                                right: index % (crossAxisCount ?? 2) != 0
                                    ? 10
                                    : 0),
                            child: Container(
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                            ),
                          ))));
            }),
      );
    }
    if (itemCount == 0) {
      return Widgets.notFoundWidget(subtitle: emptySubtitle);
    }
    return AnimationLimiter(
      child: GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount ?? 2,
          ),
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: crossAxisCount ?? 2,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                    verticalOffset: 50,
                    child: ScaleAnimation(
                        duration: const Duration(milliseconds: 275),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10,
                              bottom: 10,
                              right:
                                  index % (crossAxisCount ?? 2) != 0 ? 10 : 0),
                          child: item(index),
                        ))));
          }),
    );
  }
}
