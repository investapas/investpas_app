part of 'Widgets.dart';

/// theme button
class ThemeButton extends StatelessWidget {
  /// constructor
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
         icon: state.isDark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode));
      },
    );
  }
}
