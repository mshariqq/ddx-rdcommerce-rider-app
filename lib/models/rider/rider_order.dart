/// List item from `GET rider/orders` / `GET rider/my-orders`
/// (RiderOrderResource — wraps a driver_order row around `order`/`preOrder`).
class RiderOrder {
  final int id;
  final String orderType;
  final String orderCode;
  final double amount;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;
  final Map<String, dynamic> customerAddress;
  final String shopName;
  final String shopPhone;
  final String shopAddress;
  final String shopLatitude;
  final String shopLongitude;
  final Map<String, dynamic> raw;

  const RiderOrder({
    required this.id,
    required this.orderType,
    required this.orderCode,
    required this.amount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress = const {},
    required this.shopName,
    required this.shopPhone,
    required this.shopAddress,
    required this.shopLatitude,
    required this.shopLongitude,
    this.raw = const {},
  });

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map) return v.map((k, e) => MapEntry(k.toString(), e));
    return <String, dynamic>{};
  }

  static String _str(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  static double _dbl(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory RiderOrder.fromJson(dynamic json) {
    final map = _asMap(json);
    final user = _asMap(map['user']);
    final shop = _asMap(map['shop']);
    return RiderOrder(
      id: _int(map['id']),
      orderType: _str(map['order_type']),
      orderCode: _str(map['order_code']),
      amount: _dbl(map['amount']),
      orderStatus: _str(map['order_status']),
      paymentStatus: _str(map['payment_status']),
      paymentMethod: _str(map['payment_method']),
      customerName: _str(user['name']),
      customerPhone: _str(user['phone']),
      customerAddress: _asMap(user['address']),
      shopName: _str(shop['name']),
      shopPhone: _str(shop['phone']),
      shopAddress: _str(shop['address']),
      shopLatitude: _str(shop['latitude']),
      shopLongitude: _str(shop['longitude']),
      raw: map,
    );
  }

  static List<RiderOrder> listFromJson(dynamic json) {
    if (json is List) {
      return json.map(RiderOrder.fromJson).toList();
    }
    return [];
  }
}

/// Details from `GET rider/orders/details` /
/// `POST rider/orders/status-update` (RiderOrderDetailsResource).
class RiderOrderDetails {
  final int id;
  final String orderCode;
  final double amount;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String estimatedDeliveryDate;
  final String? pickupDate;
  final String customerName;
  final String customerPhone;
  final String? customerPhoto;
  final Map<String, dynamic> customerAddress;
  final String shopName;
  final String? shopLogo;
  final String shopPhone;
  final String shopAddress;
  final Map<String, dynamic> raw;

  const RiderOrderDetails({
    required this.id,
    required this.orderCode,
    required this.amount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.estimatedDeliveryDate,
    this.pickupDate,
    required this.customerName,
    required this.customerPhone,
    this.customerPhoto,
    this.customerAddress = const {},
    required this.shopName,
    this.shopLogo,
    required this.shopPhone,
    required this.shopAddress,
    this.raw = const {},
  });

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map) return v.map((k, e) => MapEntry(k.toString(), e));
    return <String, dynamic>{};
  }

  static String _str(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  static double _dbl(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory RiderOrderDetails.fromJson(dynamic json) {
    final map = _asMap(json);
    final user = _asMap(map['user']);
    final shop = _asMap(map['shop']);
    return RiderOrderDetails(
      id: _int(map['id']),
      orderCode: _str(map['order_code']),
      amount: _dbl(map['amount']),
      orderStatus: _str(map['order_status']),
      paymentStatus: _str(map['payment_status']),
      paymentMethod: _str(map['payment_method']),
      estimatedDeliveryDate: _str(map['estimated_delivery_date']),
      pickupDate: map['pickup_date']?.toString(),
      customerName: _str(user['name']),
      customerPhone: _str(user['phone']),
      customerPhoto: user['profile_photo']?.toString(),
      customerAddress: _asMap(user['address']),
      shopName: _str(shop['name']),
      shopLogo: shop['logo']?.toString(),
      shopPhone: _str(shop['phone']),
      shopAddress: _str(shop['address']),
      raw: map,
    );
  }
}
