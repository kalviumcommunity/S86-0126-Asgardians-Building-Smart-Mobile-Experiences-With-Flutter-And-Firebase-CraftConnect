import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CraftConnect'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Digital Storefront for Local Artisans'**
  String get tagline;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phone;

  /// No description provided for @auth_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_name;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_dontHaveAccount;

  /// No description provided for @auth_alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_alreadyHaveAccount;

  /// No description provided for @auth_signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get auth_signInWithEmail;

  /// No description provided for @auth_signInWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Phone'**
  String get auth_signInWithPhone;

  /// No description provided for @auth_verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get auth_verifyOTP;

  /// No description provided for @auth_enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get auth_enterOTP;

  /// No description provided for @auth_resendOTP.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get auth_resendOTP;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @role_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get role_selection_title;

  /// No description provided for @role_artisan.
  ///
  /// In en, this message translates to:
  /// **'Artisan (Seller)'**
  String get role_artisan;

  /// No description provided for @role_artisan_desc.
  ///
  /// In en, this message translates to:
  /// **'Create your shop and sell products'**
  String get role_artisan_desc;

  /// No description provided for @role_buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get role_buyer;

  /// No description provided for @role_buyer_desc.
  ///
  /// In en, this message translates to:
  /// **'Browse and buy from local artisans'**
  String get role_buyer_desc;

  /// No description provided for @shop_create.
  ///
  /// In en, this message translates to:
  /// **'Create Shop'**
  String get shop_create;

  /// No description provided for @shop_name.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shop_name;

  /// No description provided for @shop_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get shop_description;

  /// No description provided for @shop_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get shop_contact;

  /// No description provided for @shop_image.
  ///
  /// In en, this message translates to:
  /// **'Shop Image'**
  String get shop_image;

  /// No description provided for @shop_yourShop.
  ///
  /// In en, this message translates to:
  /// **'Your Shop'**
  String get shop_yourShop;

  /// No description provided for @shop_storeLink.
  ///
  /// In en, this message translates to:
  /// **'Store Link'**
  String get shop_storeLink;

  /// No description provided for @shop_copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get shop_copyLink;

  /// No description provided for @shop_shareStore.
  ///
  /// In en, this message translates to:
  /// **'Share Store'**
  String get shop_shareStore;

  /// No description provided for @product_add.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get product_add;

  /// No description provided for @product_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get product_edit;

  /// No description provided for @product_name.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get product_name;

  /// No description provided for @product_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get product_description;

  /// No description provided for @product_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get product_price;

  /// No description provided for @product_stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get product_stock;

  /// No description provided for @product_image.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get product_image;

  /// No description provided for @product_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get product_available;

  /// No description provided for @product_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get product_outOfStock;

  /// No description provided for @product_inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get product_inStock;

  /// No description provided for @product_shareProduct.
  ///
  /// In en, this message translates to:
  /// **'Share Product'**
  String get product_shareProduct;

  /// No description provided for @product_productLink.
  ///
  /// In en, this message translates to:
  /// **'Product Link'**
  String get product_productLink;

  /// No description provided for @order_new.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get order_new;

  /// No description provided for @order_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get order_accepted;

  /// No description provided for @order_shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get order_shipped;

  /// No description provided for @order_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get order_completed;

  /// No description provided for @order_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get order_cancelled;

  /// No description provided for @order_status.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get order_status;

  /// No description provided for @order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_details;

  /// No description provided for @order_buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get order_buyer;

  /// No description provided for @order_address.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get order_address;

  /// No description provided for @order_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get order_quantity;

  /// No description provided for @order_total.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get order_total;

  /// No description provided for @order_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get order_accept;

  /// No description provided for @order_ship.
  ///
  /// In en, this message translates to:
  /// **'Mark as Shipped'**
  String get order_ship;

  /// No description provided for @order_complete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get order_complete;

  /// No description provided for @order_cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get order_cancelOrder;

  /// No description provided for @order_trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get order_trackOrder;

  /// No description provided for @payment_title.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment_title;

  /// No description provided for @payment_upi.
  ///
  /// In en, this message translates to:
  /// **'UPI Payment'**
  String get payment_upi;

  /// No description provided for @payment_enterUPI.
  ///
  /// In en, this message translates to:
  /// **'Enter UPI ID'**
  String get payment_enterUPI;

  /// No description provided for @payment_pay.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payment_pay;

  /// No description provided for @payment_success.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get payment_success;

  /// No description provided for @payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get payment_failed;

  /// No description provided for @payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get payment_pending;

  /// No description provided for @dashboard_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get dashboard_welcome;

  /// No description provided for @dashboard_totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get dashboard_totalProducts;

  /// No description provided for @dashboard_totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get dashboard_totalOrders;

  /// No description provided for @dashboard_pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get dashboard_pendingOrders;

  /// No description provided for @dashboard_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get dashboard_revenue;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settings_profile;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_darkMode;

  /// No description provided for @settings_fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get settings_fontSize;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settings_terms;

  /// No description provided for @settings_returnPolicy.
  ///
  /// In en, this message translates to:
  /// **'Return Policy'**
  String get settings_returnPolicy;

  /// No description provided for @settings_deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete My Data'**
  String get settings_deleteData;

  /// No description provided for @accessibility_button.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get accessibility_button;

  /// No description provided for @accessibility_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get accessibility_image;

  /// No description provided for @accessibility_textField.
  ///
  /// In en, this message translates to:
  /// **'Text field'**
  String get accessibility_textField;

  /// No description provided for @accessibility_backButton.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get accessibility_backButton;

  /// No description provided for @accessibility_menuButton.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get accessibility_menuButton;

  /// No description provided for @cookies_title.
  ///
  /// In en, this message translates to:
  /// **'Cookie Notice'**
  String get cookies_title;

  /// No description provided for @cookies_message.
  ///
  /// In en, this message translates to:
  /// **'We use cookies to improve your experience'**
  String get cookies_message;

  /// No description provided for @cookies_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept All'**
  String get cookies_accept;

  /// No description provided for @cookies_decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get cookies_decline;

  /// No description provided for @cookies_learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get cookies_learnMore;

  /// No description provided for @gdpr_title.
  ///
  /// In en, this message translates to:
  /// **'Delete My Data'**
  String get gdpr_title;

  /// No description provided for @gdpr_warning.
  ///
  /// In en, this message translates to:
  /// **'Permanent Data Deletion'**
  String get gdpr_warning;

  /// No description provided for @gdpr_confirmText.
  ///
  /// In en, this message translates to:
  /// **'DELETE MY DATA'**
  String get gdpr_confirmText;

  /// No description provided for @gdpr_deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete All My Data'**
  String get gdpr_deleteButton;

  /// No description provided for @fontSize_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSize_small;

  /// No description provided for @fontSize_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get fontSize_normal;

  /// No description provided for @fontSize_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSize_large;

  /// No description provided for @fontSize_extraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get fontSize_extraLarge;

  /// No description provided for @quickView_title.
  ///
  /// In en, this message translates to:
  /// **'Quick View'**
  String get quickView_title;

  /// No description provided for @quickView_addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get quickView_addToCart;

  /// No description provided for @quickView_buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get quickView_buyNow;

  /// No description provided for @quickView_viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Full Details'**
  String get quickView_viewDetails;

  /// No description provided for @cart_removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get cart_removeItem;

  /// No description provided for @cart_saveForLater.
  ///
  /// In en, this message translates to:
  /// **'Save for Later'**
  String get cart_saveForLater;

  /// No description provided for @cart_undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get cart_undo;

  /// No description provided for @cart_clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart?'**
  String get cart_clearCart;

  /// No description provided for @tutorial_tapHere.
  ///
  /// In en, this message translates to:
  /// **'Tap here'**
  String get tutorial_tapHere;

  /// No description provided for @tutorial_gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get tutorial_gotIt;

  /// No description provided for @tutorial_swipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see more'**
  String get tutorial_swipeHint;

  /// No description provided for @notification_newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order received!'**
  String get notification_newOrder;

  /// No description provided for @notification_orderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Your order has been accepted'**
  String get notification_orderAccepted;

  /// No description provided for @notification_orderShipped.
  ///
  /// In en, this message translates to:
  /// **'Your order has been shipped'**
  String get notification_orderShipped;

  /// No description provided for @notification_orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your order has been completed'**
  String get notification_orderCompleted;

  /// No description provided for @share_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get share_whatsapp;

  /// No description provided for @share_instagram.
  ///
  /// In en, this message translates to:
  /// **'Share on Instagram'**
  String get share_instagram;

  /// No description provided for @share_facebook.
  ///
  /// In en, this message translates to:
  /// **'Share on Facebook'**
  String get share_facebook;

  /// No description provided for @share_copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get share_copyLink;

  /// No description provided for @error_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get error_invalidEmail;

  /// No description provided for @error_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get error_invalidPhone;

  /// No description provided for @error_requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get error_requiredField;

  /// No description provided for @error_networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again'**
  String get error_networkError;

  /// No description provided for @error_unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get error_unknownError;

  /// No description provided for @success_shopCreated.
  ///
  /// In en, this message translates to:
  /// **'Shop created successfully!'**
  String get success_shopCreated;

  /// No description provided for @success_productAdded.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully!'**
  String get success_productAdded;

  /// No description provided for @success_orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get success_orderPlaced;

  /// No description provided for @success_linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get success_linkCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
