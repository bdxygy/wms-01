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
    Locale('id')
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

  /// No description provided for @editStore.
  ///
  /// In en, this message translates to:
  /// **'Edit Store'**
  String get editStore;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// No description provided for @storeType.
  ///
  /// In en, this message translates to:
  /// **'Store Type'**
  String get storeType;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

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

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @openTime.
  ///
  /// In en, this message translates to:
  /// **'Open Time'**
  String get openTime;

  /// No description provided for @closeTime.
  ///
  /// In en, this message translates to:
  /// **'Close Time'**
  String get closeTime;

  /// No description provided for @storeInformation.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get storeInformation;

  /// No description provided for @addressInformation.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get addressInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @auditInformation.
  ///
  /// In en, this message translates to:
  /// **'Audit Information'**
  String get auditInformation;

  /// No description provided for @addressLine1.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// No description provided for @addressLine2.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get addressLine2;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get postalCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @mapLocation.
  ///
  /// In en, this message translates to:
  /// **'Map Location'**
  String get mapLocation;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get createdBy;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get updatedAt;

  /// No description provided for @deletedAt.
  ///
  /// In en, this message translates to:
  /// **'Deleted At'**
  String get deletedAt;

  /// No description provided for @confirmDeleteStore.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete Store'**
  String get confirmDeleteStore;

  /// No description provided for @deleteStoreConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete store \'{name}\'? This action cannot be undone.'**
  String deleteStoreConfirmation(String name);

  /// No description provided for @storeDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Store deleted successfully'**
  String get storeDeletedSuccessfully;

  /// No description provided for @failedToDeleteStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete store'**
  String get failedToDeleteStore;

  /// No description provided for @failedToLoadStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to load store'**
  String get failedToLoadStore;

  /// No description provided for @failedToLoadStores.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stores'**
  String get failedToLoadStores;

  /// No description provided for @searchStores.
  ///
  /// In en, this message translates to:
  /// **'Search stores...'**
  String get searchStores;

  /// No description provided for @manageStoresDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and manage your store locations'**
  String get manageStoresDescription;

  /// No description provided for @noStoresFound.
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get noStoresFound;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @updateStore.
  ///
  /// In en, this message translates to:
  /// **'Update Store'**
  String get updateStore;

  /// No description provided for @storeCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Store created successfully'**
  String get storeCreatedSuccessfully;

  /// No description provided for @storeUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Store updated successfully'**
  String get storeUpdatedSuccessfully;

  /// No description provided for @failedToCreateStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to create store'**
  String get failedToCreateStore;

  /// No description provided for @failedToUpdateStore.
  ///
  /// In en, this message translates to:
  /// **'Failed to update store'**
  String get failedToUpdateStore;

  /// No description provided for @operatingHours.
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get operatingHours;

  /// No description provided for @selectOpenTime.
  ///
  /// In en, this message translates to:
  /// **'Select Opening Time'**
  String get selectOpenTime;

  /// No description provided for @selectCloseTime.
  ///
  /// In en, this message translates to:
  /// **'Select Closing Time'**
  String get selectCloseTime;

  /// No description provided for @enterStoreName.
  ///
  /// In en, this message translates to:
  /// **'Enter store name'**
  String get enterStoreName;

  /// No description provided for @enterStoreType.
  ///
  /// In en, this message translates to:
  /// **'Enter store type'**
  String get enterStoreType;

  /// No description provided for @enterTimezone.
  ///
  /// In en, this message translates to:
  /// **'Enter timezone'**
  String get enterTimezone;

  /// No description provided for @enterAddressLine1.
  ///
  /// In en, this message translates to:
  /// **'Enter address line 1'**
  String get enterAddressLine1;

  /// No description provided for @enterAddressLine2.
  ///
  /// In en, this message translates to:
  /// **'Enter address line 2 (optional)'**
  String get enterAddressLine2;

  /// No description provided for @enterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get enterCity;

  /// No description provided for @enterProvince.
  ///
  /// In en, this message translates to:
  /// **'Enter province'**
  String get enterProvince;

  /// No description provided for @enterPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter postal code'**
  String get enterPostalCode;

  /// No description provided for @enterCountry.
  ///
  /// In en, this message translates to:
  /// **'Enter country'**
  String get enterCountry;

  /// No description provided for @enterMapLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter map location (optional)'**
  String get enterMapLocation;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email (optional)'**
  String get enterEmail;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @businessOverview.
  ///
  /// In en, this message translates to:
  /// **'Business Overview'**
  String get businessOverview;

  /// No description provided for @selectStoreToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Select store to view details ({count} total)'**
  String selectStoreToViewDetails(Object count);

  /// No description provided for @totalStores.
  ///
  /// In en, this message translates to:
  /// **'Total Stores'**
  String get totalStores;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @activeProducts.
  ///
  /// In en, this message translates to:
  /// **'Active Products'**
  String get activeProducts;

  /// No description provided for @totalStaff.
  ///
  /// In en, this message translates to:
  /// **'Total Staff'**
  String get totalStaff;

  /// No description provided for @businessAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Business analytics'**
  String get businessAnalytics;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @manageStores.
  ///
  /// In en, this message translates to:
  /// **'Manage Stores'**
  String get manageStores;

  /// No description provided for @addEditStores.
  ///
  /// In en, this message translates to:
  /// **'Add & edit stores'**
  String get addEditStores;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @businessReports.
  ///
  /// In en, this message translates to:
  /// **'Business reports'**
  String get businessReports;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @configureSystem.
  ///
  /// In en, this message translates to:
  /// **'Configure system'**
  String get configureSystem;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

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

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Category name must be at least 2 characters'**
  String get categoryNameMinLength;

  /// No description provided for @categoryNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Category name must be less than 100 characters'**
  String get categoryNameMaxLength;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get categoryDescription;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @categoryDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category description'**
  String get categoryDescriptionHint;

  /// No description provided for @descriptionMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be less than 500 characters'**
  String get descriptionMaxLength;

  /// No description provided for @createCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Category'**
  String get createCategoryTitle;

  /// No description provided for @createCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a new product category to organize your inventory'**
  String get createCategoryDescription;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategoryTitle;

  /// No description provided for @editCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Update category details and organization'**
  String get editCategoryDescription;

  /// No description provided for @categoryCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreatedSuccessfully;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @pleaseSelectStore.
  ///
  /// In en, this message translates to:
  /// **'Please select a store'**
  String get pleaseSelectStore;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get categoryNameHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @updateCategory.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get updateCategory;

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

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app interface'**
  String get selectLanguageSubtitle;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChangedTo;

  /// No description provided for @switchedTo.
  ///
  /// In en, this message translates to:
  /// **'Switched to'**
  String get switchedTo;

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

  /// No description provided for @storeOverview.
  ///
  /// In en, this message translates to:
  /// **'Store Overview'**
  String get storeOverview;

  /// No description provided for @switchStore.
  ///
  /// In en, this message translates to:
  /// **'Switch Store'**
  String get switchStore;

  /// No description provided for @storeMetrics.
  ///
  /// In en, this message translates to:
  /// **'Store Metrics'**
  String get storeMetrics;

  /// No description provided for @currentlyViewing.
  ///
  /// In en, this message translates to:
  /// **'Currently Viewing'**
  String get currentlyViewing;

  /// No description provided for @createNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Create new product'**
  String get createNewProduct;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// No description provided for @createNewEmployee.
  ///
  /// In en, this message translates to:
  /// **'Create new employee'**
  String get createNewEmployee;

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

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productManagement;

  /// No description provided for @transactionManagement.
  ///
  /// In en, this message translates to:
  /// **'Transaction Management'**
  String get transactionManagement;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @productSearch.
  ///
  /// In en, this message translates to:
  /// **'Product Search'**
  String get productSearch;

  /// No description provided for @checks.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get checks;

  /// No description provided for @saleTransactions.
  ///
  /// In en, this message translates to:
  /// **'Sale Transactions'**
  String get saleTransactions;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get capturePhoto;

  /// No description provided for @photoCapture.
  ///
  /// In en, this message translates to:
  /// **'Photo Capture'**
  String get photoCapture;

  /// No description provided for @photoPreview.
  ///
  /// In en, this message translates to:
  /// **'Photo Preview'**
  String get photoPreview;

  /// No description provided for @photoViewer.
  ///
  /// In en, this message translates to:
  /// **'Photo Viewer'**
  String get photoViewer;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get usePhoto;

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully'**
  String get photoCaptured;

  /// No description provided for @cameraInitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize camera'**
  String get cameraInitializationFailed;

  /// No description provided for @photoCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo'**
  String get photoCaptureFailed;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @storageInfo.
  ///
  /// In en, this message translates to:
  /// **'Storage Info'**
  String get storageInfo;

  /// No description provided for @totalSize.
  ///
  /// In en, this message translates to:
  /// **'Total Size'**
  String get totalSize;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'Photo Count'**
  String get photoCount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @imageInfo.
  ///
  /// In en, this message translates to:
  /// **'Image Info'**
  String get imageInfo;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @dateModified.
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get dateModified;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @deletePhotoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get deletePhotoConfirmation;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @common_button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_button_cancel;

  /// No description provided for @common_button_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_button_delete;

  /// No description provided for @common_button_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get common_button_settings;

  /// No description provided for @bluetooth_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Printer Setup'**
  String get bluetooth_setup_title;

  /// No description provided for @bluetooth_setup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to your thermal printer'**
  String get bluetooth_setup_subtitle;

  /// No description provided for @bluetooth_setup_instructions.
  ///
  /// In en, this message translates to:
  /// **'Make sure your printer is turned on and in pairing mode'**
  String get bluetooth_setup_instructions;

  /// No description provided for @bluetooth_paired_tab.
  ///
  /// In en, this message translates to:
  /// **'Paired ({count})'**
  String bluetooth_paired_tab(int count);

  /// No description provided for @bluetooth_available_tab.
  ///
  /// In en, this message translates to:
  /// **'Available ({count})'**
  String bluetooth_available_tab(int count);

  /// No description provided for @bluetooth_scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get bluetooth_scanning;

  /// No description provided for @bluetooth_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get bluetooth_refresh;

  /// No description provided for @bluetooth_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get bluetooth_connecting;

  /// No description provided for @bluetooth_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get bluetooth_connect;

  /// No description provided for @bluetooth_no_devices_found.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get bluetooth_no_devices_found;

  /// No description provided for @bluetooth_no_paired_devices.
  ///
  /// In en, this message translates to:
  /// **'No paired devices'**
  String get bluetooth_no_paired_devices;

  /// No description provided for @bluetooth_make_printer_discoverable.
  ///
  /// In en, this message translates to:
  /// **'Make sure your printer is discoverable and try scanning again'**
  String get bluetooth_make_printer_discoverable;

  /// No description provided for @bluetooth_pair_printer_first.
  ///
  /// In en, this message translates to:
  /// **'Please pair your thermal printer in Bluetooth settings first'**
  String get bluetooth_pair_printer_first;

  /// No description provided for @bluetooth_scan_again.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get bluetooth_scan_again;

  /// No description provided for @bluetooth_enter_mac_address.
  ///
  /// In en, this message translates to:
  /// **'Enter MAC Address'**
  String get bluetooth_enter_mac_address;

  /// No description provided for @bluetooth_manual_connection.
  ///
  /// In en, this message translates to:
  /// **'Manual Connection'**
  String get bluetooth_manual_connection;

  /// No description provided for @bluetooth_enter_mac_manually.
  ///
  /// In en, this message translates to:
  /// **'Enter printer MAC address manually'**
  String get bluetooth_enter_mac_manually;

  /// No description provided for @bluetooth_mac_address_help.
  ///
  /// In en, this message translates to:
  /// **'MAC address format: 00:11:22:33:44:55'**
  String get bluetooth_mac_address_help;

  /// No description provided for @bluetooth_printer_name_optional.
  ///
  /// In en, this message translates to:
  /// **'Printer Name (Optional)'**
  String get bluetooth_printer_name_optional;

  /// No description provided for @bluetooth_printer_name_hint.
  ///
  /// In en, this message translates to:
  /// **'My Thermal Printer'**
  String get bluetooth_printer_name_hint;

  /// No description provided for @bluetooth_mac_address_required.
  ///
  /// In en, this message translates to:
  /// **'MAC Address *'**
  String get bluetooth_mac_address_required;

  /// No description provided for @bluetooth_mac_format.
  ///
  /// In en, this message translates to:
  /// **'Format: 00:11:22:33:44:55'**
  String get bluetooth_mac_format;

  /// No description provided for @bluetooth_invalid_mac_address.
  ///
  /// In en, this message translates to:
  /// **'Invalid MAC address format'**
  String get bluetooth_invalid_mac_address;

  /// No description provided for @bluetooth_manual_printer_default_name.
  ///
  /// In en, this message translates to:
  /// **'Manual Printer'**
  String get bluetooth_manual_printer_default_name;

  /// No description provided for @bluetooth_manual_connection_help.
  ///
  /// In en, this message translates to:
  /// **'If your printer doesn\'t appear in the list, you can connect manually using its MAC address'**
  String get bluetooth_manual_connection_help;

  /// No description provided for @bluetooth_unknown_device.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get bluetooth_unknown_device;

  /// No description provided for @bluetooth_tap_to_connect.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get bluetooth_tap_to_connect;

  /// No description provided for @bluetooth_error_title.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get bluetooth_error_title;

  /// No description provided for @bluetooth_test_print_success.
  ///
  /// In en, this message translates to:
  /// **'Test page printed successfully!'**
  String get bluetooth_test_print_success;

  /// No description provided for @bluetooth_test_print_failed.
  ///
  /// In en, this message translates to:
  /// **'Test print failed: {error}'**
  String bluetooth_test_print_failed(String error);

  /// No description provided for @barcode_quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Number of Copies'**
  String get barcode_quantity_label;

  /// No description provided for @barcode_quantity_instructions.
  ///
  /// In en, this message translates to:
  /// **'Select how many copies you want to print'**
  String get barcode_quantity_instructions;

  /// No description provided for @barcode_quantity_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get barcode_quantity_invalid_number;

  /// No description provided for @barcode_quantity_minimum_error.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity is 1'**
  String get barcode_quantity_minimum_error;

  /// No description provided for @barcode_quantity_maximum_error.
  ///
  /// In en, this message translates to:
  /// **'Maximum quantity is {max}'**
  String barcode_quantity_maximum_error(int max);

  /// No description provided for @barcode_quantity_range.
  ///
  /// In en, this message translates to:
  /// **'Range: {min} - {max}'**
  String barcode_quantity_range(int min, int max);

  /// No description provided for @barcode_quantity_minimum_info.
  ///
  /// In en, this message translates to:
  /// **'Minimum: 1 (no maximum limit)'**
  String get barcode_quantity_minimum_info;

  /// No description provided for @barcode_quantity_print_button.
  ///
  /// In en, this message translates to:
  /// **'Print {count}'**
  String barcode_quantity_print_button(int count);

  /// No description provided for @logo_management_title.
  ///
  /// In en, this message translates to:
  /// **'Receipt Logo'**
  String get logo_management_title;

  /// No description provided for @logo_management_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a logo to appear on receipts'**
  String get logo_management_subtitle;

  /// No description provided for @logo_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Logo'**
  String get logo_delete_title;

  /// No description provided for @logo_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the current logo?'**
  String get logo_delete_message;

  /// No description provided for @logo_replace_button.
  ///
  /// In en, this message translates to:
  /// **'Replace Logo'**
  String get logo_replace_button;

  /// No description provided for @logo_upload_button.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get logo_upload_button;

  /// No description provided for @logo_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No Logo Uploaded'**
  String get logo_empty_title;

  /// No description provided for @logo_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a logo to display on your receipts and payment notes'**
  String get logo_empty_subtitle;

  /// No description provided for @logo_dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get logo_dimensions;

  /// No description provided for @logo_file_size.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get logo_file_size;

  /// No description provided for @logo_preview_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logo preview'**
  String get logo_preview_error;

  /// No description provided for @logo_select_image_source.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get logo_select_image_source;

  /// No description provided for @logo_select_image_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose where to get your logo image from'**
  String get logo_select_image_subtitle;

  /// No description provided for @logo_camera_option.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get logo_camera_option;

  /// No description provided for @logo_camera_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use camera to capture logo'**
  String get logo_camera_subtitle;

  /// No description provided for @logo_gallery_option.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get logo_gallery_option;

  /// No description provided for @logo_gallery_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select existing image from gallery'**
  String get logo_gallery_subtitle;

  /// No description provided for @logo_camera_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get logo_camera_permission_title;

  /// No description provided for @logo_camera_permission_message.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to take photos. Please grant permission in settings.'**
  String get logo_camera_permission_message;

  /// No description provided for @logo_gallery_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Gallery Permission Required'**
  String get logo_gallery_permission_title;

  /// No description provided for @logo_gallery_permission_message.
  ///
  /// In en, this message translates to:
  /// **'Gallery access is needed to select photos. Please grant permission in settings.'**
  String get logo_gallery_permission_message;

  /// No description provided for @barcode_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Barcode Preview'**
  String get barcode_preview_title;

  /// No description provided for @barcode_preview_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview how your barcode labels will look'**
  String get barcode_preview_subtitle;

  /// No description provided for @receipt_preview_title.
  ///
  /// In en, this message translates to:
  /// **'Receipt Preview'**
  String get receipt_preview_title;

  /// No description provided for @receipt_preview_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview how your receipts will look'**
  String get receipt_preview_subtitle;

  /// No description provided for @preview_barcode.
  ///
  /// In en, this message translates to:
  /// **'Preview Barcode'**
  String get preview_barcode;

  /// No description provided for @preview_receipt.
  ///
  /// In en, this message translates to:
  /// **'Preview Receipt'**
  String get preview_receipt;

  /// No description provided for @logo_preview_section.
  ///
  /// In en, this message translates to:
  /// **'Print Preview'**
  String get logo_preview_section;

  /// No description provided for @logo_upload_error_no_image.
  ///
  /// In en, this message translates to:
  /// **'No image selected. Please try again or check permissions.'**
  String get logo_upload_error_no_image;

  /// No description provided for @logo_upload_error_validation.
  ///
  /// In en, this message translates to:
  /// **'Invalid image. Please select a valid image file (minimum 50x50 pixels, maximum 2MB).'**
  String get logo_upload_error_validation;

  /// No description provided for @logo_upload_error_save.
  ///
  /// In en, this message translates to:
  /// **'Failed to save logo. Please check storage permissions and try again.'**
  String get logo_upload_error_save;

  /// No description provided for @logo_upload_success.
  ///
  /// In en, this message translates to:
  /// **'Logo uploaded successfully!'**
  String get logo_upload_success;

  /// No description provided for @camera_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos'**
  String get camera_permission_required;

  /// No description provided for @gallery_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Gallery permission is required to select photos'**
  String get gallery_permission_required;

  /// No description provided for @users_title_list.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users_title_list;

  /// No description provided for @users_button_create.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get users_button_create;

  /// No description provided for @users_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search users by name or username...'**
  String get users_search_hint;

  /// No description provided for @users_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No Users Found'**
  String get users_empty_title;

  /// No description provided for @users_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first user to get started'**
  String get users_empty_subtitle;

  /// No description provided for @users_role_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get users_role_owner;

  /// No description provided for @users_role_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get users_role_admin;

  /// No description provided for @users_role_staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get users_role_staff;

  /// No description provided for @users_role_cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get users_role_cashier;

  /// No description provided for @users_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get users_status_active;

  /// No description provided for @users_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get users_status_inactive;

  /// No description provided for @users_status_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get users_status_deleted;

  /// No description provided for @users_created_at.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String users_created_at(String date);

  /// No description provided for @users_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter Users'**
  String get users_filter_title;

  /// No description provided for @users_filter_role.
  ///
  /// In en, this message translates to:
  /// **'Filter by Role'**
  String get users_filter_role;

  /// No description provided for @users_filter_status.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get users_filter_status;

  /// No description provided for @users_filter_all_roles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get users_filter_all_roles;

  /// No description provided for @users_filter_all_statuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get users_filter_all_statuses;

  /// No description provided for @users_filter_active_only.
  ///
  /// In en, this message translates to:
  /// **'Active Only'**
  String get users_filter_active_only;

  /// No description provided for @users_filter_inactive_only.
  ///
  /// In en, this message translates to:
  /// **'Inactive Only'**
  String get users_filter_inactive_only;

  /// No description provided for @users_detail_title.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get users_detail_title;

  /// No description provided for @users_form_title_create.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get users_form_title_create;

  /// No description provided for @users_form_title_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get users_form_title_edit;

  /// No description provided for @users_form_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get users_form_name;

  /// No description provided for @users_form_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get users_form_username;

  /// No description provided for @users_form_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get users_form_password;

  /// No description provided for @users_form_role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get users_form_role;

  /// No description provided for @users_form_store.
  ///
  /// In en, this message translates to:
  /// **'Store Assignment'**
  String get users_form_store;

  /// No description provided for @users_form_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get users_form_status;

  /// No description provided for @users_form_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get users_form_name_hint;

  /// No description provided for @users_form_username_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get users_form_username_hint;

  /// No description provided for @users_form_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get users_form_password_hint;

  /// No description provided for @users_form_select_role.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get users_form_select_role;

  /// No description provided for @users_form_select_store.
  ///
  /// In en, this message translates to:
  /// **'Select store (optional)'**
  String get users_form_select_store;

  /// No description provided for @users_validation_name_required.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get users_validation_name_required;

  /// No description provided for @users_validation_username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get users_validation_username_required;

  /// No description provided for @users_validation_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get users_validation_password_required;

  /// No description provided for @users_validation_role_required.
  ///
  /// In en, this message translates to:
  /// **'Role is required'**
  String get users_validation_role_required;

  /// No description provided for @users_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'User created successfully'**
  String get users_created_successfully;

  /// No description provided for @users_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get users_updated_successfully;

  /// No description provided for @users_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get users_deleted_successfully;

  /// No description provided for @users_failed_to_create.
  ///
  /// In en, this message translates to:
  /// **'Failed to create user'**
  String get users_failed_to_create;

  /// No description provided for @users_failed_to_update.
  ///
  /// In en, this message translates to:
  /// **'Failed to update user'**
  String get users_failed_to_update;

  /// No description provided for @users_failed_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get users_failed_to_delete;

  /// No description provided for @users_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user'**
  String get users_failed_to_load;

  /// No description provided for @users_failed_to_load_list.
  ///
  /// In en, this message translates to:
  /// **'Failed to load users'**
  String get users_failed_to_load_list;

  /// No description provided for @users_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get users_delete_confirm_title;

  /// No description provided for @users_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete user \'{name}\'? This action cannot be undone.'**
  String users_delete_confirm_message(String name);

  /// No description provided for @common_button_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get common_button_filter;

  /// No description provided for @common_button_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get common_button_clear_filters;

  /// No description provided for @common_button_apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get common_button_apply_filters;

  /// No description provided for @products_action_printBarcode.
  ///
  /// In en, this message translates to:
  /// **'Print Barcode'**
  String get products_action_printBarcode;

  /// No description provided for @products_action_deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get products_action_deleteProduct;

  /// No description provided for @products_message_barcodePrintedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Barcode printed successfully!'**
  String get products_message_barcodePrintedSuccess;

  /// No description provided for @products_message_barcodesPrintedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} barcodes printed successfully!'**
  String products_message_barcodesPrintedSuccess(String count);

  /// No description provided for @products_error_printBarcodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to print barcode: {error}'**
  String products_error_printBarcodeFailed(String error);

  /// No description provided for @products_message_deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String products_message_deleteConfirmation(String name);

  /// No description provided for @products_message_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Product \"{name}\" deleted successfully'**
  String products_message_deleteSuccess(String name);

  /// No description provided for @products_error_deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product: {error}'**
  String products_error_deleteFailed(String error);

  /// No description provided for @products_error_onlyOwnersCanDelete.
  ///
  /// In en, this message translates to:
  /// **'Only owners can delete products'**
  String get products_error_onlyOwnersCanDelete;

  /// No description provided for @products_title_deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get products_title_deleteProduct;

  /// No description provided for @products_title_details.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get products_title_details;

  /// No description provided for @products_error_loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Product'**
  String get products_error_loadFailed;

  /// No description provided for @products_error_notFound.
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get products_error_notFound;

  /// No description provided for @products_error_notFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'The product you\'re looking for doesn\'t exist or has been removed.'**
  String get products_error_notFoundDescription;

  /// No description provided for @products_section_pricingInventory.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Inventory'**
  String get products_section_pricingInventory;

  /// No description provided for @products_section_pricingInventoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Product pricing and stock information'**
  String get products_section_pricingInventoryDescription;

  /// No description provided for @products_section_locationCategory.
  ///
  /// In en, this message translates to:
  /// **'Location & Category'**
  String get products_section_locationCategory;

  /// No description provided for @products_section_locationCategoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Store location and product categorization'**
  String get products_section_locationCategoryDescription;

  /// No description provided for @products_section_additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get products_section_additionalInfo;

  /// No description provided for @products_section_additionalInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'System information and timestamps'**
  String get products_section_additionalInfoDescription;

  /// No description provided for @products_label_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get products_label_name;

  /// No description provided for @products_label_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get products_label_sku;

  /// No description provided for @products_label_barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get products_label_barcode;

  /// No description provided for @products_label_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get products_label_price;

  /// No description provided for @products_label_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get products_label_quantity;

  /// No description provided for @products_label_purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get products_label_purchasePrice;

  /// No description provided for @products_label_salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale Price'**
  String get products_label_salePrice;

  /// No description provided for @products_label_currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get products_label_currentStock;

  /// No description provided for @products_label_units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get products_label_units;

  /// No description provided for @products_label_imei.
  ///
  /// In en, this message translates to:
  /// **'IMEI'**
  String get products_label_imei;

  /// No description provided for @products_status_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get products_status_outOfStock;

  /// No description provided for @products_status_lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get products_status_lowStock;

  /// No description provided for @products_status_inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get products_status_inStock;

  /// No description provided for @transactions_action_printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get transactions_action_printReceipt;

  /// No description provided for @transactions_action_markFinished.
  ///
  /// In en, this message translates to:
  /// **'Mark as Finished'**
  String get transactions_action_markFinished;

  /// No description provided for @transactions_label_transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactions_label_transactionId;

  /// No description provided for @transactions_message_receiptPrintedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt printed successfully!'**
  String get transactions_message_receiptPrintedSuccess;

  /// No description provided for @transactions_message_receiptsPrintedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} receipts printed successfully'**
  String transactions_message_receiptsPrintedSuccess(String count);

  /// No description provided for @transactions_error_printReceiptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to print receipt: {error}'**
  String transactions_error_printReceiptFailed(String error);

  /// No description provided for @transactions_message_markedFinished.
  ///
  /// In en, this message translates to:
  /// **'Transaction marked as finished'**
  String get transactions_message_markedFinished;

  /// No description provided for @transactions_error_markFinishedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark transaction as finished: {error}'**
  String transactions_error_markFinishedFailed(String error);

  /// No description provided for @transactions_title_detail.
  ///
  /// In en, this message translates to:
  /// **'Transaction Detail'**
  String get transactions_title_detail;

  /// No description provided for @transactions_title_details.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactions_title_details;

  /// No description provided for @transactions_label_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get transactions_label_id;

  /// No description provided for @transactions_label_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactions_label_type;

  /// No description provided for @transactions_label_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactions_label_amount;

  /// No description provided for @transactions_label_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get transactions_label_items;

  /// No description provided for @transactions_label_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transactions_label_status;

  /// No description provided for @transactions_label_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactions_label_date;

  /// No description provided for @stores_title_details.
  ///
  /// In en, this message translates to:
  /// **'Store Details'**
  String get stores_title_details;

  /// No description provided for @stores_action_deleteStore.
  ///
  /// In en, this message translates to:
  /// **'Delete Store'**
  String get stores_action_deleteStore;

  /// No description provided for @stores_label_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get stores_label_name;

  /// No description provided for @stores_label_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get stores_label_type;

  /// No description provided for @stores_label_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get stores_label_status;

  /// No description provided for @stores_label_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get stores_label_address;

  /// No description provided for @stores_label_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get stores_label_phone;

  /// No description provided for @stores_label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get stores_label_email;

  /// No description provided for @common_error_permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission required: {error}'**
  String common_error_permissionRequired(String error);

  /// No description provided for @common_action_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get common_action_settings;

  /// No description provided for @common_action_setupPrinter.
  ///
  /// In en, this message translates to:
  /// **'Setup Printer'**
  String get common_action_setupPrinter;

  /// No description provided for @common_action_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_action_retry;

  /// No description provided for @common_action_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_action_cancel;

  /// No description provided for @common_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_action_delete;

  /// No description provided for @common_action_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_action_close;

  /// No description provided for @common_action_setup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get common_action_setup;

  /// No description provided for @common_message_testPagePrintedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Test page printed successfully!'**
  String get common_message_testPagePrintedSuccess;

  /// No description provided for @common_error_testPrintFailed.
  ///
  /// In en, this message translates to:
  /// **'Test print failed: {error}'**
  String common_error_testPrintFailed(String error);

  /// No description provided for @common_title_printerManagement.
  ///
  /// In en, this message translates to:
  /// **'Printer Management'**
  String get common_title_printerManagement;

  /// No description provided for @common_label_printerStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String common_label_printerStatus(String status);

  /// No description provided for @common_status_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get common_status_connected;

  /// No description provided for @common_status_disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get common_status_disconnected;

  /// No description provided for @common_label_availableActions.
  ///
  /// In en, this message translates to:
  /// **'Available Actions:'**
  String get common_label_availableActions;

  /// No description provided for @common_action_connectToPrinter.
  ///
  /// In en, this message translates to:
  /// **'Connect to Printer'**
  String get common_action_connectToPrinter;

  /// No description provided for @common_action_printTestPage.
  ///
  /// In en, this message translates to:
  /// **'Print Test Page'**
  String get common_action_printTestPage;

  /// No description provided for @common_action_disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get common_action_disconnect;

  /// No description provided for @common_message_printerDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Printer disconnected'**
  String get common_message_printerDisconnected;

  /// No description provided for @common_error_printerAccessFailed.
  ///
  /// In en, this message translates to:
  /// **'Error accessing printer: {error}'**
  String common_error_printerAccessFailed(String error);

  /// No description provided for @common_message_copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Information copied to clipboard'**
  String get common_message_copiedToClipboard;

  /// No description provided for @common_label_notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get common_label_notSet;

  /// No description provided for @common_label_store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get common_label_store;

  /// No description provided for @common_label_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get common_label_category;

  /// No description provided for @common_status_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_status_loading;

  /// No description provided for @common_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get common_status_active;

  /// No description provided for @common_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get common_status_inactive;

  /// No description provided for @common_label_created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get common_label_created;

  /// No description provided for @common_label_lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get common_label_lastUpdated;

  /// No description provided for @common_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get common_status_completed;

  /// No description provided for @common_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get common_status_pending;

  /// No description provided for @common_error_printerNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Printer not connected. Setting up printer...'**
  String get common_error_printerNotConnected;
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
      'that was used.');
}
