import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ddx_rider/components/ecommerce/app_logo.dart';
import 'package:ddx_rider/components/ecommerce/custom_button.dart';
import 'package:ddx_rider/components/ecommerce/custom_text_field.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_auth_controller.dart';
import 'package:ddx_rider/controllers/rider/rider_user_controller.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';
import 'package:ddx_rider/utils/global_function.dart';

class RiderLoginView extends ConsumerStatefulWidget {
  const RiderLoginView({super.key});

  @override
  ConsumerState<RiderLoginView> createState() => _RiderLoginViewState();
}

class _RiderLoginViewState extends ConsumerState<RiderLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(riderAuthControllerProvider.notifier).login(
          phone: _phoneController.text,
          password: _passwordController.text,
        );
    if (!ok || !mounted) return;

    // Best-effort one-shot location ping after login.
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(timeLimit: Duration(seconds: 10)),
        );
        await ref
            .read(riderUserControllerProvider.notifier)
            .updateLocation(pos.latitude, pos.longitude);
      }
    } catch (_) {}

    if (!mounted) return;
    context.nav.pushNamedAndRemoveUntil(Routes.riderHome, (route) => false);
  }

  Future<void> _forgotPassword() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      GlobalFunction.showCustomSnackbar(
        message: 'Enter your phone number first',
        isSuccess: false,
      );
      return;
    }
    final sent = await ref
        .read(riderAuthControllerProvider.notifier)
        .sendOtp(phone: phone, forgotPassword: 1);
    if (!sent || !mounted) return;
    context.nav.pushNamed(
      Routes.otp,
      arguments: {'contact': phone, 'isForgot': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(riderAuthControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(12.h),
              const AppLogo(isAnimation: false),
              Gap(24.h),
              Text('Welcome back',
                  style: AppTextStyle(context)
                      .title
                      .copyWith(fontWeight: FontWeight.w700)),
              Gap(6.h),
              Text('Login to receive deliveries',
                  style: AppTextStyle(context).bodyTextSmall),
              Gap(24.h),
              CustomTextFormField(
                name: 'Phone',
                hintText: 'Enter phone number',
                textInputType: TextInputType.phone,
                controller: _phoneController,
                textInputAction: TextInputAction.next,
                validator: (v) => GlobalFunction.phoneValidator(
                  value: v ?? '',
                  hintText: 'Phone',
                  context: context,
                  isPhoneRequired: true,
                  minLength: 6,
                ),
              ),
              Gap(16.h),
              CustomTextFormField(
                name: 'Password',
                hintText: 'Enter password',
                textInputType: TextInputType.visiblePassword,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                obscureText: _obscure,
                validator: (v) => GlobalFunction.passwordValidator(
                  value: v ?? '',
                  hintText: 'Password',
                  context: context,
                ),
                widget: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              Gap(8.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: loading ? null : _forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              Gap(12.h),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(buttonText: 'Login', onPressed: _login),
              Gap(16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: AppTextStyle(context).bodyTextSmall),
                  TextButton(
                    onPressed: () =>
                        context.nav.pushNamed(Routes.register),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
