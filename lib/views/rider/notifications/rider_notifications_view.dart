import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_notification_controller.dart';
import 'package:ddx_rider/models/rider/rider_notification.dart';
import 'package:ddx_rider/utils/global_function.dart';

class RiderNotificationsView extends ConsumerStatefulWidget {
  const RiderNotificationsView({super.key});

  @override
  ConsumerState<RiderNotificationsView> createState() =>
      _RiderNotificationsViewState();
}

class _RiderNotificationsViewState
    extends ConsumerState<RiderNotificationsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(riderNotificationControllerProvider.notifier).list());
  }

  Future<void> _confirmDelete(RiderNotification n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete notification?'),
        content: Text(n.title),
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
    if (ok == true && mounted) {
      await ref
          .read(riderNotificationControllerProvider.notifier)
          .delete(n.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(riderNotificationControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.unreadCount > 0
            ? 'Notifications (${state.unreadCount})'
            : 'Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(riderNotificationControllerProvider.notifier).list(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(RiderNotificationState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return _message('Failed to load notifications.\nPull to retry.');
    }
    if (state.items.isEmpty) {
      return _message('No notifications yet.');
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => Gap(12.h),
      itemBuilder: (context, i) {
        final n = state.items[i];
        final unread = n.isRead != true;
        return Card(
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: CircleAvatar(
              child: Icon(
                unread
                    ? Icons.notifications_active
                    : Icons.notifications_none,
              ),
            ),
            title: Text(
              n.title.isEmpty ? 'Notification' : n.title,
              style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight:
                      unread ? FontWeight.w700 : FontWeight.w400),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((n.content ?? '').isNotEmpty) ...[
                  Gap(4.h),
                  Text(n.content ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle(context).bodyTextSmall),
                ],
                if ((n.createdAt ?? '').isNotEmpty) ...[
                  Gap(4.h),
                  Text(
                    _formatDate(n.createdAt!),
                    style: AppTextStyle(context).bodyTextSmall,
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(n),
            ),
            onTap: unread
                ? () => ref
                    .read(riderNotificationControllerProvider.notifier)
                    .markRead(n.id)
                : null,
          ),
        );
      },
    );
  }

  static String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return GlobalFunction.formatMessageDateTime(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _message(String text) {
    return ListView(
      children: [
        Gap(80.h),
        Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: AppTextStyle(context).bodyTextSmall),
        ),
      ],
    );
  }
}
