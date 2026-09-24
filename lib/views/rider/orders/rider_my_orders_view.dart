import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:ddx_rider/components/ecommerce/custom_search_field.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_order_controller.dart';
import 'package:ddx_rider/models/rider/rider_order.dart';
import 'package:ddx_rider/routes.dart';
import 'package:ddx_rider/utils/context_less_navigation.dart';
import 'package:ddx_rider/utils/global_function.dart';

/// GET rider/my-orders with status filter chips (to_deliver / delivered)
/// + search. Tap an order -> delivery details.
class RiderMyOrdersView extends ConsumerStatefulWidget {
  const RiderMyOrdersView({super.key});

  @override
  ConsumerState<RiderMyOrdersView> createState() => _RiderMyOrdersViewState();
}

class _RiderMyOrdersViewState extends ConsumerState<RiderMyOrdersView> {
  final _search = TextEditingController();
  Timer? _debounce;
  String? _status = 'to_deliver';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetch());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _fetch() {
    ref.read(riderOrderControllerProvider.notifier).myOrders(
          status: _status,
          search: _search.text,
        );
  }

  void _onSearchChanged(String? _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _fetch);
  }

  void _open(RiderOrder order) {
    context.nav.pushNamed(
      Routes.deliveryDetails,
      arguments: {'orderId': order.id, 'orderCode': order.orderCode},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(riderOrderControllerProvider);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomSearchField(
            name: 'Search orders',
            hintText: 'Search by code, customer...',
            textInputType: TextInputType.text,
            controller: _search,
            widget: const Icon(Icons.search),
            onChanged: _onSearchChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('To deliver'),
                selected: _status == 'to_deliver',
                onSelected: (_) {
                  setState(() => _status = 'to_deliver');
                  _fetch();
                },
              ),
              Gap(8.w),
              ChoiceChip(
                label: const Text('Delivered'),
                selected: _status == 'delivered',
                onSelected: (_) {
                  setState(() => _status = 'delivered');
                  _fetch();
                },
              ),
              Gap(8.w),
              ChoiceChip(
                label: const Text('All'),
                selected: _status == null,
                onSelected: (_) {
                  setState(() => _status = null);
                  _fetch();
                },
              ),
            ],
          ),
        ),
        Gap(8.h),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _fetch(),
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
      return _message('Failed to load orders.\nPull to retry.');
    }
    if (state.orders.isEmpty) {
      return _message('No orders found.');
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: state.orders.length,
      separatorBuilder: (_, __) => Gap(12.h),
      itemBuilder: (context, i) {
        final o = state.orders[i];
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
            subtitle: Text(
              o.customerName.isEmpty ? o.shopName : o.customerName,
              style: AppTextStyle(context).bodyTextSmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GlobalFunction.getStatusWidget(
                    context: context,
                    status: o.orderStatus.isEmpty ? 'pending' : o.orderStatus),
                Gap(4.h),
                Text(o.amount.toStringAsFixed(2),
                    style: AppTextStyle(context)
                        .bodyText
                        .copyWith(fontWeight: FontWeight.w600)),
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
