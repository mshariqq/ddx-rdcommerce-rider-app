class RiderUser {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? photo;
  final bool? isActive;
  final String? vehicle;

  // Extra fields present on RiderUserResource / UserResource (all optional).
  final String? lastName;
  final String? gender;
  final String? dateOfBirth;
  final String? drivingLience;
  final Map<String, dynamic>? location;
  final bool? phoneVerified;
  final bool? emailVerified;
  final String? country;
  final String? phoneCode;
  final Map<String, dynamic> raw;

  const RiderUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.photo,
    this.isActive,
    this.vehicle,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.drivingLience,
    this.location,
    this.phoneVerified,
    this.emailVerified,
    this.country,
    this.phoneCode,
    this.raw = const {},
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String _asString(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map) return v.map((k, e) => MapEntry(k.toString(), e));
    return null;
  }

  factory RiderUser.fromJson(dynamic json) {
    final Map<String, dynamic> map;
    if (json is Map) {
      map = json.map((k, e) => MapEntry(k.toString(), e));
    } else {
      map = <String, dynamic>{};
    }
    return RiderUser(
      id: _asInt(map['id']),
      // Login returns UserResource{name}; register/details return
      // RiderUserResource{first_name, last_name}.
      name: _asString(map['name'] ?? map['first_name']),
      phone: _asString(map['phone']),
      email: map['email']?.toString(),
      photo: (map['profile_photo'] ?? map['photo'] ?? map['thumbnail'])
          ?.toString(),
      isActive: _asBool(map['is_active']),
      vehicle: (map['vehicle_type'] ?? map['vehicle'])?.toString(),
      lastName: map['last_name']?.toString(),
      gender: map['gender']?.toString(),
      dateOfBirth: map['date_of_birth']?.toString(),
      drivingLience: map['driving_lience']?.toString(),
      location: _asMap(map['location']),
      phoneVerified: _asBool(map['phone_verified']),
      emailVerified: _asBool(map['email_verified']),
      country: map['country']?.toString(),
      phoneCode: map['phone_code']?.toString(),
      raw: map,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (photo != null) 'profile_photo': photo,
        if (isActive != null) 'is_active': isActive,
        if (vehicle != null) 'vehicle_type': vehicle,
        if (lastName != null) 'last_name': lastName,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (drivingLience != null) 'driving_lience': drivingLience,
      };
}

/// Wraps `POST rider/login` which responds with
/// `{message, data: {user: UserResource, access: {auth_type, token, expires_at}}}`.
/// The `access` key is verified from LoginController; a plain `token` key is
/// also accepted defensively.
class RiderAuthResponse {
  final String message;
  final RiderUser? user;
  final String accessToken;
  final Map<String, dynamic> raw;

  const RiderAuthResponse({
    required this.message,
    required this.user,
    required this.accessToken,
    this.raw = const {},
  });

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map) return v.map((k, e) => MapEntry(k.toString(), e));
    return <String, dynamic>{};
  }

  static String _extractToken(Map<String, dynamic> data) {
    final access = data['access'];
    if (access is Map) {
      final t = access['token'];
      if (t != null) return t.toString();
    } else if (access != null) {
      final s = access.toString();
      if (s.isNotEmpty) return s;
    }
    final token = data['token'];
    if (token is Map) {
      final t = token['token'] ?? token['access'];
      if (t != null) return t.toString();
    } else if (token != null) {
      return token.toString();
    }
    return '';
  }

  factory RiderAuthResponse.fromResponse(dynamic body) {
    final Map<String, dynamic> map = _asMap(body);
    final Map<String, dynamic> data = _asMap(map['data']);
    final userMap = data['user'];
    return RiderAuthResponse(
      message: map['message']?.toString() ?? '',
      user: userMap == null ? null : RiderUser.fromJson(userMap),
      accessToken: _extractToken(data),
      raw: data,
    );
  }
}
