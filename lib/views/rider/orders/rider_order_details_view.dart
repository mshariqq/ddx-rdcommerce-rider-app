import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ddx_rider/components/ecommerce/custom_button.dart';
import 'package:ddx_rider/config/app_text_style.dart';
import 'package:ddx_rider/controllers/rider/rider_order_controller.dart';
import 'package:ddx_rider/models/rider/rider_order.dart';
import 'package:ddx_rider/utils/global_function.dart';

/// Order details for ([orderId], [orderCode]) — BOTH required by the API.
/// Shows customer, pickup/delivery addresses, items, COD amount, call + map
/// actions, and a single "Advance to next stage" button (the server derives
/// the next status itself).
class RiderOrderDetailsView extends ConsumerStatefulWidget {
  final int orderId;
  final String orderCode;

  const RiderOrderDetailsView({
    super.key,
    required this.orderId,
    required this.orderCode,
  });

  @override
  ConsumerState<RiderOrderDetailsView> createState() =>
      _RiderOrderDetailsViewState();
}

class _RiderOrderDetailsViewState
    extends ConsumerState<RiderOrderDetailsView> {
  RiderOrderDetails? _details;
  bool _loading = true;
  bool _advancing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final details =
        await ref.read(riderOrderControllerProvider.notifier).details(
              orderId: widget.orderId,
              orderCode: widget.orderCode,
            );
    if (!mounted) return;
    setState(() {
      _details = details;
      _loading = false;
      if (details == null) _error = 'Failed to load order details.';
    });
  }

  Future<void> _advance() async {
    setState(() => _advancing = true);
    final details =
        await ref.read(riderOrderControllerProvider.notifier).advanceStage(
              orderId: widget.orderId,
              orderCode: widget.orderCode,
            );
    if (!mounted) return;
    setState(() => _advancing = false);
    if (details != null) {
      setState(() => _details = details);
      GlobalFunction.showCustomSnackbar(
        message: 'Order moved to ${details.orderStatus}',
        isSuccess: true,
      );
    } else {
      GlobalFunction.showCustomSnackbar(
        message: 'Failed to update order status',
        isSuccess: false,
      );
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _openMap(String query) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  static String _address(Map<String, dynamic> address) {
    if (address.isEmpty) return '-';
    final formatted =
        GlobalFunction.formatDeliveryAddress(address: address);
    if (formatted.isNotEmpty) return formatted;
    final parts = address.values
        .where((v) => v != null && v.toString().trim().isNotEmpty)
        .map((v) => v.toString().trim())
        .toList();
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  static List<Map<String, dynamic>> _items(Map<String, dynamic> raw) {
    for (final key in ['items', 'products', 'order_items', 'details']) {
      final v = raw[key];
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderCode.isEmpty
            ? 'Order #${widget.orderId}'
            : widget.orderCode),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _details == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error ?? 'Order not found',
                style: AppTextStyle(context).bodyTextSmall),
            Gap(16.h),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final d = _details!;
    final items = _items(d.raw);
    final isCod = d.paymentMethod.toLowerCase().contains('cash') ||
        d.paymentStatus.toLowerCase() != 'paid';
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GlobalFunction.getStatusWidget(
                  context: context,
                  status: d.orderStatus.isEmpty ? 'pending' : d.orderStatus),
              Gap(8.w),
              Expanded(
                child: Text('ETA: ${d.estimatedDeliveryDate}',
                    style: AppTextStyle(context).bodyTextSmall),
              ),
            ],
          ),
          Gap(16.h),
          _section('Customer', [
            _row('Name', d.customerName),
            _row('Phone', d.customerPhone),
            Gap(8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: d.customerPhone.isEmpty
                        ? null
                        : () => _call(d.customerPhone),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
          ]),
          Gap(12.h),
          _section('Pickup (shop)', [
            _row('Shop', d.shopName),
            _row('Phone', d.shopPhone),
            _row('Address', d.shopAddress),
            Gap(8.h),
            OutlinedButton.icon(
              onPressed: () => _openMap(
                  d.shopAddress.isEmpty ? d.shopName : d.shopAddress),
              icon: const Icon(Icons.map),
              label: const Text('Open in Maps'),
            ),
          ]),
          Gap(12.h),
          _section('Delivery', [
            _row('Address', _address(d.customerAddress)),
            Gap(8.h),
            OutlinedButton.icon(
              onPressed: () => _openMap(_address(d.customerAddress)),
              icon: const Icon(Icons.map),
              label: const Text('Open in Maps'),
            ),
          ]),
          Gap(12.h),
          _section('Items (${items.length})', [
            if (items.isEmpty)
              Text('No item breakdown available',
                  style: AppTextStyle(context).bodyTextSmall)
            else
              ...items.map((item) {
                final name = (item['name'] ??
                        item['product_name'] ??
                        item['title'] ??
                        'Item')
                    .toString();
                final qty =
                    (item['quantity'] ?? item['qty'] ?? 1).toString();
                final price =
                    (item['price'] ?? item['amount'] ?? '').toString();
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Expanded(child: Text(name)),
                      Text('x$qty  $price',
                          style: AppTextStyle(context).bodyTextSmall),
                    ],
                  ),
                );
              }),
          ]),
          Gap(12.h),
          _section('Payment', [
            _row('Method', d.paymentMethod),
            _row('Status', d.paymentStatus),
            _row(
              isCod ? 'COD to collect' : 'Amount',
              d.amount.toStringAsFixed(2),
              bold: true,
            ),
          ]),
          Gap(24.h),
          if (_advancing)
            const Center(child: CircularProgressIndicator())
          else
            CustomButton(
              buttonText: 'Advance to next stage',
              onPressed: _advance,
            ),
          Gap(16.h),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyle(context)
                    .subTitle
                    .copyWith(fontSize: 16.sp)),
            Gap(12.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110.w,
              child: Text(label,
                  style: AppTextStyle(context).bodyTextSmall)),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyle(context).bodyText.copyWith(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
