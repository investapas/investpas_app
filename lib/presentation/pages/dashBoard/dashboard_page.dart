import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:investapas/presentation/pages/dashBoard/profile/profile_tab.dart';
import 'package:investapas/presentation/pages/dashBoard/trading_journal/trading_journal_tab.dart';
import 'package:investapas/presentation/pages/dashBoard/trading_terminal/trading_terminal_tab.dart';

import '../../../Widgets/app_background.dart';

import '../../bloc/dashboard/bloc.dart';
import '../../bloc/dashboard/event.dart';
import '../../bloc/dashboard/state.dart';
import '../../bloc/trading_terminal/terminal_bloc.dart';
import '../../bloc/trading_terminal/terminal_event.dart';
import '../../bloc/trading_terminal/terminal_state.dart';

import 'bottomNavigationBar.dart';
import 'home/home_tab.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final systemBottom = MediaQuery.of(context).viewPadding.bottom;
    final navBarHeight = 56.0 + (systemBottom > 0 ? systemBottom : 16.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        final dashState = context.read<DashBoardBloc>().state;
        final terminalState = context.read<TerminalBloc>().state;

        if (dashState.pageIndex == 1 && terminalState.searchQuery.isNotEmpty) {
          context.read<TerminalBloc>().add(SearchStockEvent(''));
          return;
        }

        if (dashState.pageIndex == 1 && terminalState.subView != TerminalSubView.main) {
          context.read<TerminalBloc>().add(const ChangeTerminalSubViewEvent(TerminalSubView.main));
          return;
        }

        if (dashState.pageIndex != 0) {
          context.read<DashBoardBloc>().add(const ChangeTabDashBoardEvent(0));
          return;
        }

        SystemNavigator.pop();
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: navBarHeight),
              child: BlocBuilder<DashBoardBloc, DashBoardState>(
                builder: (context, state) {
                  return _body(state.pageIndex);
                },
              ),
            ),
          ),
          bottomNavigationBar: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: const DashBoardNavigationBar(),
          ),
        ),
      ),
    );
  }

  Widget _body(int index) {
    switch (index) {
      case 1:
        return const TradingTerminalTab();
      case 2:
        return const TradingJournalTab();
      case 3:
        return const ProfileTab();
      default:
        return const HomeTab();
    }
  }
}
