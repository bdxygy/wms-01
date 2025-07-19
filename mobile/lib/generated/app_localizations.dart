import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WMS Mobile'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Management System'**
  String get appTagline;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @welcomeToWMS.
  ///
  /// In en, this message translates to:
  /// **'Welcome to WMS'**
  String get welcomeToWMS;

  /// No description provided for @signInDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your warehouse management system'**
  String get signInDescription;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordMinLength;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @needHelpSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Need help signing in?'**
  String get needHelpSigningIn;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @contactSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'For login assistance, please contact your system administrator or IT support team.'**
  String get contactSupportMessage;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @networkConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkConnectionError;

  /// No description provided for @requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get requestTimeout;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @loginInProgress.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loginInProgress;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @ownerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @staffDashboard.
  ///
  /// In en, this message translates to:
  /// **'Staff Dashboard'**
  String get staffDashboard;

  /// No description provided for @cashierDashboard.
  ///
  /// In en, this message translates to:
  /// **'Cashier Dashboard'**
  String get cashierDashboard;

  /// No description provided for @wmsDashboard.
  ///
  /// In en, this message translates to:
  /// **'WMS Dashboard'**
  String get wmsDashboard;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @scanAndSell.
  ///
  /// In en, this message translates to:
  /// **'Scan & Sell'**
  String get scanAndSell;

  /// No description provided for @productCheck.
  ///
  /// In en, this message translates to:
  /// **'Product Check'**
  String get productCheck;

  /// No description provided for @findProduct.
  ///
  /// In en, this message translates to:
  /// **'Find Product'**
  String get findProduct;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @viewProducts.
  ///
  /// In en, this message translates to:
  /// **'View & manage products'**
  String get viewProducts;

  /// No description provided for @viewProductsReadOnly.
  ///
  /// In en, this message translates to:
  /// **'View products (read-only)'**
  String get viewProductsReadOnly;

  /// No description provided for @viewProductsForSale.
  ///
  /// In en, this message translates to:
  /// **'View products for sale'**
  String get viewProductsForSale;

  /// No description provided for @quickProductLookup.
  ///
  /// In en, this message translates to:
  /// **'Quick product lookup'**
  String get quickProductLookup;

  /// No description provided for @qualityVerification.
  ///
  /// In en, this message translates to:
  /// **'Quality verification'**
  String get qualityVerification;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @productsList.
  ///
  /// In en, this message translates to:
  /// **'Products List'**
  String get productsList;

  /// No description provided for @productsListReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Products List (read-only) page coming soon!'**
  String get productsListReadOnly;

  /// No description provided for @productsListForSales.
  ///
  /// In en, this message translates to:
  /// **'Products List (for sales) page coming soon!'**
  String get productsListForSales;

  /// No description provided for @productsListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Products List page coming soon!'**
  String get productsListComingSoon;

  /// No description provided for @productSearchComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Product Search feature coming soon!'**
  String get productSearchComingSoon;

  /// No description provided for @scannerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Scanner feature coming soon!'**
  String get scannerComingSoon;

  /// No description provided for @addProductComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Add Product feature coming soon!'**
  String get addProductComingSoon;

  /// No description provided for @productCheckComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Product Check feature coming soon!'**
  String get productCheckComingSoon;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @createSale.
  ///
  /// In en, this message translates to:
  /// **'Create sale transaction'**
  String get createSale;

  /// No description provided for @quickBarcodeSale.
  ///
  /// In en, this message translates to:
  /// **'Quick barcode sale'**
  String get quickBarcodeSale;

  /// No description provided for @newSaleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'New Sale feature coming soon!'**
  String get newSaleComingSoon;

  /// No description provided for @createSaleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Sale feature coming soon!'**
  String get createSaleComingSoon;

  /// No description provided for @scanAndSellComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Scan & Sell feature coming soon!'**
  String get scanAndSellComingSoon;

  /// No description provided for @createTransactionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Transaction feature coming soon!'**
  String get createTransactionComingSoon;

  /// No description provided for @transactionsListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Transactions List page coming soon!'**
  String get transactionsListComingSoon;

  /// No description provided for @myTransactionsListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'My Transactions List page coming soon!'**
  String get myTransactionsListComingSoon;

  /// No description provided for @allTransactionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'All Transactions feature coming soon!'**
  String get allTransactionsComingSoon;

  /// No description provided for @viewTransactions.
  ///
  /// In en, this message translates to:
  /// **'View & manage transactions'**
  String get viewTransactions;

  /// No description provided for @viewMyTransactions.
  ///
  /// In en, this message translates to:
  /// **'View my transactions'**
  String get viewMyTransactions;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @selectStore.
  ///
  /// In en, this message translates to:
  /// **'Select Store'**
  String get selectStore;

  /// No description provided for @currentStore.
  ///
  /// In en, this message translates to:
  /// **'Current Store'**
  String get currentStore;

  /// No description provided for @noStoreSelected.
  ///
  /// In en, this message translates to:
  /// **'No store selected'**
  String get noStoreSelected;

  /// No description provided for @changeStore.
  ///
  /// In en, this message translates to:
  /// **'Change Store'**
  String get changeStore;

  /// No description provided for @storeSelection.
  ///
  /// In en, this message translates to:
  /// **'Store Selection'**
  String get storeSelection;

  /// No description provided for @welcomeChooseStore.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Please choose a store to continue.'**
  String get welcomeChooseStore;

  /// No description provided for @noStoresAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stores available for your account.'**
  String get noStoresAvailable;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please contact your administrator.'**
  String get contactAdmin;

  /// No description provided for @storeManagement.
  ///
  /// In en, this message translates to:
  /// **'Store Management'**
  String get storeManagement;

  /// No description provided for @multiStoreOverview.
  ///
  /// In en, this message translates to:
  /// **'Multi-Store Overview'**
  String get multiStoreOverview;

  /// No description provided for @noStoresCreated.
  ///
  /// In en, this message translates to:
  /// **'No stores created yet'**
  String get noStoresCreated;

  /// No description provided for @createFirstStore.
  ///
  /// In en, this message translates to:
  /// **'Create your first store to start managing inventory'**
  String get createFirstStore;

  /// No description provided for @createStore.
  ///
  /// In en, this message translates to:
  /// **'Create Store'**
  String get createStore;

  /// No description provided for @addStore.
  ///
  /// In en, this message translates to:
  /// **'Add Store'**
  String get addStore;

  /// No description provided for @selectStoreToView.
  ///
  /// In en, this message translates to:
  /// **'Select store to view details ({count} total)'**
  String selectStoreToView(int count);

  /// No description provided for @storeDetailsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Store Details feature coming soon!'**
  String get storeDetailsComingSoon;

  /// No description provided for @storeManagementComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Store Management feature coming soon!'**
  String get storeManagementComingSoon;

  /// No description provided for @addStoreComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Add Store feature coming soon!'**
  String get addStoreComingSoon;

  /// No description provided for @viewStores.
  ///
  /// In en, this message translates to:
  /// **'View & manage stores'**
  String get viewStores;

  /// No description provided for @storesListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Stores List page coming soon!'**
  String get storesListComingSoon;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @manageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage Staff'**
  String get manageStaff;

  /// No description provided for @staffManagement.
  ///
  /// In en, this message translates to:
  /// **'Staff management'**
  String get staffManagement;

  /// No description provided for @manageStaffComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Manage Staff feature coming soon!'**
  String get manageStaffComingSoon;

  /// No description provided for @userManagementComingSoon.
  ///
  /// In en, this message translates to:
  /// **'User Management feature coming soon!'**
  String get userManagementComingSoon;

  /// No description provided for @usersListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Users List page coming soon!'**
  String get usersListComingSoon;

  /// No description provided for @viewUsers.
  ///
  /// In en, this message translates to:
  /// **'View & manage users'**
  String get viewUsers;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @viewCategories.
  ///
  /// In en, this message translates to:
  /// **'View & manage categories'**
  String get viewCategories;

  /// No description provided for @categoriesListComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Categories List page coming soon!'**
  String get categoriesListComingSoon;

  /// No description provided for @categoriesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Categories feature coming soon!'**
  String get categoriesComingSoon;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings & store'**
  String get appSettings;

  /// No description provided for @appConfiguration.
  ///
  /// In en, this message translates to:
  /// **'App configuration'**
  String get appConfiguration;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @appSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettingsSection;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updatePassword;

  /// No description provided for @emailSettings.
  ///
  /// In en, this message translates to:
  /// **'Email Settings'**
  String get emailSettings;

  /// No description provided for @manageEmailPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage email preferences'**
  String get manageEmailPreferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get manageNotificationPreferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Light, Dark, or System'**
  String get themeDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @manageLocalData.
  ///
  /// In en, this message translates to:
  /// **'Manage local data and cache'**
  String get manageLocalData;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @getHelpOrSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help or contact support'**
  String get getHelpOrSupport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @viewPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'View privacy policy'**
  String get viewPrivacyPolicy;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @warehouseManagementSystem.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Management System'**
  String get warehouseManagementSystem;

  /// No description provided for @appVersionNumber.
  ///
  /// In en, this message translates to:
  /// **'WMS Mobile v1.0.0'**
  String get appVersionNumber;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A complete inventory management system for tracking goods across multiple stores.'**
  String get appDescription;

  /// No description provided for @editProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile feature coming soon!'**
  String get editProfileComingSoon;

  /// No description provided for @changePasswordComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Change Password feature coming soon!'**
  String get changePasswordComingSoon;

  /// No description provided for @emailSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Email Settings feature coming soon!'**
  String get emailSettingsComingSoon;

  /// No description provided for @notificationSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings feature coming soon!'**
  String get notificationSettingsComingSoon;

  /// No description provided for @themeSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings feature coming soon!'**
  String get themeSettingsComingSoon;

  /// No description provided for @languageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Language Settings feature coming soon!'**
  String get languageSettingsComingSoon;

  /// No description provided for @storageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Storage Settings feature coming soon!'**
  String get storageSettingsComingSoon;

  /// No description provided for @helpAndSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support feature coming soon!'**
  String get helpAndSupportComingSoon;

  /// No description provided for @privacyPolicyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy feature coming soon!'**
  String get privacyPolicyComingSoon;

  /// No description provided for @welcomeBackUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeBackUser(String name);

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get roleAdmin;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'STAFF'**
  String get roleStaff;

  /// No description provided for @roleCashier.
  ///
  /// In en, this message translates to:
  /// **'CASHIER'**
  String get roleCashier;

  /// No description provided for @roleUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get roleUnknown;

  /// No description provided for @storeOverviewReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Store Overview (Read-Only)'**
  String get storeOverviewReadOnly;

  /// No description provided for @viewMode.
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get viewMode;

  /// No description provided for @salesMode.
  ///
  /// In en, this message translates to:
  /// **'Sales Mode'**
  String get salesMode;

  /// No description provided for @pointOfSale.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get pointOfSale;

  /// No description provided for @storePerformance.
  ///
  /// In en, this message translates to:
  /// **'Store Performance'**
  String get storePerformance;

  /// No description provided for @todaySales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get todaySales;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @averageTransaction.
  ///
  /// In en, this message translates to:
  /// **'Average transaction'**
  String get averageTransaction;

  /// No description provided for @numberOfSales.
  ///
  /// In en, this message translates to:
  /// **'Number of sales'**
  String get numberOfSales;

  /// No description provided for @averageSale.
  ///
  /// In en, this message translates to:
  /// **'Avg. Sale'**
  String get averageSale;

  /// No description provided for @itemsSold.
  ///
  /// In en, this message translates to:
  /// **'Items Sold'**
  String get itemsSold;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total items'**
  String get totalItems;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @myChecksToday.
  ///
  /// In en, this message translates to:
  /// **'My Checks Today'**
  String get myChecksToday;

  /// No description provided for @pendingChecks.
  ///
  /// In en, this message translates to:
  /// **'Pending Checks'**
  String get pendingChecks;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @businessIntelligenceDashboard.
  ///
  /// In en, this message translates to:
  /// **'Business Intelligence Dashboard'**
  String get businessIntelligenceDashboard;

  /// No description provided for @comprehensiveAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Analytics for {storeName}'**
  String comprehensiveAnalytics(String storeName);

  /// No description provided for @salesPerformance.
  ///
  /// In en, this message translates to:
  /// **'Sales Performance'**
  String get salesPerformance;

  /// No description provided for @inventoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// No description provided for @operationsQualityControl.
  ///
  /// In en, this message translates to:
  /// **'Operations & Quality Control'**
  String get operationsQualityControl;

  /// No description provided for @productChecks.
  ///
  /// In en, this message translates to:
  /// **'Product Checks'**
  String get productChecks;

  /// No description provided for @totalChecksToday.
  ///
  /// In en, this message translates to:
  /// **'Total checks today'**
  String get totalChecksToday;

  /// No description provided for @requiresAttention.
  ///
  /// In en, this message translates to:
  /// **'Requires attention'**
  String get requiresAttention;

  /// No description provided for @activeUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// No description provided for @totalStores.
  ///
  /// In en, this message translates to:
  /// **'Total Stores'**
  String get totalStores;

  /// No description provided for @quickNavigation.
  ///
  /// In en, this message translates to:
  /// **'Quick Navigation'**
  String get quickNavigation;

  /// No description provided for @quickNavigationFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Navigation (Full Access)'**
  String get quickNavigationFullAccess;

  /// No description provided for @quickNavigationAdminAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Navigation (Admin Access)'**
  String get quickNavigationAdminAccess;

  /// No description provided for @quickNavigationReadOnlyAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Navigation (Read-Only Access)'**
  String get quickNavigationReadOnlyAccess;

  /// No description provided for @quickNavigationTransactionFocus.
  ///
  /// In en, this message translates to:
  /// **'Quick Navigation (Transaction Focus)'**
  String get quickNavigationTransactionFocus;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @fastSaleOptions.
  ///
  /// In en, this message translates to:
  /// **'Fast Sale Options'**
  String get fastSaleOptions;

  /// No description provided for @selectPreferredMethod.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred method to create a sale:'**
  String get selectPreferredMethod;

  /// No description provided for @createNewSale.
  ///
  /// In en, this message translates to:
  /// **'Create New Sale'**
  String get createNewSale;

  /// No description provided for @lastSale.
  ///
  /// In en, this message translates to:
  /// **'Last Sale'**
  String get lastSale;

  /// No description provided for @reprintReceipt.
  ///
  /// In en, this message translates to:
  /// **'Reprint Receipt'**
  String get reprintReceipt;

  /// No description provided for @dailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get dailyReport;

  /// No description provided for @lastSaleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Last Sale feature coming soon!'**
  String get lastSaleComingSoon;

  /// No description provided for @reprintReceiptComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reprint Receipt feature coming soon!'**
  String get reprintReceiptComingSoon;

  /// No description provided for @dailyReportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Daily Report feature coming soon!'**
  String get dailyReportComingSoon;

  /// No description provided for @todaysSalesSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sales Summary'**
  String get todaysSalesSummary;

  /// No description provided for @productChecking.
  ///
  /// In en, this message translates to:
  /// **'Product Checking'**
  String get productChecking;

  /// No description provided for @quickProductCheck.
  ///
  /// In en, this message translates to:
  /// **'Quick Product Check'**
  String get quickProductCheck;

  /// No description provided for @useButtonsToCheck.
  ///
  /// In en, this message translates to:
  /// **'Use the buttons below to quickly check product status:'**
  String get useButtonsToCheck;

  /// No description provided for @storeInformation.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get storeInformation;

  /// No description provided for @inventoryOverview.
  ///
  /// In en, this message translates to:
  /// **'Inventory Overview'**
  String get inventoryOverview;

  /// No description provided for @checkStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get checkStatusPending;

  /// No description provided for @checkStatusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get checkStatusOk;

  /// No description provided for @checkStatusMissing.
  ///
  /// In en, this message translates to:
  /// **'MISSING'**
  String get checkStatusMissing;

  /// No description provided for @checkStatusBroken.
  ///
  /// In en, this message translates to:
  /// **'BROKEN'**
  String get checkStatusBroken;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @statusProductsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{status} products feature coming soon!'**
  String statusProductsComingSoon(String status);

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @recentTransactionsAllStores.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions (All Stores)'**
  String get recentTransactionsAllStores;

  /// No description provided for @recentProductChecks.
  ///
  /// In en, this message translates to:
  /// **'Recent Product Checks'**
  String get recentProductChecks;

  /// No description provided for @myRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'My Recent Transactions'**
  String get myRecentTransactions;

  /// No description provided for @storeOperationsActivity.
  ///
  /// In en, this message translates to:
  /// **'Store Operations Activity'**
  String get storeOperationsActivity;

  /// No description provided for @multiStoreSummary.
  ///
  /// In en, this message translates to:
  /// **'Multi-Store Summary'**
  String get multiStoreSummary;

  /// No description provided for @allChecksComingSoon.
  ///
  /// In en, this message translates to:
  /// **'All Checks feature coming soon!'**
  String get allChecksComingSoon;

  /// No description provided for @allProductChecksComingSoon.
  ///
  /// In en, this message translates to:
  /// **'All Product Checks feature coming soon!'**
  String get allProductChecksComingSoon;

  /// No description provided for @pendingChecksComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Pending Checks feature coming soon!'**
  String get pendingChecksComingSoon;

  /// No description provided for @mySalesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'My Sales feature coming soon!'**
  String get mySalesComingSoon;

  /// No description provided for @storeActivityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Store Activity feature coming soon!'**
  String get storeActivityComingSoon;

  /// No description provided for @allActivityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'All Activity feature coming soon!'**
  String get allActivityComingSoon;

  /// No description provided for @reportsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reports feature coming soon!'**
  String get reportsComingSoon;

  /// No description provided for @inventoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Inventory feature coming soon!'**
  String get inventoryComingSoon;

  /// No description provided for @lowStockComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Low Stock feature coming soon!'**
  String get lowStockComingSoon;

  /// No description provided for @salesReportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sales Report feature coming soon!'**
  String get salesReportComingSoon;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @businessAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Business analytics'**
  String get businessAnalytics;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @unknownRole.
  ///
  /// In en, this message translates to:
  /// **'Unknown Role'**
  String get unknownRole;

  /// No description provided for @roleNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'Your user role is not recognized. Please contact your administrator.'**
  String get roleNotRecognized;

  /// No description provided for @oopsWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsWentWrong;

  /// No description provided for @goToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {location}'**
  String pageNotFound(String location);

  /// No description provided for @failedToLogout.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout: {error}'**
  String failedToLogout(String error);

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @pleaseSelectStoreToContine.
  ///
  /// In en, this message translates to:
  /// **'Please select a store to continue'**
  String get pleaseSelectStoreToContine;

  /// No description provided for @loadingAvailableStores.
  ///
  /// In en, this message translates to:
  /// **'Loading available stores...'**
  String get loadingAvailableStores;

  /// No description provided for @failedToLoadStoresRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stores. Please try again.'**
  String get failedToLoadStoresRetry;

  /// No description provided for @availableStoresCount.
  ///
  /// In en, this message translates to:
  /// **'Available Stores ({count})'**
  String availableStoresCount(int count);

  /// No description provided for @noStoresAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No stores available'**
  String get noStoresAvailableTitle;

  /// No description provided for @contactAdminForStoreAssignment.
  ///
  /// In en, this message translates to:
  /// **'Please contact your administrator to assign you to a store.'**
  String get contactAdminForStoreAssignment;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @continueToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Continue to Dashboard'**
  String get continueToDashboard;

  /// No description provided for @signOutAndUseDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out and use different account'**
  String get signOutAndUseDifferentAccount;

  /// No description provided for @failedToSelectStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to select store: {error}'**
  String failedToSelectStore(String error);

  /// No description provided for @failedToSignOut.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign out: {error}'**
  String failedToSignOut(String error);
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
