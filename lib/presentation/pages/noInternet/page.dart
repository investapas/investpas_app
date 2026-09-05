
import 'package:flutter/material.dart';
import '../../../Widgets/Widgets.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/internet.dart';
import '../../../core/utils/navigationService.dart';
import '../../../routes/appRoutes.dart';

///  no internet page
class NoInternetPage extends StatelessWidget {
  /// constructor
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.purple.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Main Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
               Txt(
                'No Internet Connection',
                textStyle: AppTextStyles.headerOne.copyWith(color: Colorz.white),
              ),
              const SizedBox(height: 10),
               Txt(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                textStyle: AppTextStyles.large.copyWith(
                  color: Colorz.gray,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: ()async{
                  final bool available = await InternetService.isConnected();

                  if (!available) {
                    Widgets.showToast('No Internet Connection');
                    return;
                  }

                NavigatorService.pushNamedAndRemoveUntil(AppRoutes.initialRoute);

                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}
