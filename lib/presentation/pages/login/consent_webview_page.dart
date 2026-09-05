import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:investapas/Widgets/app_background.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../Widgets/circle_widget.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/navigationService.dart';
import '../../bloc/login/login_bloc.dart';

class ConsentWebviewPage extends StatefulWidget {
  final String url;
  const ConsentWebviewPage({super.key,required this.url});

  @override
  State<ConsentWebviewPage> createState() => _ConsentWebviewPageState();
}

class _ConsentWebviewPageState extends State<ConsentWebviewPage> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {

            print("URL : ${request.url}");

            if (request.url.contains("tokenId=")) {

              final uri = Uri.parse(request.url);
              final tokenId = uri.queryParameters["tokenId"];

              print("TOKEN ID : $tokenId");

              if (tokenId != null) {
                context.read<LoginBloc>().add(ConsumeConsent(tokenId));
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: WebViewWidget(controller: controller),
    );
  }
}
