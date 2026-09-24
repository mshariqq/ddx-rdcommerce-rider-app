enum Environment { development, production }
 
class AppConstants {
  // TODO(configure): point this at your own backend before release.
  // Example: 'https://your-domain.com/api'
  static const String baseUrl = 'https://ddlist.github.io/api';
  //static const String baseUrl = 'https://armachine.in/api';

  // chatak
  // static const String baseUrl = 'https://www.chatak.pk/api';

  // iGM Mart
  // static const String baseUrl = 'https://commercify.imperiumglobalmedia.com/api';

  // static const String baseUrl = 'https://uat.readyecommerce.app/api';

  //static const Environment environment = Environment.production;

  //static const String baseUrl = environment == Environment.production ? 'https://www.chatak.pk/api' : 'https://chatak.razinsoft.com/api';

  static const String settings = '$baseUrl/master';
  static const String loginUrl = '$baseUrl/login';
  static const String registrationUrl = '$baseUrl/registration';
  static const String sendOTP = '$baseUrl/send-otp';
  static const String verifyOtp = '$baseUrl/verify-otp';
  static const String resetPassword = '$baseUrl/reset-password';
  static const String changePassword = '$baseUrl/change-password';
  static const String updateProfile = '$baseUrl/update-profile';
  static const String getDashboardData = '$baseUrl/home';
  static const String getCategories = '$baseUrl/categories';
  static const String getSubCategories = '$baseUrl/sub-categories';
  static const String getShops = '$baseUrl/shops';
  static const String getShopDetails = '$baseUrl/shops/{shop}';
  static const String getProducts = '$baseUrl/products';
  static const String getShopCategiries = '$baseUrl/shop-categories';
  static const String getReviews = '$baseUrl/reviews';
  static const String getCategoryWiseProducts = '$baseUrl/category-products';
  static const String getProductDetails = '$baseUrl/product-details';
  static const String productFavoriteAddRemoveUrl =
      '$baseUrl/favorite-add-or-remove';
  static const String getFavoriteProducts = '$baseUrl/favorite-products';
  static const String addAddress = '$baseUrl/address/store';
  static const String address = '$baseUrl/addresses';
  static const String getAddress = '$baseUrl/addresses';
  static const String addToCart = '$baseUrl/cart/store';
  static const String incrementQty = '$baseUrl/cart/increment';
  static const String decrementQty = '$baseUrl/cart/decrement';
  static const String getAllCarts = '$baseUrl/carts';
// static const String getAllGifts = '$baseUrl/gifts'; // TODO: API endpoint not implemented
// static const String addGift = '$baseUrl/gift/store';
// static const String updateGift = '$baseUrl/gift/update';
// static const String removeGift = '$baseUrl/gift/delete';
// static const String buyNow = '$baseUrl/buy-now'; // TODO: API endpoint not implemented
// static const String buyNowOrderPlace = '$baseUrl/buy-now/place-order'; // TODO: API endpoint not implemented
static const String cartSummery = '$baseUrl/cart/checkout';
static const String placeOrder = '$baseUrl/place-order';
static const String placeOrderV1 = '$baseUrl/v1/place-order';
static const String orderAgain = '$baseUrl/place-order/again';
  static const String getOrders = '$baseUrl/orders';
  static const String getOrderDetails = '$baseUrl/order-details';
  static const String cancelOrder = '$baseUrl/orders/cancel';
  static const String addProductReview = '$baseUrl/product-review';
  static const String getVoucher = '$baseUrl/get-vouchers';
  static const String collectVoucher = '$baseUrl/vouchers-collect';
  static const String applyVoucher = '$baseUrl/apply-voucher';
  static const String ordePayment = '$baseUrl/order-payment';
  static const String blogs = '$baseUrl/blogs';
  static const String blogDetails = '$baseUrl/blog';

