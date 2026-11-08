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

  /// No description provided for @registerDni.
  ///
  /// In en, this message translates to:
  /// **'DNI'**
  String get registerDni;

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
  /// **'Enter a valid Gmail address.'**
  String get registerEmailInvalid;

  /// No description provided for @registerPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get registerPhoneInvalid;

  /// No description provided for @registerDniInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 8-digit DNI.'**
  String get registerDniInvalid;

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

  /// No description provided for @plotsPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get plotsPublish;

  /// No description provided for @plotsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plots'**
  String get plotsSearchHint;

  /// No description provided for @plotsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get plotsFilterAll;

  /// No description provided for @plotsFilterFunded.
  ///
  /// In en, this message translates to:
  /// **'Funded'**
  String get plotsFilterFunded;

  /// No description provided for @plotsFilterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get plotsFilterAvailable;

  /// No description provided for @plotsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No plots match your search or filter.'**
  String get plotsNoMatch;

  /// No description provided for @plotsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load plots. Please try again.'**
  String get plotsLoadError;

  /// No description provided for @plotsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get plotsRetry;

  /// No description provided for @plotHarvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest: {date}'**
  String plotHarvest(String date);

  /// No description provided for @publishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishTitle;

  /// No description provided for @publishStep.
  ///
  /// In en, this message translates to:
  /// **'STEP {current} OF {total}'**
  String publishStep(int current, int total);

  /// No description provided for @publishStepInfo.
  ///
  /// In en, this message translates to:
  /// **'PLOT INFORMATION'**
  String get publishStepInfo;

  /// No description provided for @publishStepLocation.
  ///
  /// In en, this message translates to:
  /// **'PLOT LOCATION'**
  String get publishStepLocation;

  /// No description provided for @publishStepFinancing.
  ///
  /// In en, this message translates to:
  /// **'FINANCING'**
  String get publishStepFinancing;

  /// No description provided for @publishPlotName.
  ///
  /// In en, this message translates to:
  /// **'Plot name'**
  String get publishPlotName;

  /// No description provided for @publishCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop type'**
  String get publishCrop;

  /// No description provided for @publishArea.
  ///
  /// In en, this message translates to:
  /// **'Area (hectares)'**
  String get publishArea;

  /// No description provided for @publishHarvest.
  ///
  /// In en, this message translates to:
  /// **'Estimated harvest'**
  String get publishHarvest;

  /// No description provided for @publishHarvestHint.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get publishHarvestHint;

  /// No description provided for @publishNextLocation.
  ///
  /// In en, this message translates to:
  /// **'Next: location'**
  String get publishNextLocation;

  /// No description provided for @publishRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get publishRegion;

  /// No description provided for @publishProvince.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get publishProvince;

  /// No description provided for @publishDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get publishDistrict;

  /// No description provided for @publishAddress.
  ///
  /// In en, this message translates to:
  /// **'Address or landmark'**
  String get publishAddress;

  /// No description provided for @publishNextFinancing.
  ///
  /// In en, this message translates to:
  /// **'Next: financing'**
  String get publishNextFinancing;

  /// No description provided for @publishTotal.
  ///
  /// In en, this message translates to:
  /// **'Total financing amount (S/)'**
  String get publishTotal;

  /// No description provided for @publishCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle duration'**
  String get publishCycle;

  /// No description provided for @publishCycleMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String publishCycleMonths(int months);

  /// No description provided for @publishMilestones.
  ///
  /// In en, this message translates to:
  /// **'Payment milestones: 4'**
  String get publishMilestones;

  /// No description provided for @publishPlan.
  ///
  /// In en, this message translates to:
  /// **'Disbursement plan'**
  String get publishPlan;

  /// No description provided for @publishPlanPlanting.
  ///
  /// In en, this message translates to:
  /// **'Planting'**
  String get publishPlanPlanting;

  /// No description provided for @publishPlanIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get publishPlanIrrigation;

  /// No description provided for @publishPlanFertilization.
  ///
  /// In en, this message translates to:
  /// **'Fertilization'**
  String get publishPlanFertilization;

  /// No description provided for @publishPlanHarvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get publishPlanHarvest;

  /// No description provided for @publishFundsHeld.
  ///
  /// In en, this message translates to:
  /// **'Funds will remain in custody and will be released after each milestone is approved.'**
  String get publishFundsHeld;

  /// No description provided for @publishAcceptCustody.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the custody (escrow) agreement'**
  String get publishAcceptCustody;

  /// No description provided for @publishConfirm.
  ///
  /// In en, this message translates to:
  /// **'Publish plot'**
  String get publishConfirm;

  /// No description provided for @publishSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your plot is published!'**
  String get publishSuccess;

  /// No description provided for @publishRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete this field.'**
  String get publishRequired;

  /// No description provided for @publishNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get publishNumberInvalid;

  /// No description provided for @publishRejected.
  ///
  /// In en, this message translates to:
  /// **'We could not publish the plot. Please try again.'**
  String get publishRejected;

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
