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

  /// No description provided for @onboardingPlotTitle.
  ///
  /// In en, this message translates to:
  /// **'List your plot'**
  String get onboardingPlotTitle;

  /// No description provided for @onboardingPlotBody.
  ///
  /// In en, this message translates to:
  /// **'Register your plots and crops to get funding from verified traders.'**
  String get onboardingPlotBody;

  /// No description provided for @onboardingPlotImage.
  ///
  /// In en, this message translates to:
  /// **'A new crop growing from a plot'**
  String get onboardingPlotImage;

  /// No description provided for @onboardingEscrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Escrow financing'**
  String get onboardingEscrowTitle;

  /// No description provided for @onboardingEscrowBody.
  ///
  /// In en, this message translates to:
  /// **'Funds held in Escrow; released when each milestone is approved.'**
  String get onboardingEscrowBody;

  /// No description provided for @onboardingEscrowImage.
  ///
  /// In en, this message translates to:
  /// **'A padlock representing protected funds'**
  String get onboardingEscrowImage;

  /// No description provided for @onboardingWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Free weather alerts'**
  String get onboardingWeatherTitle;

  /// No description provided for @onboardingWeatherBody.
  ///
  /// In en, this message translates to:
  /// **'Get frost, heavy rain and drought alerts to protect your crop.'**
  String get onboardingWeatherBody;

  /// No description provided for @onboardingWeatherImage.
  ///
  /// In en, this message translates to:
  /// **'Sun and cloud representing weather alerts'**
  String get onboardingWeatherImage;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back to role selection'**
  String get onboardingBack;

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

  /// No description provided for @plotsFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get plotsFilterApproved;

  /// No description provided for @plotsFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get plotsFilterPending;

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

  /// No description provided for @plotCurrentStage.
  ///
  /// In en, this message translates to:
  /// **'Current stage:'**
  String get plotCurrentStage;

  /// No description provided for @plotProgressComplete.
  ///
  /// In en, this message translates to:
  /// **'{progress}% complete'**
  String plotProgressComplete(int progress);

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

  /// No description provided for @merchantNoFunded.
  ///
  /// In en, this message translates to:
  /// **'You have not funded any plots yet'**
  String get merchantNoFunded;

  /// No description provided for @merchantActiveFundedPlots.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 funded plot} other{{count} funded plots}}'**
  String merchantActiveFundedPlots(int count);

  /// No description provided for @merchantRainRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Moderate rain risk'**
  String get merchantRainRiskTitle;

  /// No description provided for @merchantRainRiskBody.
  ///
  /// In en, this message translates to:
  /// **'{count} plot in Cusco needs monitoring'**
  String merchantRainRiskBody(int count);

  /// No description provided for @merchantRainRiskBodyPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} plots in Cusco need monitoring'**
  String merchantRainRiskBodyPlural(int count);

  /// No description provided for @merchantRainRiskTemp.
  ///
  /// In en, this message translates to:
  /// **'18°C'**
  String get merchantRainRiskTemp;

  /// No description provided for @merchantShowReviewFirst.
  ///
  /// In en, this message translates to:
  /// **'Show plots needing review first'**
  String get merchantShowReviewFirst;

  /// No description provided for @merchantMilestonesFraction.
  ///
  /// In en, this message translates to:
  /// **'Milestones: {approved}/{total}'**
  String merchantMilestonesFraction(int approved, int total);

  /// No description provided for @merchantInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get merchantInProgress;

  /// No description provided for @merchantStatusFundedChip.
  ///
  /// In en, this message translates to:
  /// **'Funded'**
  String get merchantStatusFundedChip;

  /// No description provided for @merchantNeedsYourReview.
  ///
  /// In en, this message translates to:
  /// **'Needs your review'**
  String get merchantNeedsYourReview;

  /// No description provided for @merchantCurrentMilestone.
  ///
  /// In en, this message translates to:
  /// **'Current milestone:'**
  String get merchantCurrentMilestone;

  /// No description provided for @merchantNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next:'**
  String get merchantNextMilestone;

  /// No description provided for @merchantPlotDetails.
  ///
  /// In en, this message translates to:
  /// **'Plot details'**
  String get merchantPlotDetails;

  /// No description provided for @merchantAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get merchantAvailable;

  /// No description provided for @merchantFinancialStatus.
  ///
  /// In en, this message translates to:
  /// **'Financial status'**
  String get merchantFinancialStatus;

  /// No description provided for @merchantEscrowDeposit.
  ///
  /// In en, this message translates to:
  /// **'Escrow deposit'**
  String get merchantEscrowDeposit;

  /// No description provided for @merchantFundingDate.
  ///
  /// In en, this message translates to:
  /// **'Funding date'**
  String get merchantFundingDate;

  /// No description provided for @merchantFundsReleased.
  ///
  /// In en, this message translates to:
  /// **'Funds released'**
  String get merchantFundsReleased;

  /// No description provided for @merchantEscrowBalance.
  ///
  /// In en, this message translates to:
  /// **'Escrow balance'**
  String get merchantEscrowBalance;

  /// No description provided for @merchantApprovedProgress.
  ///
  /// In en, this message translates to:
  /// **'Approved milestones: {approved}/{total} · {percent} %'**
  String merchantApprovedProgress(int approved, int total, int percent);

  /// No description provided for @merchantCropDetails.
  ///
  /// In en, this message translates to:
  /// **'Crop details'**
  String get merchantCropDetails;

  /// No description provided for @merchantCropLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get merchantCropLabel;

  /// No description provided for @merchantAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get merchantAreaLabel;

  /// No description provided for @merchantHarvestLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated harvest'**
  String get merchantHarvestLabel;

  /// No description provided for @merchantPaymentPerMilestone.
  ///
  /// In en, this message translates to:
  /// **'Payment per milestone'**
  String get merchantPaymentPerMilestone;

  /// No description provided for @merchantFarmerFunder.
  ///
  /// In en, this message translates to:
  /// **'Farmer: {farmer} · Funder: {funder} ({company})'**
  String merchantFarmerFunder(String farmer, String funder, String company);

  /// No description provided for @merchantContactFarmer.
  ///
  /// In en, this message translates to:
  /// **'Contact {name}'**
  String merchantContactFarmer(String name);

  /// No description provided for @merchantFundPlot.
  ///
  /// In en, this message translates to:
  /// **'Fund this plot'**
  String get merchantFundPlot;

  /// No description provided for @merchantFundTitle.
  ///
  /// In en, this message translates to:
  /// **'Fund plot'**
  String get merchantFundTitle;

  /// No description provided for @merchantTotalInvestment.
  ///
  /// In en, this message translates to:
  /// **'TOTAL INVESTMENT'**
  String get merchantTotalInvestment;

  /// No description provided for @merchantListedAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount listed by the farmer'**
  String get merchantListedAmount;

  /// No description provided for @merchantFixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount'**
  String get merchantFixedAmount;

  /// No description provided for @merchantDisbursement.
  ///
  /// In en, this message translates to:
  /// **'DISBURSEMENT PLAN'**
  String get merchantDisbursement;

  /// No description provided for @merchantEscrowHow.
  ///
  /// In en, this message translates to:
  /// **'HOW ESCROW PROTECTS YOU'**
  String get merchantEscrowHow;

  /// No description provided for @merchantEscrowSafe.
  ///
  /// In en, this message translates to:
  /// **'Your funds stay safe'**
  String get merchantEscrowSafe;

  /// No description provided for @merchantEscrowApprove.
  ///
  /// In en, this message translates to:
  /// **'You approve each proof'**
  String get merchantEscrowApprove;

  /// No description provided for @merchantEscrowHarvest.
  ///
  /// In en, this message translates to:
  /// **'You receive your harvest'**
  String get merchantEscrowHarvest;

  /// No description provided for @merchantPaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get merchantPaymentMethodTitle;

  /// No description provided for @merchantPayCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get merchantPayCard;

  /// No description provided for @merchantPayWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get merchantPayWallet;

  /// No description provided for @merchantPayAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent deposit'**
  String get merchantPayAgent;

  /// No description provided for @merchantPayBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get merchantPayBank;

  /// No description provided for @merchantFundTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the terms of the escrow financing agreement'**
  String get merchantFundTerms;

  /// No description provided for @merchantAcceptFirst.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms first'**
  String get merchantAcceptFirst;

  /// No description provided for @merchantContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get merchantContinue;

  /// No description provided for @merchantConfirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm and pay {amount}'**
  String merchantConfirmAndPay(String amount);

  /// No description provided for @merchantFinancingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Financing confirmed'**
  String get merchantFinancingConfirmed;

  /// No description provided for @merchantFinancingConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is funded by {method} and the funds are held in escrow.'**
  String merchantFinancingConfirmedBody(String name, String method);

  /// No description provided for @merchantBackToMyPlots.
  ///
  /// In en, this message translates to:
  /// **'Back to my plots'**
  String get merchantBackToMyPlots;

  /// No description provided for @merchantPayFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be registered.'**
  String get merchantPayFailed;

  /// No description provided for @merchantFundSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get merchantFundSuccessTitle;

  /// No description provided for @merchantFundsSecured.
  ///
  /// In en, this message translates to:
  /// **'Funds secured in Escrow'**
  String get merchantFundsSecured;

  /// No description provided for @merchantSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{plot} is now financed.\n{farmer} has received a confirmation.'**
  String merchantSuccessBody(String plot, String farmer);

  /// No description provided for @merchantAmountFunded.
  ///
  /// In en, this message translates to:
  /// **'Amount funded'**
  String get merchantAmountFunded;

  /// No description provided for @merchantPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get merchantPaymentMethodLabel;

  /// No description provided for @merchantReceiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get merchantReceiptStatus;

  /// No description provided for @merchantHeldInEscrow.
  ///
  /// In en, this message translates to:
  /// **'Funds held in Escrow'**
  String get merchantHeldInEscrow;

  /// No description provided for @merchantReceiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get merchantReceiptDate;

  /// No description provided for @merchantReleaseNote.
  ///
  /// In en, this message translates to:
  /// **'Payments will be released to the farmer as you approve each milestone.'**
  String get merchantReleaseNote;

  /// No description provided for @merchantViewFinancedPlot.
  ///
  /// In en, this message translates to:
  /// **'View financed plot'**
  String get merchantViewFinancedPlot;

  /// No description provided for @merchantDownloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download receipt'**
  String get merchantDownloadReceipt;

  /// No description provided for @merchantReceiptSaved.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved to {path}'**
  String merchantReceiptSaved(String path);

  /// No description provided for @merchantReceiptSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The receipt could not be saved.'**
  String get merchantReceiptSaveFailed;

  /// No description provided for @muyuContactMissing.
  ///
  /// In en, this message translates to:
  /// **'No valid contact email is available.'**
  String get muyuContactMissing;

  /// No description provided for @muyuContactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No email app could be opened.'**
  String get muyuContactUnavailable;

  /// No description provided for @merchantVisitRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request visit'**
  String get merchantVisitRequestTitle;

  /// No description provided for @merchantVisitStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit request'**
  String get merchantVisitStatusTitle;

  /// No description provided for @merchantVisitProposedDate.
  ///
  /// In en, this message translates to:
  /// **'PROPOSED DATE'**
  String get merchantVisitProposedDate;

  /// No description provided for @merchantVisitPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'PREFERRED TIME'**
  String get merchantVisitPreferredTime;

  /// No description provided for @merchantVisitMessage.
  ///
  /// In en, this message translates to:
  /// **'Message to farmer (optional)'**
  String get merchantVisitMessage;

  /// No description provided for @merchantVisitMessageHint.
  ///
  /// In en, this message translates to:
  /// **'I’d like to review the irrigation system'**
  String get merchantVisitMessageHint;

  /// No description provided for @merchantVisitDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Requesting a visit does not reserve or fund the plot. The farmer will record whether an agreement was reached.'**
  String get merchantVisitDisclaimer;

  /// No description provided for @merchantVisitSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get merchantVisitSending;

  /// No description provided for @merchantVisitSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send the visit request: {error}'**
  String merchantVisitSendError(String error);

  /// No description provided for @merchantVisitSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get merchantVisitSend;

  /// No description provided for @merchantVisitSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get merchantVisitSent;

  /// No description provided for @merchantVisitSentBody.
  ///
  /// In en, this message translates to:
  /// **'{name} received your visit proposal.'**
  String merchantVisitSentBody(String name);

  /// No description provided for @merchantVisitToPlot.
  ///
  /// In en, this message translates to:
  /// **'Visit to {name}'**
  String merchantVisitToPlot(String name);

  /// No description provided for @merchantVisitDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get merchantVisitDate;

  /// No description provided for @merchantVisitTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get merchantVisitTime;

  /// No description provided for @merchantVisitPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get merchantVisitPlace;

  /// No description provided for @merchantVisitCoordinationOnly.
  ///
  /// In en, this message translates to:
  /// **'Visit coordination only. It does not reserve or fund the plot. No charges or Escrow deposit.'**
  String get merchantVisitCoordinationOnly;

  /// No description provided for @merchantVisitBackPlot.
  ///
  /// In en, this message translates to:
  /// **'Back to plot'**
  String get merchantVisitBackPlot;

  /// No description provided for @merchantVisitConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Visit confirmed'**
  String get merchantVisitConfirmed;

  /// No description provided for @merchantVisitConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} accepted your visit proposal.'**
  String merchantVisitConfirmedBody(String name);

  /// No description provided for @merchantVisitMeetingPoint.
  ///
  /// In en, this message translates to:
  /// **'Meeting point'**
  String get merchantVisitMeetingPoint;

  /// No description provided for @merchantVisitMeetingHint.
  ///
  /// In en, this message translates to:
  /// **'Entrance to the plot near the main road. Coordinate with the farmer before arriving.'**
  String get merchantVisitMeetingHint;

  /// No description provided for @merchantViewEvidence.
  ///
  /// In en, this message translates to:
  /// **'View evidence'**
  String get merchantViewEvidence;

  /// No description provided for @merchantVisitRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Request visit'**
  String get merchantVisitRequestButton;

  /// No description provided for @merchantHarvestReceiptPending.
  ///
  /// In en, this message translates to:
  /// **'Harvest receipt · Pending'**
  String get merchantHarvestReceiptPending;

  /// No description provided for @merchantExactLocation.
  ///
  /// In en, this message translates to:
  /// **'Exact location'**
  String get merchantExactLocation;

  /// No description provided for @merchantFarmerStats.
  ///
  /// In en, this message translates to:
  /// **'12 years of experience · 8 plots completed'**
  String get merchantFarmerStats;

  /// No description provided for @merchantApprovalRate.
  ///
  /// In en, this message translates to:
  /// **'94% approval rate'**
  String get merchantApprovalRate;

  /// No description provided for @merchantMilestoneApprovedLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · Approved {amount}'**
  String merchantMilestoneApprovedLine(String date, String amount);

  /// No description provided for @merchantMilestoneAwaitingLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time} · Awaiting review · {amount}'**
  String merchantMilestoneAwaitingLine(String date, String time, String amount);

  /// No description provided for @merchantMilestonePendingLine.
  ///
  /// In en, this message translates to:
  /// **'{date} · Pending {amount}'**
  String merchantMilestonePendingLine(String date, String amount);

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

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

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

  /// No description provided for @profileNewPlotAlerts.
  ///
  /// In en, this message translates to:
  /// **'New plot alerts'**
  String get profileNewPlotAlerts;

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

  /// No description provided for @ratingNoContracts.
  ///
  /// In en, this message translates to:
  /// **'You have no finished contracts to rate yet.'**
  String get ratingNoContracts;

  /// No description provided for @reportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reports cannot be sent from the app yet. Call technical support and we will help you.'**
  String get reportUnavailable;

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

  /// No description provided for @reportSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get reportSendRequest;

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

  /// No description provided for @ratingContractEnded.
  ///
  /// In en, this message translates to:
  /// **'Contract ended · {date}'**
  String ratingContractEnded(String date);

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
  /// **'Your rating is not saved on the server yet.'**
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

  /// No description provided for @profileRolePlace.
  ///
  /// In en, this message translates to:
  /// **'{role} · {place}'**
  String profileRolePlace(String role, String place);

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentsTitle;

  /// No description provided for @paymentsTotalReceived.
  ///
  /// In en, this message translates to:
  /// **'TOTAL RECEIVED'**
  String get paymentsTotalReceived;

  /// No description provided for @paymentsTotalReleased.
  ///
  /// In en, this message translates to:
  /// **'TOTAL RELEASED'**
  String get paymentsTotalReleased;

  /// No description provided for @paymentsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed payments'**
  String paymentsCompletedCount(int count);

  /// No description provided for @paymentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get paymentsEmptyTitle;

  /// No description provided for @paymentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Payments appear here when evidence for a financed milestone is approved.'**
  String get paymentsEmptyBody;

  /// No description provided for @paymentsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentsFilterAll;

  /// No description provided for @paymentsFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get paymentsFilterCompleted;

  /// No description provided for @paymentsFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentsFilterPending;

  /// No description provided for @paymentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get paymentDetailsTitle;

  /// No description provided for @paymentTransactionDetails.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION DETAILS'**
  String get paymentTransactionDetails;

  /// No description provided for @paymentLabelMilestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get paymentLabelMilestone;

  /// No description provided for @paymentLabelPlot.
  ///
  /// In en, this message translates to:
  /// **'Plot'**
  String get paymentLabelPlot;

  /// No description provided for @paymentLabelDate.
  ///
  /// In en, this message translates to:
  /// **'Release date'**
  String get paymentLabelDate;

  /// No description provided for @paymentLabelAccount.
  ///
  /// In en, this message translates to:
  /// **'Destination account'**
  String get paymentLabelAccount;

  /// No description provided for @paymentLabelTxid.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get paymentLabelTxid;

  /// No description provided for @paymentLabelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentLabelAmount;

  /// No description provided for @paymentPendingDate.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get paymentPendingDate;

  /// No description provided for @paymentEscrowExplanation.
  ///
  /// In en, this message translates to:
  /// **'Funds are released only after the merchant approves the milestone evidence.'**
  String get paymentEscrowExplanation;

  /// No description provided for @paymentMilestonePlanting.
  ///
  /// In en, this message translates to:
  /// **'Planting'**
  String get paymentMilestonePlanting;

  /// No description provided for @paymentMilestoneIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation'**
  String get paymentMilestoneIrrigation;

  /// No description provided for @paymentMilestoneFertilization.
  ///
  /// In en, this message translates to:
  /// **'Fertilization'**
  String get paymentMilestoneFertilization;

  /// No description provided for @paymentMilestoneHarvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest'**
  String get paymentMilestoneHarvest;

  /// No description provided for @weatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather alert'**
  String get weatherTitle;

  /// No description provided for @weatherLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking the weather for your plot…'**
  String get weatherLoading;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather is unavailable for this plot right now.'**
  String get weatherUnavailable;

  /// No description provided for @weatherStable.
  ///
  /// In en, this message translates to:
  /// **'Stable conditions'**
  String get weatherStable;

  /// No description provided for @weatherHeavyRain.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain expected'**
  String get weatherHeavyRain;

  /// No description provided for @weatherModerateRain.
  ///
  /// In en, this message translates to:
  /// **'Moderate rain expected'**
  String get weatherModerateRain;

  /// No description provided for @weatherFrost.
  ///
  /// In en, this message translates to:
  /// **'Frost risk'**
  String get weatherFrost;

  /// No description provided for @weatherEstTemp.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get weatherEstTemp;

  /// No description provided for @weatherEstTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get weatherEstTime;

  /// No description provided for @weatherTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get weatherTonight;

  /// No description provided for @weatherToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get weatherToday;

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'5-day forecast'**
  String get weatherForecast;

  /// No description provided for @weatherCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle {year}'**
  String weatherCycle(String year);

  /// No description provided for @weatherRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk level'**
  String get weatherRisk;

  /// No description provided for @weatherRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get weatherRiskHigh;

  /// No description provided for @weatherRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get weatherRiskMedium;

  /// No description provided for @weatherRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get weatherRiskLow;

  /// No description provided for @weatherRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommended measures'**
  String get weatherRecommendations;

  /// No description provided for @weatherMeasureDrainage.
  ///
  /// In en, this message translates to:
  /// **'Check drainage and field access'**
  String get weatherMeasureDrainage;

  /// No description provided for @weatherMeasureCover.
  ///
  /// In en, this message translates to:
  /// **'Protect sensitive crops'**
  String get weatherMeasureCover;

  /// No description provided for @weatherMeasureIrrigation.
  ///
  /// In en, this message translates to:
  /// **'Adjust irrigation to the forecast'**
  String get weatherMeasureIrrigation;

  /// No description provided for @weatherMeasureMonitor.
  ///
  /// In en, this message translates to:
  /// **'Monitor crop moisture and stress'**
  String get weatherMeasureMonitor;

  /// No description provided for @weatherMeasuresPending.
  ///
  /// In en, this message translates to:
  /// **'Pending attention'**
  String get weatherMeasuresPending;

  /// No description provided for @weatherMeasuresDone.
  ///
  /// In en, this message translates to:
  /// **'Measures recorded'**
  String get weatherMeasuresDone;

  /// No description provided for @weatherMeasuresHint.
  ///
  /// In en, this message translates to:
  /// **'Select the actions you took to protect your crop.'**
  String get weatherMeasuresHint;

  /// No description provided for @weatherMeasuresConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save measures taken'**
  String get weatherMeasuresConfirm;

  /// No description provided for @weatherMeasuresRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one measure.'**
  String get weatherMeasuresRequired;

  /// No description provided for @merchantAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get merchantAlertsTitle;

  /// No description provided for @merchantAlertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'When farmers send evidence or request extensions on your financed plots, you will see alerts here.'**
  String get merchantAlertsEmpty;

  /// No description provided for @merchantAlertPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment review'**
  String get merchantAlertPayment;

  /// No description provided for @merchantAlertWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather alert'**
  String get merchantAlertWeather;

  /// No description provided for @merchantAlertWeatherBody.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain expected near {plot} over the next 24 hours.'**
  String merchantAlertWeatherBody(String plot);

  /// No description provided for @merchantAlertPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'{farmer} sent {milestone} evidence. Review it to release {amount}.'**
  String merchantAlertPaymentBody(String farmer, String milestone, String amount);

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get resetTitle;

  /// No description provided for @resetHeading.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you back into your account'**
  String get resetHeading;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will show you the next recovery step.'**
  String get resetBody;

  /// No description provided for @resetEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get resetEmailPrompt;

  /// No description provided for @resetNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resetNext;

  /// No description provided for @resetInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get resetInvalidEmail;

  /// No description provided for @resetSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get resetSentTitle;

  /// No description provided for @resetSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, you will receive recovery instructions.'**
  String resetSentBody(String email);

  /// No description provided for @resetDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Recovery preview: the server does not yet send reset emails.'**
  String get resetDemoNotice;

  /// No description provided for @resetBackLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get resetBackLogin;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get loginForgotPassword;
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