  static const String privacyPolicy = '$baseUrl/legal-pages/privacy-policy';
  static const String termsAndConditions =
      '$baseUrl/legal-pages/terms-and-conditions';
  static const String refundPolicy =
      '$baseUrl/legal-pages/return-and-refund-policy';
  static const String support = '$baseUrl/support';
  static const String contactUs = '$baseUrl/contact-us';
  static const String profileinfo = '$baseUrl/profile';

  static const String logout = '$baseUrl/logout';
  static const String flashSales = '$baseUrl/flash-sales';
  static const String flashSaleDetails = '$baseUrl/flash-sale/{name}/details';
  static const String allCountry = '$baseUrl/countries';
  static const String storeMessage = '$baseUrl/store-message';
  static const String getMessage = '$baseUrl/get-message';
  static const String sendMessage = '$baseUrl/send-message';
  static const String getShopsList = '$baseUrl/get-shops';
  static const String unreadMessage = '$baseUrl/unread-messages';
  static const String returnOrderSubmit = '$baseUrl/return-order';
  static const String returnHistory = '$baseUrl/return-history';
  static const String returnOrdersList = '$baseUrl/return-orders';
  static const String returnOrderDetails = '$baseUrl/return-order-details/{returnOrder}';

  static const String areasListUrl = '$baseUrl/areas';

  // dynamic url based on the service name
  static String getDashboardInfoUrl(String serviceName) =>
      '$baseUrl/api/$serviceName/store/dashoard';

  // seller
  static const sellerBase = '$baseUrl/seller';
  static const sellerLogin = '$sellerBase/login';
  static const sellerRegistration = '$sellerBase/registration';
  static const sellerForgotPassword = '$sellerBase/forgot-password';
  static const sellerSendOtp = '$sellerBase/send-otp';
  static const sellerVerifyOtp = '$sellerBase/verify-otp';
  static const sellerCheckUserStatus = '$sellerBase/check-user-status';
  static const sellerCheckEmailPhone = '$sellerBase/check-email-phone';
  static const sellerChangePassword = '$sellerBase/change-password';
  static const sellerDetails = '$sellerBase/details';
  static const sellerUserUpdate = '$sellerBase/user-update';
  static const sellerShopUpdate = '$sellerBase/shop-update';
  static const sellerShopSettingUpdate = '$sellerBase/shop-setting-update';
  static const sellerLogout = '$sellerBase/logout';
  static const sellerDeleteAccount = '$sellerBase/delete-account';
  static const sellerDashboard = '$sellerBase/dashboard';
  static const sellerOrders = '$sellerBase/orders';
  static const sellerOrderDetails = '$sellerBase/orders/details';
  static const sellerOrderStatusUpdate = '$sellerBase/orders/status-update';
  static const sellerWallet = '$sellerBase/wallet';
  static const sellerWalletHistory = '$sellerBase/wallet/history';
  static const sellerWalletWithdraw = '$sellerBase/wallet/withdraw';
  static const sellerNotifications = '$sellerBase/notifications';
  static String sellerNotificationUpdate(int id) =>
      '$sellerBase/notifications/$id';
  static String sellerNotificationDelete(int id) =>
      '$sellerBase/notifications/$id';
  static const sellerProducts = '$sellerBase/products';
  static const sellerLowStockProducts = '$sellerBase/products/low-stock';
  static const sellerProductStore = '$sellerBase/product/store';
  static String sellerProductUpdate(int id) => '$sellerBase/product/$id/update';
  static String sellerProductShow(int id) => '$sellerBase/product/$id/show';
  static const sellerProductCreateData = '$sellerBase/product/create-data';
  static String sellerProductStatusToggle(int id) =>
      '$sellerBase/product/status/toggle/$id';
  static String sellerProductDestroy(int id) =>
      '$sellerBase/product/$id/destroy';
  static const sellerThumbnailDestroy = '$sellerBase/product/thumbnail/delete';
  static const sellerFilemanagerImage = '$sellerBase/filemanager-image';
  static const sellerFilemanagerUpload = '$sellerBase/filemanager/image-upload';
  static const sellerFilemanagerDelete = '$sellerBase/filemanager/image-delete';
  static const sellerBanners = '$sellerBase/banners';
  static const sellerBannerStore = '$sellerBase/banners/store';
  static const sellerBannerUpdate = '$sellerBase/banners/update';
  static String sellerBannerDestroy(int id) => '$sellerBase/banners/$id';
  static const sellerGetUsers = '$sellerBase/get-users';
  static const sellerGetMessage = '$sellerBase/get-message';
  static const sellerSendMessage = '$sellerBase/send-message';
  static const sellerUnreadMessages = '$sellerBase/unread-messages';
  static const sellerReturnOrders = '$sellerBase/return-orders';
  static String sellerReturnOrderDetails(int id) =>
      '$sellerBase/return-order-details/$id';
  static String sellerReturnOrderStatus(int id) =>
      '$sellerBase/return-order/$id/status-change';

