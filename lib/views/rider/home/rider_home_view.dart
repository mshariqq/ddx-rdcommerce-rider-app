import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddx_rider/controllers/rider/rider_notification_controller.dart';
import 'package:ddx_rider/controllers/rider/rider_tracking_controller.dart';
import 'package:ddx_rider/views/rider/notifications/rider_notifications_view.dart';
import 'package:ddx_rider/views/rider/orders/rider_my_orders_view.dart';
import 'package:ddx_rider/views/rider/orders/rider_orders_view.dart';
import 'package:ddx_rider/views/rider/profile/rider_profile_view.dart';

/// Bottom nav: Deliveries, My Orders, Notifications (badge), Profile.
/// AppBar carries the on-duty toggle wired to [riderTrackingControllerProvider].
class RiderHomeView extends ConsumerStatefulWidget {
  const RiderHomeView({super.key});

  @override
  ConsumerState<RiderHomeView> createState() => _RiderHomeViewState();
}

class _RiderHomeViewState extends ConsumerState<RiderHomeView> {
  int _index = 0;

  static const _pages = [
    RiderOrdersView(),
    RiderMyOrdersView(),
    RiderNotificationsView(),
    RiderProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final onDuty = ref.watch(riderTrackingControllerProvider);
    final unread = ref.watch(riderUnreadCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DDX Rider'),
        actions: [
          Row(
            children: [
              Text(onDuty ? 'On duty' : 'Off duty',
                  style: Theme.of(context).textTheme.labelLarge),
              Switch(
                value: onDuty,
                onChanged: (_) => ref
                    .read(riderTrackingControllerProvider.notifier)
                    .toggle(),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Deliveries',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              child: const Icon(Icons.notifications),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
