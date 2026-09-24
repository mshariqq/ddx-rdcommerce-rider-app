import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_order_controller.dart';
import 'package:ddx_rider/models/rider/rider_order.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';
import 'package:ddx_rider/utils/global_function.dart';

/// Delivery queue from GET rider/orders with To-do / Completed tabs driven
/// by the summary counts. Tap an order -> delivery details.
class RiderOrdersView extends ConsumerStatefulWidget {
  const RiderOrdersView({super.key});

  @override
  ConsumerState<RiderOrdersView> createState() => _RiderOrdersViewState();
}

class _RiderOrdersViewState extends ConsumerState<RiderOrdersView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    Future.microtask(
        () => ref.read(riderOrderControllerProvider.notifier).orders());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _open(RiderOrder order) {
    context.nav.pushNamed(
      Routes.deliveryDetails,
      arguments: {'orderId': order.id, 'orderCode': order.orderCode},
    ).then((_) {
      if (mounted) ref.read(riderOrderControllerProvider.notifier).orders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(riderOrderControllerProvider);
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: 'To-do (${state.toDoCount})'),
            Tab(text: 'Completed (${state.completedCount})'),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(riderOrderControllerProvider.notifier).orders(),
            child: _buildBody(state),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(RiderOrdersState state) {
    if (state.isLoading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.orders.isEmpty) {
      return _message('Failed to load deliveries.\nPull to retry.');
    }
    if (state.orders.isEmpty) {
      return _message('No deliveries assigned yet.');
    }
    final todo = state.orders
        .where((o) => o.orderStatus.toLowerCase() != 'delivered' &&
            o.orderStatus.toLowerCase() != 'deliveredandpaid')
        .toList();
    final done = state.orders
        .where((o) =>
            o.orderStatus.toLowerCase() == 'delivered' ||
            o.orderStatus.toLowerCase() == 'deliveredandpaid')
        .toList();
    return TabBarView(
      controller: _tabs,
      children: [
        _orderList(todo, 'No to-do deliveries.'),
        _orderList(done, 'No completed deliveries yet.'),
      ],
    );
  }

  Widget _orderList(List<RiderOrder> items, String emptyText) {
    if (items.isEmpty) return _message(emptyText);
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      separatorBuilder: (_, __) => Gap(12.h),
      itemBuilder: (context, i) {
        final o = items[i];
        return Card(
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            title: Text(
              o.orderCode.isEmpty ? 'Order #${o.id}' : o.orderCode,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(4.h),
                Text(o.customerName.isEmpty ? o.shopName : o.customerName,
                    style: AppTextStyle(context).bodyTextSmall),
                Gap(2.h),
                Text(o.shopAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle(context).bodyTextSmall),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GlobalFunction.getStatusWidget(
                    context: context,
                    status: o.orderStatus.isEmpty ? 'pending' : o.orderStatus),
                Gap(4.h),
                Text(
                  o.amount.toStringAsFixed(2),
                  style: AppTextStyle(context)
                      .bodyText
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            onTap: () => _open(o),
          ),
        );
      },
    );
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
