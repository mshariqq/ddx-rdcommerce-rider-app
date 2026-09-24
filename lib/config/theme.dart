import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ddx_rider/config/app_color.dart';

AppColors colors(context) => Theme.of(context).extension<AppColors>()!;
ThemeData getAppTheme(
    {required BuildContext context, required bool isDarkTheme}) {
  AppColor appColor = AppColorManager.getColorClass(serviceName: 'serviceName');
  return ThemeData(
    useMaterial3: true,
    extensions: <ThemeExtension<AppColors>>[
      AppColors(
        primaryColor: appColor.primaryColor,
        accentColor:
            isDarkTheme ? const Color(0xFF1e2420) : appColor.accentColor,
        secondaryColor: appColor.secondaryColor,
        buttonColor: appColor.buttonColor,
        bodyTextColor: isDarkTheme ? appColor.light : appColor.dark,
        light: appColor.light,
        dark: appColor.dark,
        bodyTextSmallColor:
            isDarkTheme ? appColor.accentColor : appColor.bodyTextSmallColor,
        headingColor: isDarkTheme ? appColor.light : appColor.dark,
        hintTextColor: appColor.hintTextColor,
        errorColor: appColor.errorColor,
      ),
    ],
    fontFamily: 'Poppins',
    unselectedWidgetColor: appColor.accentColor,
    scaffoldBackgroundColor: isDarkTheme ? appColor.dark : appColor.light,
    appBarTheme: AppBarTheme(
      // toolbarHeight: 80.h,
      backgroundColor: isDarkTheme ? appColor.dark : appColor.light,
      titleTextStyle: TextStyle(
        color: isDarkTheme ? appColor.light : appColor.dark,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
      ),
      centerTitle: false,
      elevation: 0,
      iconTheme: IconThemeData(
        color: isDarkTheme ? appColor.light : appColor.dark,
      ),
    ),
    colorScheme: ColorScheme(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      primary: appColor.primaryColor,
      onPrimary: appColor.accentColor,
      secondary: appColor.secondaryColor,
      onSecondary: appColor.secondaryColor,
      error: appColor.errorColor,
      onError: appColor.errorColor,
      surface: isDarkTheme ? appColor.dark : appColor.light,
      onSurface: isDarkTheme ? appColor.light : appColor.dark,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      modalBarrierColor: isDarkTheme
          ? const Color(0xFF1e2420).withOpacity(0.8)
          : appColor.accentColor.withOpacity(0.8),
      backgroundColor:
          isDarkTheme ? EcommerceAppColor.black : EcommerceAppColor.white,
      modalBackgroundColor:
          isDarkTheme ? EcommerceAppColor.black : EcommerceAppColor.white,
      surfaceTintColor:
          isDarkTheme ? EcommerceAppColor.black : EcommerceAppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      showDragHandle: true,
    ),
    // ---- DDX reskin: cards, buttons, inputs, bars ----
    cardTheme: CardThemeData(
      color: isDarkTheme ? EcommerceAppColor.black : EcommerceAppColor.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isDarkTheme
              ? const Color(0xFF2A2A3A)
              : const Color(0xFFE4E7EF),
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appColor.buttonColor,
        foregroundColor: EcommerceAppColor.white,
        disabledBackgroundColor: EcommerceAppColor.lightGray,
        disabledForegroundColor: EcommerceAppColor.white,
        elevation: 0,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: appColor.primaryColor,
        side: BorderSide(color: appColor.primaryColor, width: 1.5),
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appColor.primaryColor,
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDarkTheme
          ? const Color(0xFF1A1A2E)
          : EcommerceAppColor.offWhite,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      hintStyle: TextStyle(
        color: appColor.hintTextColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: appColor.bodyTextSmallColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE4E7EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE4E7EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: appColor.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: appColor.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: appColor.errorColor, width: 1.5),
      ),
      isDense: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor:
          isDarkTheme ? const Color(0xFF1A1A2E) : EcommerceAppColor.blueChalk,
      selectedColor: appColor.primaryColor,
      disabledColor: EcommerceAppColor.lightGray,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: appColor.primaryColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: Colors.transparent),
      ),
      showCheckmark: false,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor:
          isDarkTheme ? EcommerceAppColor.black : EcommerceAppColor.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: isDarkTheme ? appColor.light : appColor.dark,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE4E7EF),
      thickness: 1,
      space: 16,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:
          isDarkTheme ? EcommerceAppColor.black : EcommerceAppColor.white,
      selectedItemColor: appColor.primaryColor,
      unselectedItemColor: appColor.hintTextColor,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
