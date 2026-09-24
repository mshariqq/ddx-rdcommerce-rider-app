import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ddx_rider/components/ecommerce/custom_button.dart';
import 'package:ddx_rider/components/ecommerce/custom_text_field.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_auth_controller.dart';
import 'package:ddx_rider/controllers/rider/rider_notification_controller.dart';
import 'package:ddx_rider/controllers/rider/rider_tracking_controller.dart';
import 'package:ddx_rider/controllers/rider/rider_user_controller.dart';
import 'package:ddx_rider/models/rider/rider_user.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';
import 'package:ddx_rider/utils/global_function.dart';

class RiderProfileView extends ConsumerStatefulWidget {
  const RiderProfileView({super.key});

  @override
  ConsumerState<RiderProfileView> createState() => _RiderProfileViewState();
}

class _RiderProfileViewState extends ConsumerState<RiderProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(riderUserControllerProvider.notifier).details();
      ref.read(riderNotificationControllerProvider.notifier).list();
    });
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will stop receiving delivery updates.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Logout')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(riderTrackingControllerProvider.notifier).stop();
    await ref.read(riderAuthControllerProvider.notifier).logout();
    if (!mounted) return;
    context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
            'This permanently deletes your rider account. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(riderTrackingControllerProvider.notifier).stop();
    await ref.read(riderAuthControllerProvider.notifier).deleteAccount();
    if (!mounted) return;
    context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  void _openEditSheet(RiderUser? user) {
    final first = TextEditingController(text: user?.name ?? '');
    final last = TextEditingController(text: user?.lastName ?? '');
    final phone = TextEditingController(text: user?.phone ?? '');
    final email = TextEditingController(text: user?.email ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.w).copyWith(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit profile',
                style: AppTextStyle(context)
                    .subTitle
                    .copyWith(fontSize: 16.sp)),
            Gap(16.h),
            CustomTextFormField(
              name: 'First Name',
              hintText: 'First name',
              textInputType: TextInputType.name,
              controller: first,
              textInputAction: TextInputAction.next,
              validator: (_) => null,
            ),
            Gap(12.h),
            CustomTextFormField(
              name: 'Last Name',
              hintText: 'Last name',
              textInputType: TextInputType.name,
              controller: last,
              textInputAction: TextInputAction.next,
              validator: (_) => null,
            ),
            Gap(12.h),
            CustomTextFormField(
              name: 'Phone',
              hintText: 'Phone',
              textInputType: TextInputType.phone,
              controller: phone,
              textInputAction: TextInputAction.next,
              validator: (_) => null,
            ),
            Gap(12.h),
            CustomTextFormField(
              name: 'Email',
              hintText: 'Email',
              textInputType: TextInputType.emailAddress,
              controller: email,
              textInputAction: TextInputAction.done,
              validator: (_) => null,
            ),
            Gap(20.h),
            CustomButton(
              buttonText: 'Save',
              onPressed: () async {
                final ok = await ref
                    .read(riderUserControllerProvider.notifier)
                    .updateProfile({
                  'first_name': first.text.trim(),
                  if (last.text.trim().isNotEmpty)
                    'last_name': last.text.trim(),
                  if (phone.text.trim().isNotEmpty)
                    'phone': phone.text.trim(),
                  if (email.text.trim().isNotEmpty)
                    'email': email.text.trim(),
                });
                if (ctx.mounted && ok) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openPasswordSheet() {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.w).copyWith(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Change password',
                style: AppTextStyle(context)
                    .subTitle
                    .copyWith(fontSize: 16.sp)),
            Gap(16.h),
            CustomTextFormField(
              name: 'Current Password',
              hintText: 'Current password',
              textInputType: TextInputType.visiblePassword,
              controller: current,
              textInputAction: TextInputAction.next,
              obscureText: true,
              validator: (_) => null,
            ),
            Gap(12.h),
            CustomTextFormField(
              name: 'New Password',
              hintText: 'New password',
              textInputType: TextInputType.visiblePassword,
              controller: next,
              textInputAction: TextInputAction.next,
              obscureText: true,
              validator: (_) => null,
            ),
            Gap(12.h),
            CustomTextFormField(
              name: 'Confirm Password',
              hintText: 'Confirm new password',
              textInputType: TextInputType.visiblePassword,
              controller: confirm,
              textInputAction: TextInputAction.done,
              obscureText: true,
              validator: (_) => null,
            ),
            Gap(20.h),
            CustomButton(
              buttonText: 'Update',
              onPressed: () async {
                if (next.text != confirm.text) {
                  GlobalFunction.showCustomSnackbar(
                    message: 'Passwords do not match',
                    isSuccess: false,
                  );
                  return;
                }
                final ok = await ref
                    .read(riderAuthControllerProvider.notifier)
                    .changePassword(
                      currentPassword: current.text,
                      password: next.text,
                      passwordConfirmation: confirm.text,
                    );
                if (ctx.mounted && ok) Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(riderUserControllerProvider);
    final authLoading = ref.watch(riderAuthControllerProvider);
    final onDuty = ref.watch(riderTrackingControllerProvider);
    final user = profile.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(riderUserControllerProvider.notifier).details(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (profile.isLoading && user == null)
                const Center(child: CircularProgressIndicator())
              else
                _header(user),
              Gap(16.h),
              _stats(profile.monthDelivered, profile.monthCash),
              Gap(16.h),
              SwitchListTile(
                title: Text(onDuty ? 'On duty' : 'Off duty',
                    style: AppTextStyle(context).bodyText),
                subtitle: Text(
                  onDuty
                      ? 'Sharing location every 30s'
                      : 'Turn on to receive deliveries',
                  style: AppTextStyle(context).bodyTextSmall,
                ),
                value: onDuty,
                onChanged: (_) => ref
                    .read(riderTrackingControllerProvider.notifier)
                    .toggle(),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit profile'),
                onTap: () => _openEditSheet(user),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change password'),
                onTap: _openPasswordSheet,
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                onTap: () => context.nav.pushNamed(Routes.languageView),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                enabled: !authLoading,
                onTap: _logout,
              ),
              ListTile(
                leading: Icon(Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error),
                title: Text('Delete account',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error)),
                enabled: !authLoading,
                onTap: _deleteAccount,
              ),
              Gap(24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(RiderUser? user) {
    final name = user == null
        ? 'Rider'
        : [user.name, user.lastName]
            .where((p) => (p ?? '').trim().isNotEmpty)
            .join(' ');
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              child: Text(
                name.isEmpty ? 'R' : name[0].toUpperCase(),
                style: TextStyle(fontSize: 22.sp),
              ),
            ),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isEmpty ? 'Rider' : name,
                      style: AppTextStyle(context)
                          .subTitle
                          .copyWith(fontSize: 16.sp)),
                  Gap(4.h),
                  Text(user?.phone ?? '',
                      style: AppTextStyle(context).bodyTextSmall),
                  if ((user?.vehicle ?? '').isNotEmpty)
                    Text(user!.vehicle!,
                        style: AppTextStyle(context).bodyTextSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stats(int delivered, double cash) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Text('$delivered',
                      style: AppTextStyle(context)
                          .title
                          .copyWith(fontWeight: FontWeight.w700)),
                  Gap(4.h),
                  Text('Delivered this month',
                      textAlign: TextAlign.center,
                      style: AppTextStyle(context).bodyTextSmall),
                ],
              ),
            ),
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Text(cash.toStringAsFixed(2),
                      style: AppTextStyle(context)
                          .title
                          .copyWith(fontWeight: FontWeight.w700)),
                  Gap(4.h),
                  Text('Cash collected',
                      textAlign: TextAlign.center,
                      style: AppTextStyle(context).bodyTextSmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
