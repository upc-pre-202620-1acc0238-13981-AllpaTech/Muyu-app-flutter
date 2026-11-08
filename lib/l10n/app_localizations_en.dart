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

  @override
  String get homeMoreOptions => 'More options';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navMyPlots => 'My plots';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navPayments => 'Payments';

  @override
  String get navPayment => 'Payment';

  @override
  String get navProfile => 'Profile';

  @override
  String get merchantTabSoon => 'This section is coming next.';

  @override
  String get merchantWelcome => 'Welcome,';

  @override
  String get merchantCompanyName => 'Distribuidora La Cosecha';

  @override
  String get merchantSearch => 'Search plots or GPS…';

  @override
  String get merchantSearchIcon => 'Search';

  @override
  String get merchantFilterAll => 'All';

  @override
  String get merchantFilterNear => 'Near me';

  @override
  String get merchantFilterRecommended => 'Recommended';

  @override
  String get merchantVerified => 'Verified farmer';

  @override
  String get merchantMilestones => '94% of milestones approved';

  @override
  String get merchantNoPlots => 'No plots available yet';

  @override
  String get farmerCountryPeru => 'PERU';

  @override
  String get farmerFlagPeru => 'Peru flag';

  @override
  String get roleMerchantShort => 'Merchant';

  @override
  String get profileVerified => 'Verified';

  @override
  String get profileContactDetails => 'CONTACT DETAILS';

  @override
  String get profileEditContact => 'Edit contact';

  @override
  String get profileSaveContact => 'Save';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileCompanyNameLabel => 'Company name';

  @override
  String get profileActivityLabel => 'Activity';

  @override
  String get profileRucLabel => 'RUC';

  @override
  String get profileLocationLabel => 'City';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileNotificationPrefs => 'NOTIFICATION PREFERENCES';

  @override
  String get profileWeatherAlertsQuestion => 'How should we send you weather alerts?';

  @override
  String get profileChannelCall => 'Call';

  @override
  String get profileChannelPush => 'Push';

  @override
  String get profileChannelWhatsapp => 'WhatsApp';

  @override
  String get profilePayment => 'PAYMENT';

  @override
  String get profileSavedMethods => 'Saved payment methods';

  @override
  String get profileVisaBcp => 'Visa ending in 4821 · BCP transfer';

  @override
  String get profileSecurityHelp => 'SECURITY & HELP';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileLegal => 'LEGAL';

  @override
  String get profileTerms => 'Terms and Conditions';

  @override
  String get profilePrivacy => 'Privacy Policy';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileWholesale => 'Wholesale distributor';

  @override
  String get profileCompanyLegalName => 'Distribuidora La Cosecha SAC';

  @override
  String get profileMerchantPlace => 'Lima';

  @override
  String get profileCompanyLocationEmail => 'Lima · contacto@lacosecha.pe';

  @override
  String get profileNewPlotAlerts => 'New plot alerts';

  @override
  String get profileNewPlotAlertsBody => 'Potatoes · Cusco · from 5,000 kg';

  @override
  String get profileComingSoon => 'This section is coming next.';

  @override
  String get paymentNoCard => 'No card registered';

  @override
  String get profileRegisterCard => 'Register card';

  @override
  String get profileChangeCard => 'Change card';

  @override
  String get profileNoWallet => 'No Yape or Plin linked';

  @override
  String get profileChangeWallet => 'Change';

  @override
  String get bankAccountYape => 'Yape';

  @override
  String get bankAccountPlin => 'Plin';

  @override
  String get bankAccountVisaLogo => 'Visa logo';

  @override
  String get addCardTitle => 'Add card';

  @override
  String get addCardDataTitle => 'Card details';

  @override
  String get addCardNumber => 'Card number';

  @override
  String get addCardNumberHint => '0000  0000  0000  0000';

  @override
  String get addCardNumberError => 'Enter a valid Visa or Mastercard number';

  @override
  String get addCardHolder => 'Cardholder name';

  @override
  String get addCardHolderHint => 'As shown on the card';

  @override
  String get addCardExpiration => 'Expiration date';

  @override
  String get addCardExpirationHint => 'MM/YY';

  @override
  String get addCardCvv => 'CVV';

  @override
  String get addCardType => 'Card type';

  @override
  String get addCardDebit => 'Debit';

  @override
  String get addCardCredit => 'Credit';

  @override
  String get addCardPrimary => 'Save as primary card';

  @override
  String get addCardSecurity => 'Your data is protected and stored securely.';

  @override
  String get addCardSave => 'Save card';

  @override
  String get addCardUnknownBrand => 'Unrecognized card brand';

  @override
  String get yapeEditTitle => 'Edit Yape';

  @override
  String get yapeLinked => 'Linked';

  @override
  String get yapeNotLinked => 'Not linked';

  @override
  String get yapeNoPhone => 'No phone number';

  @override
  String get yapeAccountData => 'Account details';

  @override
  String get yapePhoneLabel => 'Mobile number';

  @override
  String get yapePhoneError => 'Enter a valid 9-digit mobile number';

  @override
  String get yapeVerifyPhone => 'Verify number';

  @override
  String get yapePhoneVerified => 'Number verified';

  @override
  String get yapeHolderLabel => 'Account holder';

  @override
  String get yapeSaveChanges => 'Save changes';

  @override
  String get yapeUnlink => 'Unlink Yape';

  @override
  String get plinEditTitle => 'Edit Plin';

  @override
  String get plinUnlink => 'Unlink Plin';

  @override
  String get merchantWalletPaymentInfo =>
      'Muyu will charge the financing to this number. You will confirm the payment in your app.';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordNewTitle => 'New password';

  @override
  String get passwordRulesTitle => 'Suggested requirements';

  @override
  String get passwordRuleLength => '8 or more characters';

  @override
  String get passwordRuleNumber => 'At least one number';

  @override
  String get passwordRuleUppercase => 'At least one uppercase letter';

  @override
  String get passwordConfirmationHint => 'The confirmation must match the new password exactly.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get passwordHeroDescription => 'Muyu character next to a password form';

  @override
  String get passwordBackProfile => 'Back to profile';

  @override
  String get passwordFlowCompleteTitle => 'Ready to continue';

  @override
  String get passwordFlowCompleteBody =>
      'You completed the password flow preview. Your current password has not changed.';

  @override
  String get passwordChangeFailed => 'Could not change the password. Try again.';

  @override
  String get legalUpdated => 'Last updated: October 10, 2026';

  @override
  String get legalUnderstood => 'Understood';

  @override
  String get navHome => 'Home';

  @override
  String get navPlot => 'Plot';

  @override
  String get navSync => 'Sync';

  @override
  String get roleFarmerShort => 'Farmer';

  @override
  String get farmerStatPlots => 'No. of\nplots';

  @override
  String get farmerStatMilestones => 'Milestones\ncompleted';

  @override
  String get farmerStatCrop => 'Active\ncrop';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileSync => 'SYNC';

  @override
  String get profileSyncWifi => 'Sync evidence over Wi-Fi only';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionNo => 'No';

  @override
  String get profileBankAccount => 'Bank account';

  @override
  String get profileBankAccountBody => 'Set up where you receive your disbursements';

  @override
  String get profileChangePin => 'Change PIN';

  @override
  String get profileCallSupport => 'Call technical support';

  @override
  String get profileSupportPhone => '967990437';

  @override
  String get profileReportIssue => 'Report an issue';

  @override
  String get profileRateContract => 'Rate a completed contract';

  @override
  String get yapePrimary => 'Use Yape as the default wallet';

  @override
  String get plinPrimary => 'Use Plin as the default wallet';

  @override
  String get yapeDisbursementInfo => 'Disbursements will be sent to the linked number.';

  @override
  String get plinNotLinked => 'Not linked';

  @override
  String get bankAccountTitle => 'Bank account';

  @override
  String get bankAccountBack => 'Back to profile';

  @override
  String get bankAccountDebitLabel => 'DEBIT';

  @override
  String get bankAccountCreditLabel => 'CREDIT';

  @override
  String bankAccountExpirationValue(String date) {
    return 'Expires $date';
  }

  @override
  String get bankAccountCvvMasked => 'CVV •••';

  @override
  String bankAccountBalance(String amount) {
    return 'Balance $amount';
  }

  @override
  String get bankAccountAddCard => 'Add new card';

  @override
  String get bankAccountReplaceCard => 'Replace card';

  @override
  String get bankAccountDetails => 'Account details';

  @override
  String get bankAccountDigitalWallets => 'Digital wallets';

  @override
  String get bankAccountNoCardTitle => 'No card registered';

  @override
  String get bankAccountNoCardBody => 'Add a debit or credit card to receive your disbursements.';

  @override
  String get bankAccountNoDetails => 'Register a card to see where your payments arrive.';

  @override
  String get bankAccountHolderLabel => 'Holder';

  @override
  String get bankAccountCardLabel => 'Card';

  @override
  String bankAccountYapeLinkedValue(String phone) {
    return 'Linked to $phone';
  }

  @override
  String bankAccountYapeLinkedDefaultValue(String phone) {
    return 'Linked to $phone · Default account';
  }

  @override
  String get bankAccountWalletLimitNote =>
      'Yape and Plin move up to S/ 500 per transfer. Larger disbursements go to your card account.';

  @override
  String get changePinTitle => 'New security PIN';

  @override
  String get changePinConfirmTitle => 'Confirm PIN';

  @override
  String get changePinHeading => 'Enter your new 4-digit PIN';

  @override
  String get changePinConfirmHeading => 'Enter the same PIN again';

  @override
  String get changePinContinue => 'Continue';

  @override
  String get changePinConfirm => 'Confirm PIN';

  @override
  String get changePinEdit => 'Edit PIN';

  @override
  String get changePinCancel => 'Cancel';

  @override
  String get changePinMismatch => 'The PINs do not match. Please try again.';

  @override
  String changePinDigitLabel(int index) {
    return 'PIN digit $index of 4';
  }

  @override
  String get changePinDemoNotice => 'Flow preview. Your current PIN will not be changed.';

  @override
  String get changePinCompleteTitle => 'PIN preview complete';

  @override
  String get changePinCompleteBody =>
      'You have completed the PIN change preview. Your current PIN has not been changed.';

  @override
  String get reportTitle => 'Report an issue';

  @override
  String get reportNoConnection => 'No Connection';

  @override
  String get reportOfflineBody =>
      'If you have no signal, the report will be sent automatically when the connection returns.';

  @override
  String get reportTypeLabel => 'Issue type';

  @override
  String get reportTypeTechnical => 'Technical issue';

  @override
  String get reportTypePayment => 'Payment issue';

  @override
  String get reportTypePlot => 'Plot or harvest';

  @override
  String get reportTypeOther => 'Other';

  @override
  String get reportDescriptionLabel => 'Description';

  @override
  String get reportDescriptionHint => 'Describe what happened and when';

  @override
  String get reportAttachPhoto => 'Attach photo (optional)';

  @override
  String get reportPhotoAttached => 'Photo attached';

  @override
  String get reportSend => 'Send report';

  @override
  String get ratingTitle => 'Rate the buyer';

  @override
  String get ratingSection => 'Rate';

  @override
  String get ratingCycleDate => '15 Feb 2027';

  @override
  String ratingContractEnded(String date) {
    return 'Contract ended · $date';
  }

  @override
  String get ratingPreviewBuyer => 'Valeria Mendoza';

  @override
  String get ratingPreviewCompany => 'Distribuidora La Cosecha';

  @override
  String get ratingPreviewPlot => 'Esperanza';

  @override
  String ratingBuyer(String name) {
    return 'Buyer: $name';
  }

  @override
  String get ratingQuestion => 'How would you rate the experience?';

  @override
  String ratingSelected(int score) {
    return 'Your rating: $score of 5';
  }

  @override
  String get ratingCommentTitle => 'Comment (optional)';

  @override
  String get ratingCommentHint => 'Write a comment about your experience...';

  @override
  String get ratingSubmit => 'Submit rating';

  @override
  String ratingStarDescription(int score) {
    return '$score out of 5 stars';
  }

  @override
  String get ratingPreviewNotice => 'Preview only. This rating is not sent to the server.';

  @override
  String get ratingSubmittedTitle => 'Rating submitted';

  @override
  String ratingLaterStage(String date) {
    return 'Later stage · $date · Cycle ended';
  }

  @override
  String get ratingThanks => 'Thank you for your rating';

  @override
  String ratingThanksBody(String name) {
    return 'Your rating of $name was submitted.';
  }

  @override
  String ratingSubmittedValue(int score) {
    return 'Rating submitted: $score of 5';
  }

  @override
  String ratingSubmittedBy(String farmer, String buyer, String company) {
    return 'Submitted by $farmer to $buyer of $company.';
  }

  @override
  String get ratingNoComment => 'No additional comment.';

  @override
  String get ratingBackProfile => 'Back to profile';

  @override
  String get ratingFarmerPreview => 'Miguel Quispe';

  @override
  String profileRolePlace(String role, String place) {
    return '$role · $place';
  }
}
