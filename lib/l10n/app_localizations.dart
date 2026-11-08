import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
    Locale('es'),
    Locale('es', '419'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Muyu'**
  String get appName;

  /// No description provided for @splashLogo.
  ///
  /// In en, this message translates to:
  /// **'MUYU'**
  String get splashLogo;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Connecting the countryside'**
  String get splashTagline;

  /// No description provided for @languageCode.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageCode;

  /// No description provided for @languageToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Change language to Spanish'**
  String get languageToggleLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginHero.
  ///
  /// In en, this message translates to:
  /// **'Muyu character with a credential'**
  String get loginHero;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegister;

  /// No description provided for @loginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginInvalid;

  /// No description provided for @loginNetworkError.
  ///
  /// In en, this message translates to:
  /// **'We could not reach Muyu. Check your connection and try again.'**
  String get loginNetworkError;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get loginLoading;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerName;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registerPhone;

  /// No description provided for @registerBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get registerBirthdate;

  /// No description provided for @registerBirthdateHint.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get registerBirthdateHint;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Do you have an account?'**
  String get registerHaveAccount;

  /// No description provided for @registerAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the terms and conditions'**
  String get registerAcceptTerms;

  /// No description provided for @registerNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid name using 2 to 60 letters.'**
  String get registerNameInvalid;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get registerEmailInvalid;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get registerPhoneInvalid;

  /// No description provided for @registerBirthdateRequired.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth.'**
  String get registerBirthdateRequired;

  /// No description provided for @registerBirthdateInvalid.
  ///
  /// In en, this message translates to:
  /// **'You must be between 18 and 90 years old.'**
  String get registerBirthdateInvalid;

  /// No description provided for @registerPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Password must contain 8+ characters, uppercase, lowercase, a number, and a special character.'**
  String get registerPasswordInvalid;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerPasswordMismatch;

  /// No description provided for @registerTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms and conditions to continue.'**
  String get registerTermsRequired;

  /// No description provided for @registerRuleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerRuleLength;

  /// No description provided for @registerRuleUppercase.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get registerRuleUppercase;

  /// No description provided for @registerRuleLowercase.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get registerRuleLowercase;

  /// No description provided for @registerRuleNumber.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get registerRuleNumber;

  /// No description provided for @registerRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'One special character, such as * ! @ #'**
  String get registerRuleSpecial;

  /// No description provided for @registerRuleNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'No spaces'**
  String get registerRuleNoSpaces;

  /// No description provided for @registerRuleMet.
  ///
  /// In en, this message translates to:
  /// **'Met'**
  String get registerRuleMet;

  /// No description provided for @registerRuleMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get registerRuleMissing;

  /// No description provided for @registerError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the account'**
  String get registerError;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created. Log in to continue.'**
  String get registerSuccess;

  /// No description provided for @roleQuestion.
  ///
  /// In en, this message translates to:
  /// **'How will you use MUYU?'**
  String get roleQuestion;

  /// No description provided for @roleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your role to personalize your experience.'**
  String get roleSubtitle;

  /// No description provided for @roleFarmerTitle.
  ///
  /// In en, this message translates to:
  /// **'I am a farmer'**
  String get roleFarmerTitle;

  /// No description provided for @roleFarmerBody.
  ///
  /// In en, this message translates to:
  /// **'List your plots, log cultivation milestones, and receive secure payments'**
  String get roleFarmerBody;

  /// No description provided for @roleFarmerImage.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get roleFarmerImage;

  /// No description provided for @roleMerchantTitle.
  ///
  /// In en, this message translates to:
  /// **'I am a merchant'**
  String get roleMerchantTitle;

  /// No description provided for @roleMerchantBody.
  ///
  /// In en, this message translates to:
  /// **'Explore the catalog of plots, finance harvests, and approve milestones securely'**
  String get roleMerchantBody;

  /// No description provided for @roleMerchantImage.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get roleMerchantImage;

  /// No description provided for @roleNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get roleNext;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @farmerHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'My plots'**
  String get farmerHomeTitle;

  /// No description provided for @farmerHomeEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not published any plots yet.'**
  String get farmerHomeEmpty;

  /// No description provided for @merchantHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Plot catalog'**
  String get merchantHomeTitle;

  /// No description provided for @merchantHomeEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no plots to finance yet.'**
  String get merchantHomeEmpty;

  /// No description provided for @homeChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get homeChangeRole;

  /// No description provided for @homeLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get homeLogout;

  /// No description provided for @homeMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get homeMoreOptions;

  /// No description provided for @navCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// No description provided for @navMyPlots.
  ///
  /// In en, this message translates to:
  /// **'My plots'**
  String get navMyPlots;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get navPayment;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @merchantTabSoon.
  ///
  /// In en, this message translates to:
  /// **'This section is coming next.'**
  String get merchantTabSoon;

  /// No description provided for @merchantWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get merchantWelcome;

  /// No description provided for @merchantCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Distribuidora La Cosecha'**
  String get merchantCompanyName;

  /// No description provided for @merchantSearch.
  ///
  /// In en, this message translates to:
  /// **'Search plots or GPS…'**
  String get merchantSearch;

  /// No description provided for @merchantSearchIcon.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get merchantSearchIcon;

  /// No description provided for @merchantFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get merchantFilterAll;

  /// No description provided for @merchantFilterNear.
  ///
  /// In en, this message translates to:
  /// **'Near me'**
  String get merchantFilterNear;

  /// No description provided for @merchantFilterRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get merchantFilterRecommended;

  /// No description provided for @merchantVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified farmer'**
  String get merchantVerified;

  /// No description provided for @merchantMilestones.
  ///
  /// In en, this message translates to:
  /// **'94% of milestones approved'**
  String get merchantMilestones;

  /// No description provided for @merchantNoPlots.
  ///
  /// In en, this message translates to:
  /// **'No plots available yet'**
  String get merchantNoPlots;

  /// No description provided for @farmerCountryPeru.
  ///
  /// In en, this message translates to:
  /// **'PERU'**
  String get farmerCountryPeru;

  /// No description provided for @farmerFlagPeru.
  ///
  /// In en, this message translates to:
  /// **'Peru flag'**
  String get farmerFlagPeru;

  /// No description provided for @roleMerchantShort.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get roleMerchantShort;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileVerified;

  /// No description provided for @profileContactDetails.
  ///
  /// In en, this message translates to:
  /// **'CONTACT DETAILS'**
  String get profileContactDetails;

  /// No description provided for @profileEditContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get profileEditContact;

  /// No description provided for @profileSaveContact.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveContact;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileCompanyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get profileCompanyNameLabel;

  /// No description provided for @profileActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivityLabel;

  /// No description provided for @profileRucLabel.
  ///
  /// In en, this message translates to:
  /// **'RUC'**
  String get profileRucLabel;

  /// No description provided for @profileLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileLocationLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileNotificationPrefs.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATION PREFERENCES'**
  String get profileNotificationPrefs;

  /// No description provided for @profileWeatherAlertsQuestion.
  ///
  /// In en, this message translates to:
  /// **'How should we send you weather alerts?'**
  String get profileWeatherAlertsQuestion;

  /// No description provided for @profileChannelCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get profileChannelCall;

  /// No description provided for @profileChannelPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get profileChannelPush;

  /// No description provided for @profileChannelWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get profileChannelWhatsapp;

  /// No description provided for @profilePayment.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT'**
  String get profilePayment;

  /// No description provided for @profileSavedMethods.
  ///
  /// In en, this message translates to:
  /// **'Saved payment methods'**
  String get profileSavedMethods;

  /// No description provided for @profileVisaBcp.
  ///
  /// In en, this message translates to:
  /// **'Visa ending in 4821 · BCP transfer'**
  String get profileVisaBcp;

  /// No description provided for @profileSecurityHelp.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & HELP'**
  String get profileSecurityHelp;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get profileLegal;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacy;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogout;

  /// No description provided for @profileWholesale.
  ///
  /// In en, this message translates to:
  /// **'Wholesale distributor'**
  String get profileWholesale;

  /// No description provided for @profileCompanyLegalName.
  ///
  /// In en, this message translates to:
  /// **'Distribuidora La Cosecha SAC'**
  String get profileCompanyLegalName;

  /// No description provided for @profileMerchantPlace.
  ///
  /// In en, this message translates to:
  /// **'Lima'**
  String get profileMerchantPlace;

  /// No description provided for @profileCompanyLocationEmail.
  ///
  /// In en, this message translates to:
  /// **'Lima · contacto@lacosecha.pe'**
  String get profileCompanyLocationEmail;

  /// No description provided for @profileNewPlotAlerts.
  ///
  /// In en, this message translates to:
  /// **'New plot alerts'**
  String get profileNewPlotAlerts;

  /// No description provided for @profileNewPlotAlertsBody.
  ///
  /// In en, this message translates to:
  /// **'Potatoes · Cusco · from 5,000 kg'**
  String get profileNewPlotAlertsBody;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section is coming next.'**
  String get profileComingSoon;

  /// No description provided for @paymentNoCard.
  ///
  /// In en, this message translates to:
  /// **'No card registered'**
  String get paymentNoCard;

  /// No description provided for @profileRegisterCard.
  ///
  /// In en, this message translates to:
  /// **'Register card'**
  String get profileRegisterCard;

  /// No description provided for @profileChangeCard.
  ///
  /// In en, this message translates to:
  /// **'Change card'**
  String get profileChangeCard;

  /// No description provided for @profileNoWallet.
  ///
  /// In en, this message translates to:
  /// **'No Yape or Plin linked'**
  String get profileNoWallet;

  /// No description provided for @profileChangeWallet.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get profileChangeWallet;

  /// No description provided for @bankAccountYape.
  ///
  /// In en, this message translates to:
  /// **'Yape'**
  String get bankAccountYape;

  /// No description provided for @bankAccountPlin.
  ///
  /// In en, this message translates to:
  /// **'Plin'**
  String get bankAccountPlin;

  /// No description provided for @bankAccountVisaLogo.
  ///
  /// In en, this message translates to:
  /// **'Visa logo'**
  String get bankAccountVisaLogo;

  /// No description provided for @addCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCardTitle;

  /// No description provided for @addCardDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get addCardDataTitle;

  /// No description provided for @addCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get addCardNumber;

  /// No description provided for @addCardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'0000  0000  0000  0000'**
  String get addCardNumberHint;

  /// No description provided for @addCardNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Visa or Mastercard number'**
  String get addCardNumberError;

  /// No description provided for @addCardHolder.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get addCardHolder;

  /// No description provided for @addCardHolderHint.
  ///
  /// In en, this message translates to:
  /// **'As shown on the card'**
  String get addCardHolderHint;

  /// No description provided for @addCardExpiration.
  ///
  /// In en, this message translates to:
  /// **'Expiration date'**
  String get addCardExpiration;

  /// No description provided for @addCardExpirationHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get addCardExpirationHint;

  /// No description provided for @addCardCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get addCardCvv;

  /// No description provided for @addCardType.
  ///
  /// In en, this message translates to:
  /// **'Card type'**
  String get addCardType;

  /// No description provided for @addCardDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get addCardDebit;

  /// No description provided for @addCardCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get addCardCredit;

  /// No description provided for @addCardPrimary.
  ///
  /// In en, this message translates to:
  /// **'Save as primary card'**
  String get addCardPrimary;

  /// No description provided for @addCardSecurity.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected and stored securely.'**
  String get addCardSecurity;

  /// No description provided for @addCardSave.
  ///
  /// In en, this message translates to:
  /// **'Save card'**
  String get addCardSave;

  /// No description provided for @addCardUnknownBrand.
  ///
  /// In en, this message translates to:
  /// **'Unrecognized card brand'**
  String get addCardUnknownBrand;

  /// No description provided for @yapeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Yape'**
  String get yapeEditTitle;

  /// No description provided for @yapeLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get yapeLinked;

  /// No description provided for @yapeNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get yapeNotLinked;

  /// No description provided for @yapeNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get yapeNoPhone;

  /// No description provided for @yapeAccountData.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get yapeAccountData;

  /// No description provided for @yapePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get yapePhoneLabel;

  /// No description provided for @yapePhoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 9-digit mobile number'**
  String get yapePhoneError;

  /// No description provided for @yapeVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify number'**
  String get yapeVerifyPhone;

  /// No description provided for @yapePhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Number verified'**
  String get yapePhoneVerified;

  /// No description provided for @yapeHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get yapeHolderLabel;

  /// No description provided for @yapeSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get yapeSaveChanges;

  /// No description provided for @yapeUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink Yape'**
  String get yapeUnlink;

  /// No description provided for @plinEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Plin'**
  String get plinEditTitle;

  /// No description provided for @plinUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink Plin'**
  String get plinUnlink;

  /// No description provided for @merchantWalletPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Muyu will charge the financing to this number. You will confirm the payment in your app.'**
  String get merchantWalletPaymentInfo;

  /// No description provided for @passwordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// No description provided for @passwordNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNewTitle;

  /// No description provided for @passwordRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested requirements'**
  String get passwordRulesTitle;

  /// No description provided for @passwordRuleLength.
  ///
  /// In en, this message translates to:
  /// **'8 or more characters'**
  String get passwordRuleLength;

  /// No description provided for @passwordRuleNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get passwordRuleNumber;

  /// No description provided for @passwordRuleUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get passwordRuleUppercase;

  /// No description provided for @passwordConfirmationHint.
  ///
  /// In en, this message translates to:
  /// **'The confirmation must match the new password exactly.'**
  String get passwordConfirmationHint;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @passwordHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Muyu character next to a password form'**
  String get passwordHeroDescription;

  /// No description provided for @passwordBackProfile.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get passwordBackProfile;

  /// No description provided for @passwordFlowCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to continue'**
  String get passwordFlowCompleteTitle;

  /// No description provided for @passwordFlowCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You completed the password flow preview. Your current password has not changed.'**
  String get passwordFlowCompleteBody;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change the password. Try again.'**
  String get passwordChangeFailed;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: October 10, 2026'**
  String get legalUpdated;

  /// No description provided for @legalUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get legalUnderstood;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlot.
  ///
  /// In en, this message translates to:
  /// **'Plot'**
  String get navPlot;

  /// No description provided for @navSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get navSync;

  /// No description provided for @roleFarmerShort.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get roleFarmerShort;

  /// No description provided for @farmerStatPlots.
  ///
  /// In en, this message translates to:
  /// **'No. of\nplots'**
  String get farmerStatPlots;

  /// No description provided for @farmerStatMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones\ncompleted'**
  String get farmerStatMilestones;

  /// No description provided for @farmerStatCrop.
  ///
  /// In en, this message translates to:
  /// **'Active\ncrop'**
  String get farmerStatCrop;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileSync.
  ///
  /// In en, this message translates to:
  /// **'SYNC'**
  String get profileSync;

  /// No description provided for @profileSyncWifi.
  ///
  /// In en, this message translates to:
  /// **'Sync evidence over Wi-Fi only'**
  String get profileSyncWifi;

  /// No description provided for @actionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// No description provided for @actionNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// No description provided for @profileBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get profileBankAccount;

  /// No description provided for @profileBankAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Set up where you receive your disbursements'**
  String get profileBankAccountBody;

  /// No description provided for @profileChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get profileChangePin;

  /// No description provided for @profileCallSupport.
  ///
  /// In en, this message translates to:
  /// **'Call technical support'**
  String get profileCallSupport;

  /// No description provided for @profileSupportPhone.
  ///
  /// In en, this message translates to:
  /// **'967990437'**
  String get profileSupportPhone;

  /// No description provided for @profileReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get profileReportIssue;

  /// No description provided for @profileRateContract.
  ///
  /// In en, this message translates to:
  /// **'Rate a completed contract'**
  String get profileRateContract;

  /// No description provided for @yapePrimary.
  ///
  /// In en, this message translates to:
  /// **'Use Yape as the default wallet'**
  String get yapePrimary;

  /// No description provided for @plinPrimary.
  ///
  /// In en, this message translates to:
  /// **'Use Plin as the default wallet'**
  String get plinPrimary;

  /// No description provided for @yapeDisbursementInfo.
  ///
  /// In en, this message translates to:
  /// **'Disbursements will be sent to the linked number.'**
  String get yapeDisbursementInfo;

  /// No description provided for @plinNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get plinNotLinked;

  /// No description provided for @bankAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get bankAccountTitle;

  /// No description provided for @bankAccountBack.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get bankAccountBack;

  /// No description provided for @bankAccountDebitLabel.
  ///
  /// In en, this message translates to:
  /// **'DEBIT'**
  String get bankAccountDebitLabel;

  /// No description provided for @bankAccountCreditLabel.
  ///
  /// In en, this message translates to:
  /// **'CREDIT'**
  String get bankAccountCreditLabel;

  /// No description provided for @bankAccountExpirationValue.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String bankAccountExpirationValue(String date);

  /// No description provided for @bankAccountCvvMasked.
  ///
  /// In en, this message translates to:
  /// **'CVV •••'**
  String get bankAccountCvvMasked;

  /// No description provided for @bankAccountBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance {amount}'**
  String bankAccountBalance(String amount);

  /// No description provided for @bankAccountAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add new card'**
  String get bankAccountAddCard;

  /// No description provided for @bankAccountReplaceCard.
  ///
  /// In en, this message translates to:
  /// **'Replace card'**
  String get bankAccountReplaceCard;

  /// No description provided for @bankAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get bankAccountDetails;

  /// No description provided for @bankAccountDigitalWallets.
  ///
  /// In en, this message translates to:
  /// **'Digital wallets'**
  String get bankAccountDigitalWallets;

  /// No description provided for @bankAccountNoCardTitle.
  ///
  /// In en, this message translates to:
  /// **'No card registered'**
  String get bankAccountNoCardTitle;

  /// No description provided for @bankAccountNoCardBody.
  ///
  /// In en, this message translates to:
  /// **'Add a debit or credit card to receive your disbursements.'**
  String get bankAccountNoCardBody;

  /// No description provided for @bankAccountNoDetails.
  ///
  /// In en, this message translates to:
  /// **'Register a card to see where your payments arrive.'**
  String get bankAccountNoDetails;

  /// No description provided for @bankAccountHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Holder'**
  String get bankAccountHolderLabel;

  /// No description provided for @bankAccountCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get bankAccountCardLabel;

  /// No description provided for @bankAccountYapeLinkedValue.
  ///
  /// In en, this message translates to:
  /// **'Linked to {phone}'**
  String bankAccountYapeLinkedValue(String phone);

  /// No description provided for @bankAccountYapeLinkedDefaultValue.
  ///
  /// In en, this message translates to:
  /// **'Linked to {phone} · Default account'**
  String bankAccountYapeLinkedDefaultValue(String phone);

  /// No description provided for @bankAccountWalletLimitNote.
  ///
  /// In en, this message translates to:
  /// **'Yape and Plin move up to S/ 500 per transfer. Larger disbursements go to your card account.'**
  String get bankAccountWalletLimitNote;

  /// No description provided for @changePinTitle.
  ///
  /// In en, this message translates to:
  /// **'New security PIN'**
  String get changePinTitle;

  /// No description provided for @changePinConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get changePinConfirmTitle;

  /// No description provided for @changePinHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter your new 4-digit PIN'**
  String get changePinHeading;

  /// No description provided for @changePinConfirmHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again'**
  String get changePinConfirmHeading;

  /// No description provided for @changePinContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get changePinContinue;

  /// No description provided for @changePinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get changePinConfirm;

  /// No description provided for @changePinEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit PIN'**
  String get changePinEdit;

  /// No description provided for @changePinCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get changePinCancel;

  /// No description provided for @changePinMismatch.
  ///
  /// In en, this message translates to:
  /// **'The PINs do not match. Please try again.'**
  String get changePinMismatch;

  /// No description provided for @changePinDigitLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN digit {index} of 4'**
  String changePinDigitLabel(int index);

  /// No description provided for @changePinDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Flow preview. Your current PIN will not be changed.'**
  String get changePinDemoNotice;

  /// No description provided for @changePinCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN preview complete'**
  String get changePinCompleteTitle;

  /// No description provided for @changePinCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You have completed the PIN change preview. Your current PIN has not been changed.'**
  String get changePinCompleteBody;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportTitle;

  /// No description provided for @reportNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get reportNoConnection;

  /// No description provided for @reportOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'If you have no signal, the report will be sent automatically when the connection returns.'**
  String get reportOfflineBody;

  /// No description provided for @reportTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue type'**
  String get reportTypeLabel;

  /// No description provided for @reportTypeTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical issue'**
  String get reportTypeTechnical;

  /// No description provided for @reportTypePayment.
  ///
  /// In en, this message translates to:
  /// **'Payment issue'**
  String get reportTypePayment;

  /// No description provided for @reportTypePlot.
  ///
  /// In en, this message translates to:
  /// **'Plot or harvest'**
  String get reportTypePlot;

  /// No description provided for @reportTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportTypeOther;

  /// No description provided for @reportDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportDescriptionLabel;

  /// No description provided for @reportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened and when'**
  String get reportDescriptionHint;

  /// No description provided for @reportAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attach photo (optional)'**
  String get reportAttachPhoto;

  /// No description provided for @reportPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo attached'**
  String get reportPhotoAttached;

  /// No description provided for @reportSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSend;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the buyer'**
  String get ratingTitle;

  /// No description provided for @ratingSection.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get ratingSection;

  /// No description provided for @ratingCycleDate.
  ///
  /// In en, this message translates to:
  /// **'15 Feb 2027'**
  String get ratingCycleDate;

  /// No description provided for @ratingContractEnded.
  ///
  /// In en, this message translates to:
  /// **'Contract ended · {date}'**
  String ratingContractEnded(String date);

  /// No description provided for @ratingPreviewBuyer.
  ///
  /// In en, this message translates to:
  /// **'Valeria Mendoza'**
  String get ratingPreviewBuyer;

  /// No description provided for @ratingPreviewCompany.
  ///
  /// In en, this message translates to:
  /// **'Distribuidora La Cosecha'**
  String get ratingPreviewCompany;

  /// No description provided for @ratingPreviewPlot.
  ///
  /// In en, this message translates to:
  /// **'Esperanza'**
  String get ratingPreviewPlot;

  /// No description provided for @ratingBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer: {name}'**
  String ratingBuyer(String name);

  /// No description provided for @ratingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you rate the experience?'**
  String get ratingQuestion;

  /// No description provided for @ratingSelected.
  ///
  /// In en, this message translates to:
  /// **'Your rating: {score} of 5'**
  String ratingSelected(int score);

  /// No description provided for @ratingCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get ratingCommentTitle;

  /// No description provided for @ratingCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment about your experience...'**
  String get ratingCommentHint;

  /// No description provided for @ratingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get ratingSubmit;

  /// No description provided for @ratingStarDescription.
  ///
  /// In en, this message translates to:
  /// **'{score} out of 5 stars'**
  String ratingStarDescription(int score);

  /// No description provided for @ratingPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview only. This rating is not sent to the server.'**
  String get ratingPreviewNotice;

  /// No description provided for @ratingSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted'**
  String get ratingSubmittedTitle;

  /// No description provided for @ratingLaterStage.
  ///
  /// In en, this message translates to:
  /// **'Later stage · {date} · Cycle ended'**
  String ratingLaterStage(String date);

  /// No description provided for @ratingThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating'**
  String get ratingThanks;

  /// No description provided for @ratingThanksBody.
  ///
  /// In en, this message translates to:
  /// **'Your rating of {name} was submitted.'**
  String ratingThanksBody(String name);

  /// No description provided for @ratingSubmittedValue.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted: {score} of 5'**
  String ratingSubmittedValue(int score);

  /// No description provided for @ratingSubmittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted by {farmer} to {buyer} of {company}.'**
  String ratingSubmittedBy(String farmer, String buyer, String company);

  /// No description provided for @ratingNoComment.
  ///
  /// In en, this message translates to:
  /// **'No additional comment.'**
  String get ratingNoComment;

  /// No description provided for @ratingBackProfile.
  ///
  /// In en, this message translates to:
  /// **'Back to profile'**
  String get ratingBackProfile;

  /// No description provided for @ratingFarmerPreview.
  ///
  /// In en, this message translates to:
  /// **'Miguel Quispe'**
  String get ratingFarmerPreview;

  /// No description provided for @profileRolePlace.
  ///
  /// In en, this message translates to:
  /// **'{role} · {place}'**
  String profileRolePlace(String role, String place);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case '419':
            return AppLocalizationsEs419();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
