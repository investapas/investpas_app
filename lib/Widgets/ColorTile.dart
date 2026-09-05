part of './Widgets.dart';

/// common color Tile
class ColorTile extends StatelessWidget {
  /// color of tile
  final Color? color;
  /// title of Tile
  final dynamic title;
  /// subtitle of tiles
  final dynamic subtitle;
  /// icon of the tile if available
  final IconData? icon;
  /// onTap function of tile
  final VoidCallback? onTap;
  /// constructor
  const ColorTile(
      {super.key, this.color = Colors.grey, this.title, this.subtitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        splashColor: color,
        onTap: onTap,
        child: Card(
          elevation: 0,
          color: color?.withAlpha(30),
          shadowColor: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon, color: color),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Txt(
                        title,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        maxlines: 1,
                        color: color,
                      ),
                      Txt(
                         subtitle,
                        maxlines: 1,
                        color: color,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Widgets.arrow(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
