import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ddx_rider/components/ecommerce/app_logo.dart';
import 'package:ddx_rider/components/ecommerce/custom_button.dart';
import 'package:ddx_rider/components/ecommerce/custom_text_field.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_auth_controller.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';
import 'package:ddx_rider/utils/global_function.dart';

const List<String> _vehicleTypes = ['bike', 'cycle', 'car', 'van', 'truck'];

class RiderRegisterView extends ConsumerStatefulWidget {
  const RiderRegisterView({super.key});

  @override
  ConsumerState<RiderRegisterView> createState() => _RiderRegisterViewState();
}

class _RiderRegisterViewState extends ConsumerState<RiderRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _licence = TextEditingController();
  String _vehicleType = _vehicleTypes.first;
  bool _obscure = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _licence.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_password.text != _confirmPassword.text) {
      GlobalFunction.showCustomSnackbar(
        message: 'Passwords do not match',
        isSuccess: false,
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final ok =
        await ref.read(riderAuthControllerProvider.notifier).register({
      'first_name': _firstName.text.trim(),
      if (_lastName.text.trim().isNotEmpty)
        'last_name': _lastName.text.trim(),
      'phone': _phone.text.trim(),
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      'password': _password.text,
      'password_confirmation': _confirmPassword.text,
      'vehicle_type': _vehicleType,
      if (_licence.text.trim().isNotEmpty)
        'driving_lience': _licence.text.trim(),
    });
    if (!ok || !mounted) return;

    // Try to send OTP for verification; fall back to login either way.
    try {
      await ref
          .read(riderAuthControllerProvider.notifier)
          .sendOtp(phone: _phone.text.trim());
    } catch (_) {}
    if (!mounted) return;
    context.nav.pushNamed(
      Routes.otp,
      arguments: {'contact': _phone.text.trim()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(riderAuthControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Registration')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLogo(isAnimation: false),
              Gap(20.h),
              Text('Become a rider',
                  style: AppTextStyle(context)
                      .title
                      .copyWith(fontWeight: FontWeight.w700)),
              Gap(20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      name: 'First Name',
                      hintText: 'First name',
                      textInputType: TextInputType.name,
                      controller: _firstName,
                      textInputAction: TextInputAction.next,
                      validator: (v) => GlobalFunction.commonValidator(
                        value: v ?? '',
                        hintText: 'First name',
                        context: context,
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: CustomTextFormField(
                      name: 'Last Name',
                      hintText: 'Last name',
                      textInputType: TextInputType.name,
                      controller: _lastName,
                      textInputAction: TextInputAction.next,
                      validator: (_) => null,
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              CustomTextFormField(
                name: 'Phone',
                hintText: 'Enter phone number',
                textInputType: TextInputType.phone,
                controller: _phone,
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
                name: 'Email (optional)',
                hintText: 'Enter email',
                textInputType: TextInputType.emailAddress,
                controller: _email,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return null;
                  return GlobalFunction.emailValidator(
                    value: v ?? '',
                    hintText: 'Email',
                    context: context,
                  );
                },
              ),
              Gap(16.h),
              CustomTextFormField(
                name: 'Password',
                hintText: 'Enter password',
                textInputType: TextInputType.visiblePassword,
                controller: _password,
                textInputAction: TextInputAction.next,
                obscureText: _obscure,
                validator: (v) => GlobalFunction.passwordValidator(
                  value: v ?? '',
                  hintText: 'Password',
                  context: context,
                ),
                widget: IconButton(
                  icon:
                      Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              Gap(16.h),
              CustomTextFormField(
                name: 'Confirm Password',
                hintText: 'Confirm password',
                textInputType: TextInputType.visiblePassword,
                controller: _confirmPassword,
                textInputAction: TextInputAction.next,
                obscureText: _obscure,
                validator: (v) => GlobalFunction.passwordValidator(
                  value: v ?? '',
                  hintText: 'Confirm password',
                  context: context,
                ),
              ),
              Gap(16.h),
              Text('Vehicle Type',
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w500)),
              Gap(12.h),
              DropdownButtonFormField<String>(
                initialValue: _vehicleType,
                items: _vehicleTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _vehicleType = v);
                },
              ),
              Gap(16.h),
              CustomTextFormField(
                name: 'Driving Licence (optional)',
                hintText: 'Licence number',
                textInputType: TextInputType.text,
                controller: _licence,
                textInputAction: TextInputAction.done,
                validator: (_) => null,
              ),
              Gap(24.h),
              if (loading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(buttonText: 'Register', onPressed: _register),
              Gap(12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ',
                      style: AppTextStyle(context).bodyTextSmall),
                  TextButton(
                    onPressed: () =>
                        context.nav.pushReplacementNamed(Routes.login),
                    child: const Text('Login'),
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
