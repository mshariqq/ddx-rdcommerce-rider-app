import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ddx_rider/config/app_constants.dart';
import 'package:ddx_rider/utils/global_function.dart';

class HiveService {
  final Ref ref;

  HiveService(this.ref);

  // save the first open status
  Future setFirstOpenValue({required bool value}) async {
    final appSettingsBox = await Hive.openBox(AppConstants.appSettingsBox);
    appSettingsBox.put(AppConstants.firstOpen, value);
  }

  Future setPrimaryColor({required String color}) async {
    final appSettingsBox = Hive.box(AppConstants.appSettingsBox);
    appSettingsBox.put(AppConstants.primaryColor, color);
  }

  Future setAppLogo({required String logo}) async {
    final appSettingsBox = Hive.box(AppConstants.appSettingsBox);
    appSettingsBox.put(AppConstants.appLogo, logo);
  }

  Future setAppName({required String name}) async {
    final appSettingsBox = Hive.box(AppConstants.appSettingsBox);
    appSettingsBox.put(AppConstants.appName, name);
  }

  Future setAppTheme({required bool isDarkTheme}) async {
    final appSettingsBox = Hive.box(AppConstants.appSettingsBox);
    appSettingsBox.put(AppConstants.isDarkTheme, isDarkTheme);
  }

  Future setSplashLogo({required String splashLogo}) async {
    final appSettingsBox = Hive.box(AppConstants.appSettingsBox);
    appSettingsBox.put(AppConstants.splashLogo, splashLogo);
  }

  // save access token
  Future saveUserAuthToken({required String authToken}) async {
    final authBox = await Hive.openBox(AppConstants.authBox);
    authBox.put(AppConstants.authToken, authToken);
  }

  // save app local
  Future<void> saveAppLocal({required String local}) async {
    final appSettingBox = Hive.box(AppConstants.appSettingsBox);
    appSettingBox.put(AppConstants.appLocal, local);
  }

  // get appLocal
  Future<String?> getAppLocal() async {
    final appSettingBox = Hive.box(AppConstants.appSettingsBox);
    final data = appSettingBox.get(AppConstants.appLocal);
    return data;
  }

  // get user auth token
  Future<String?> getAuthToken() async {
    final authToken = await Hive.openBox(AppConstants.authBox)
        .then((box) => box.get(AppConstants.authToken));

    if (authToken != null) {
      return authToken;
    }
    return null;
  }

  bool userIsLoggedIn() {
    final userAuthToken =
        Hive.box(AppConstants.authBox).get(AppConstants.authToken);
    return userAuthToken == null ? false : true;
  }

  // remove access token
  Future removeUserAuthToken() async {
    final authBox = await Hive.openBox(AppConstants.authBox);
    authBox.clear();
  }

  // save seller/user information as raw map
  Future saveUserInfo({required Map<String, dynamic> userInfo}) async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    userBox.put(AppConstants.userData, userInfo);
  }

  // get seller/user information
  Future<Map<String, dynamic>?> getUserInfo() async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    Map<dynamic, dynamic>? userInfo = userBox.get(AppConstants.userData);
    if (userInfo != null) {
      return userInfo.cast<String, dynamic>();
    }
    return null;
  }


  Future<void> saveCustomerLocation({required double latitude,required double longitude})async {
    final locationBox = Hive.box(AppConstants.appSettingsBox);

     await locationBox.put(AppConstants.latitude, latitude);
     await locationBox.put(AppConstants.longitude, longitude);

    log("--> Saved User Location: $latitude | $longitude");
    GlobalFunction.showCustomSnackbar(message: "User Location has been saved", isSuccess: true);

  }

  double? getLatitude(){
    final locationBox = Hive.box(AppConstants.appSettingsBox);
    return locationBox.get(AppConstants.latitude,defaultValue: null);
  }
  double? getLongitude(){
    final locationBox = Hive.box(AppConstants.appSettingsBox);
    return locationBox.get(AppConstants.longitude,defaultValue: null);
  }


  // Get user first open status
  Future<bool?> getUserFirstOpenStatus() async {
    final appSettingsBox = await Hive.openBox(AppConstants.appSettingsBox);
    final status = appSettingsBox.get(AppConstants.firstOpen);
    if (status != null) {
      return status;
    }
    return false;
  }

  // load token and user info
  Future<List<dynamic>?> loadTokenAndUser() async {
    final firstOpenStatus = await getUserFirstOpenStatus();
    final authToken = await getAuthToken();
    final user = await getUserInfo();
    return [firstOpenStatus, authToken, user];
  }

  // remove user data
  Future removeUserData() async {
    final userBox = await Hive.openBox(AppConstants.userBox);
    userBox.clear();
  }

  Future<bool> removeAllData() async {
    try {
      await removeUserAuthToken();
      // await removeUserData();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final hiveServiceProvider = Provider((ref) => HiveService(ref));