  // rider
  static const riderBase = '$baseUrl/rider';
  static const riderLogin = '$riderBase/login';
  static const riderRegister = '$riderBase/register';
  static const riderCreatePassword = '$riderBase/create-password';
  static const riderSendOtp = '$riderBase/send-otp';
  static const riderVerifyOtp = '$riderBase/verify-otp';
  static const riderCheckUserStatus = '$riderBase/check-user-status';
  static const riderChangePassword = '$riderBase/change-password';
  static const riderDetails = '$riderBase/details';
  static const riderProfileUpdate = '$riderBase/profile-update';
  static const riderLocationUpdate = '$riderBase/location-update';
  static const riderOrders = '$riderBase/orders';
  static const riderOrderDetails = '$riderBase/orders/details';
  static const riderOrderStatusUpdate = '$riderBase/orders/status-update';
  static const riderMyOrders = '$riderBase/my-orders';
  static const riderNotifications = '$riderBase/notifications';
  static const riderNotificationStore = '$riderBase/notifications';
  static String riderNotificationUpdate(int id) =>
      '$riderBase/notifications/$id';
  static String riderNotificationDelete(int id) =>
      '$riderBase/notifications/$id';
  static const riderLogout = '$riderBase/logout';
  static const riderDeleteAccount = '$riderBase/delete-account';

  // hive constants

  // Box Names
  static const String appSettingsBox = 'appSettings';
  static const String authBox = 'laundrySeller_authBox';
  static const String userBox = 'laundrySeller_userBox';
  static const String cartModelBox = 'hive_cart_model_box';

  // Settings Veriable Names
  static const String firstOpen = 'firstOpen';
  static const String appLocal = 'appLocal';
  static const String isDarkTheme = 'isDarkTheme';
  static const String primaryColor = 'primaryColor';
  static const String appLogo = 'appLogo';
  static const String appName = 'appName';
  static const String splashLogo = 'splashLogo';

  // Auth Variable Names
  static const String authToken = 'token';

  // User Variable Names
  static const String userData = 'userData';
  static const String storeData = 'storeData';
  static const String cartData = 'cartData';
  static const String defaultAddress = 'defaultAddress';

  static String appCurrency = "\$";
  static String appServiceName = 'ecommerce';

  static String latitude = 'latitude';
  static String longitude = 'longitude';

  // static String pusherApiKey = 'a3cbadc04a202a7746fc';
  // static String pusherCluster = 'mt1';
  static String pusherApiKey = 'a5aabe1d00d4022dbb11';
  static String pusherCluster = 'ap2';
  // static String googleApiKey = "AIzaSyDNesExi2V6RPZFyBEsH2FWSoefGKIldik";
  //  static String googleApiKey = "AIzaSyACxvaQEVw0mxj5Eo2Wkl_rQ6vZrszpPNs";
  static String googleApiKey = "AIzaSyB-iGXLTfsGrwWMwbfNFVKctmPBbZIOJvI";
}

enum FileSystem { file, image }
