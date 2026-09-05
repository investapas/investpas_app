part of 'Views.dart';

///An indexed list view which can be scrolled horizontally
class IndexedListView extends StatefulWidget {
  ///Primary contents with label & target page
  final List<NRI> nris;

  ///Width of the each table built inside the list view
  final double tableWidth;

  ///Constructor
  const IndexedListView({
    super.key,
    required this.nris,
    this.tableWidth = 400,
  });

  @override
  State<IndexedListView> createState() => _IndexedListViewState();
}

class _IndexedListViewState extends State<IndexedListView> {
  final AutoScrollController controller = AutoScrollController(axis: Axis.horizontal);

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        chips(),
        tables(),
      ],
    );
  }

  Widget chips() {
    return Container(
      height: 50,
      alignment: Alignment.center,
      width: double.maxFinite,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Iconbutton(
              icon: Icons.arrow_circle_left_outlined,
              color: Colorz.blue,
              tooltip: 'Go to first',
              onPressed: () async {
                setState(() => selectedIndex = 0);
                const double offset = 0;
                controller.animateTo(
                  offset,
                  duration: Widgets.duration,
                  curve: Widgets.curve,
                );
              },
            ),
            ...widget.nris.map((NRI nri) {
              final int index = widget.nris.indexOf(nri);
              final bool isSelected = selectedIndex == index;
              return Chipp(
                icon: isSelected ? Icons.check : null,
                selected: isSelected,
                color: Colorz.blue,
                selectedTextColor: Colors.white,
                unselectedTextColor: Colors.black87,
                unSelectedColor: Colorz.skyBlue,
                // color: Colorz.blue,
                text: nri.label,
                maxLength: nri.label.characters.length + 5,
                onPressed: () {
                  setState(() => selectedIndex = index);
                  controller.scrollToIndex(index);
                },
              );
            }),
            Iconbutton(
              icon: Icons.arrow_circle_right_outlined,
              color: Colorz.blue,
              tooltip: 'Go to last',
              onPressed: () async {
                setState(() => selectedIndex = widget.nris.length - 1);
                final double offset = controller.position.maxScrollExtent;
                controller.animateTo(
                  offset,
                  duration: Widgets.duration,
                  curve: Widgets.curve,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget tables() {
    return Expanded(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.nris.length,
        itemBuilder: (BuildContext context, int index) {
          final NRI nri = widget.nris[index];
          return AutoScrollTag(
            highlightColor: Colors.green,
            key: ValueKey<String>(nri.label),
            controller: controller,
            index: index,
            child: Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colorz.blue.withAlpha(75),
                borderRadius: BorderRadius.circular(8),
              ),
              height: double.maxFinite,
              width: nri.width ?? widget.tableWidth,
              alignment: Alignment.center,
              child: nri.page,
            ),
          );
        },
      ),
    );
  }
}
