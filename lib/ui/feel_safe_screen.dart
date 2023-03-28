import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wireguard_flutter/ui/common/app_router.dart';
import 'package:wireguard_flutter/ui/common/button.dart';
import 'package:wireguard_flutter/ui/common/colors.dart';
import 'package:wireguard_flutter/ui/common/text_styles.dart';

class FeelSafeScreen extends StatelessWidget {
  final bool emailSubmit;

  const FeelSafeScreen({
    Key? key,
    this.emailSubmit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Text(
                  'V-Tell VPN',
                  style: TextStyles.regular14,
                ),
                SizedBox(height: 85.h),
                SvgPicture.asset(
                  emailSubmit
                      ? 'assets/icon/email_submit.svg'
                      : 'assets/icon/feel_safety.svg',
                ),
                if (emailSubmit) ...[
                  SizedBox(height: 60.h),
                  Text(
                    'If you would like to become a V-Tell Customer or get access to VPN services, please submit your e-mail address and a representative will reach out to you shortly.',
                    style: TextStyles.regular16,
                  ),
                  SizedBox(height: 50.h),
                  TextFormField(
                    style: TextStyles.beauSansRegular14.copyWith(color: Colors.white),
                    cursorColor: PjColors.lightGrey,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: border(),
                      disabledBorder: border(),
                      border: border(),
                      focusedBorder: border(),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'E-mail',
                        style: TextStyles.beauSansRegular14,
                      ),
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Button(
                    text: 'Submit',
                    onTap: () {
                      context.router.push(TunnelDetailsRoute());
                    },
                  ),
                  SizedBox(height: 34.h),
                  Text(
                    'If you do not receive the e-mail containing the V-Tell VPN Key within 24hrs of subscribing, please check your spam or contact Customer Service.',
                    style: TextStyles.italic12,
                  ),
                ] else ...[
                  SizedBox(height: 30.h),
                  Text(
                    'FEEL SAFE.',
                    style: TextStyles.redTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Please continue to the next page to confirm your subscription.',
                    style: TextStyles.regular16,
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Once you have successfully subscribed, you will receive an e-mail with a VPN Activation Key.',
                    style: TextStyles.regular16,
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Once received, you can then activate VPN on your device by selecting "Upload V-Tell VPN Key".',
                    style: TextStyles.regular16,
                  ),
                  SizedBox(height: 50.h),
                  Button(
                    text: 'Continue',
                    onTap: () {
                      context.router.push(FeelSafeScreenRoute(emailSubmit: true));
                    },
                  ),
                  SizedBox(height: 20.h),
                  Button(
                    text: 'Upload V-Tell VPN key',
                    onTap: () {},
                    isActive: false,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder border() {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(40)),
    borderSide: BorderSide(color: PjColors.lightGrey),
  );
}
