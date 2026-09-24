import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';
import 'package:ddx_rider/components/ecommerce/app_logo.dart';
import 'package:ddx_rider/components/ecommerce/custom_button.dart';
import 'package:ddx_rider/components/ecommerce/custom_text_field.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_auth_controller.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';
import 'package:ddx_rider/utils/global_function.dart';

/// OTP verification for [contact] (phone).
/// Normal flow: verify -> go to login.
/// Forgot-password flow ([isForgot]): verify -> set new password inline
/// via create-password -> go to login.
class RiderOtpView extends ConsumerStatefulWidget {
  final String contact;
  final bool isForgot;

  const RiderOtpView({super.key, required this.contact, this.isForgot = false});

  @override
  ConsumerState<RiderOtpView> createState() => _RiderOtpViewState();
}

class _RiderOtpViewState extends ConsumerState<RiderOtpView> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _resetToken;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      GlobalFunction.showCustomSnackbar(
        message: 'Enter the 4-digit OTP',
        isSuccess: false,
      );
      return;
    }
    final token = await ref
        .read(riderAuthControllerProvider.notifier)
        .verifyOtp(phone: widget.contact, otp: otp);
    if (token == null || !mounted) return;
    if (widget.isForgot) {
      setState(() => _resetToken = token);
    } else {
      context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
    }
  }

  Future<void> _createPassword() async {
    if (_passwordController.text.length < 6) {
      GlobalFunction.showCustomSnackbar(
        message: 'Password must be at least 6 characters',
        isSuccess: false,
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      GlobalFunction.showCustomSnackbar(
        message: 'Passwords do not match',
        isSuccess: false,
      );
      return;
    }
    final ok = await ref
        .read(riderAuthControllerProvider.notifier)
        .createPassword(
          token: _resetToken ?? '',
          password: _passwordController.text,
          passwordConfirmation: _confirmController.text,
        );
    if (!ok || !mounted) return;
    context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  Future<void> _resend() async {
    await ref.read(riderAuthControllerProvider.notifier).sendOtp(
          phone: widget.contact,
          forgotPassword: widget.isForgot ? 1 : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(riderAuthControllerProvider);
    final showPasswordForm = widget.isForgot && _resetToken != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppLogo(isAnimation: false),
            Gap(24.h),
            Text('Enter verification code',
                style: AppTextStyle(context)
                    .title
                    .copyWith(fontWeight: FontWeight.w700)),
            Gap(6.h),
            Text('Sent to ${widget.contact}',
                style: AppTextStyle(context).bodyTextSmall),
            Gap(24.h),
            if (!showPasswordForm) ...[
              Center(
                child: Pinput(
                  length: 4,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  onCompleted: (_) => _verify(),
                ),
              ),
              Gap(24.h),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(buttonText: 'Verify', onPressed: _verify),
              Gap(8.h),
              TextButton(onPressed: loading ? null : _resend,
                  child: const Text('Resend OTP')),
            ] else ...[
              CustomTextFormField(
                name: 'New Password',
                hintText: 'Enter new password',
                textInputType: TextInputType.visiblePassword,
                controller: _passwordController,
                textInputAction: TextInputAction.next,
                obscureText: true,
                validator: (_) => null,
              ),
              Gap(16.h),
              CustomTextFormField(
                name: 'Confirm Password',
                hintText: 'Confirm new password',
                textInputType: TextInputType.visiblePassword,
                controller: _confirmController,
                textInputAction: TextInputAction.done,
                obscureText: true,
                validator: (_) => null,
              ),
              Gap(24.h),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(
                    buttonText: 'Set Password', onPressed: _createPassword),
            ],
          ],
        ),
      ),
    );
  }
}
