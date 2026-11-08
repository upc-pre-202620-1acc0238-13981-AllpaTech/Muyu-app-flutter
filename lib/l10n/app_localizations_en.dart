// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Muyu';

  @override
  String get splashLogo => 'MUYU';

  @override
  String get splashTagline => 'Connecting the countryside';

  @override
  String get languageCode => 'EN';

  @override
  String get languageToggleLabel => 'Change language to Spanish';

  @override
  String get back => 'Back';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginHero => 'Muyu character with a credential';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginRegister => 'Register';

  @override
  String get loginInvalid => 'Invalid email or password';

  @override
  String get loginNetworkError => 'We could not reach Muyu. Check your connection and try again.';

  @override
  String get loginLoading => 'Signing in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerName => 'Name';

  @override
  String get registerPhone => 'Phone number';

  @override
  String get registerDni => 'DNI';

  @override
  String get registerBirthdate => 'Date of birth';

  @override
  String get registerBirthdateHint => 'Select a date';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerButton => 'Register';

  @override
  String get registerHaveAccount => 'Do you have an account?';

  @override
  String get registerAcceptTerms => 'I have read and accept the terms and conditions';

  @override
  String get registerNameInvalid => 'Enter a valid name using 2 to 60 letters.';

  @override
  String get registerEmailInvalid => 'Enter a valid Gmail address.';

  @override
  String get registerPhoneInvalid => 'Enter a valid number.';

  @override
  String get registerDniInvalid => 'Enter a valid 8-digit DNI.';

  @override
  String get registerBirthdateRequired => 'Select your date of birth.';

  @override
  String get registerBirthdateInvalid => 'You must be between 18 and 90 years old.';

  @override
  String get registerPasswordInvalid =>
      'Password must contain 8+ characters, uppercase, lowercase, a number, and a special character.';

  @override
  String get registerPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerTermsRequired => 'Accept the terms and conditions to continue.';

  @override
  String get registerRuleLength => 'At least 8 characters';

  @override
  String get registerRuleUppercase => 'One uppercase letter';

  @override
  String get registerRuleLowercase => 'One lowercase letter';

  @override
  String get registerRuleNumber => 'One number';

  @override
  String get registerRuleSpecial => 'One special character, such as * ! @ #';

  @override
  String get registerRuleNoSpaces => 'No spaces';

  @override
  String get registerRuleMet => 'Met';

  @override
  String get registerRuleMissing => 'Missing';

  @override
  String get registerError => 'Could not create the account';

  @override
  String get registerSuccess => 'Account created. Log in to continue.';

  @override
  String get roleQuestion => 'How will you use MUYU?';

  @override
  String get roleSubtitle => 'Select your role to personalize your experience.';

  @override
  String get roleFarmerTitle => 'I am a farmer';

  @override
  String get roleFarmerBody =>
      'List your plots, log cultivation milestones, and receive secure payments';

  @override
  String get roleFarmerImage => 'Farmer';

  @override
  String get roleMerchantTitle => 'I am a merchant';

  @override
  String get roleMerchantBody =>
      'Explore the catalog of plots, finance harvests, and approve milestones securely';

  @override
  String get roleMerchantImage => 'Merchant';

  @override
  String get roleNext => 'Next';

  @override
  String get plotsPublish => 'Publish';

  @override
  String get plotsSearchHint => 'Search plots';

  @override
  String get plotsFilterAll => 'All';

  @override
  String get plotsFilterFunded => 'Funded';

  @override
  String get plotsFilterAvailable => 'Available';

  @override
  String get plotsNoMatch => 'No plots match your search or filter.';

  @override
  String get plotsLoadError => 'Unable to load plots. Please try again.';

  @override
  String get plotsRetry => 'Try again';

  @override
  String plotHarvest(String date) {
    return 'Harvest: $date';
  }

  @override
  String get publishTitle => 'Publish';

  @override
  String publishStep(int current, int total) {
    return 'STEP $current OF $total';
  }

  @override
  String get publishStepInfo => 'PLOT INFORMATION';

  @override
  String get publishStepLocation => 'PLOT LOCATION';

  @override
  String get publishStepFinancing => 'FINANCING';

  @override
  String get publishPlotName => 'Plot name';

  @override
  String get publishCrop => 'Crop type';

  @override
  String get publishArea => 'Area (hectares)';

  @override
  String get publishHarvest => 'Estimated harvest';

  @override
  String get publishHarvestHint => 'Select a date';

  @override
  String get publishNextLocation => 'Next: location';

  @override
  String get publishRegion => 'Region';

  @override
  String get publishProvince => 'Province';

  @override
  String get publishDistrict => 'District';

  @override
  String get publishAddress => 'Address or landmark';

  @override
  String get publishNextFinancing => 'Next: financing';

  @override
  String get publishTotal => 'Total financing amount (S/)';

  @override
  String get publishCycle => 'Cycle duration';

  @override
  String publishCycleMonths(int months) {
    return '$months months';
  }

  @override
  String get publishMilestones => 'Payment milestones: 4';

  @override
  String get publishPlan => 'Disbursement plan';

  @override
  String get publishPlanPlanting => 'Planting';

  @override
  String get publishPlanIrrigation => 'Irrigation';

  @override
  String get publishPlanFertilization => 'Fertilization';

  @override
  String get publishPlanHarvest => 'Harvest';

  @override
  String get publishFundsHeld =>
      'Funds will remain in custody and will be released after each milestone is approved.';

  @override
  String get publishAcceptCustody => 'I have read and accept the custody (escrow) agreement';

  @override
  String get publishConfirm => 'Publish plot';

  @override
  String get publishSuccess => 'Your plot is published!';

  @override
  String get publishRequired => 'Complete this field.';

  @override
  String get publishNumberInvalid => 'Enter an amount greater than zero.';

  @override
  String get publishRejected => 'We could not publish the plot. Please try again.';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get farmerHomeTitle => 'My plots';

  @override
  String get farmerHomeEmpty => 'You have not published any plots yet.';

  @override
  String get merchantHomeTitle => 'Plot catalog';

  @override
  String get merchantHomeEmpty => 'There are no plots to finance yet.';

  @override
  String get homeChangeRole => 'Change role';

  @override
  String get homeLogout => 'Log out';
}
