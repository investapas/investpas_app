import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:investapas/core/constants/constants.dart';
import 'package:investapas/presentation/bloc/login/login_bloc.dart';

import '../../../Widgets/Widgets.dart';
import '../../../Widgets/app_background.dart';
import '../../../core/utils/navigationService.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../routes/appRoutes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LoginBloc>().add(LoginStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if(state is LoginOpenWebview){
          NavigatorService.pushNamed(AppRoutes.loginWebviewPage,arguments: {"url": state.url});
        }

        if(state is LoginError){
          ToastHelper.showToast(state.message,isSuccess: false);
        }

        if(state is NavigateToRegister){
          // NavigatorService.pushNamedAndRemoveUntil(AppRoutes.homePage);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: SizeConfig.spaceBetween*2),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.loginSvg),
                        SizeConfig.verticalSpaceLarge(),
                        Text(
                          "Get Started Now",
                          style: AppTextStyles.headerOne.copyWith(fontSize: SizeConfig.headerOneFont,fontWeight: FontWeight.w500),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*0.1),
                        Text(
                          "Please login to your account to continue",
                          style: AppTextStyles.medium.copyWith(fontWeight: FontWeight.w500,color: Colorz.hintTextColor),
                        ),
                        SizeConfig.verticalSpace(height: SizeConfig.spaceBetween*4),
                        Button(
                          text: 'Login with Dhan',
                          isOutlined: false,
                          isBig: true,
                          radius: 100,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF138C61),
                              Color(0xFF4DBA93),
                            ],
                          ),
                          onPressed: () {
                            context.read<LoginBloc>().add(LoginButtonPressed());
                          },
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      context.read<LoginBloc>().add(RegisterButtonPressed());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have a Dhan account?",
                          style: AppTextStyles.medium.copyWith(fontWeight: FontWeight.w500,color: Colorz.hintTextColor2),
                        ),
                        SizeConfig.horizontalSpace(width: SizeConfig.spaceBetween*0.4),
                        Text(
                          "Create Here.",
                          style: AppTextStyles.semiBold.copyWith(color: Colorz.primary,decoration: TextDecoration.underline,decorationColor: Colorz.primary),
                        ),
                      ],
                    ),
                  ),
                  SizeConfig.verticalSpaceLarge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
