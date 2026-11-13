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
  String get onboardingPlotTitle => 'List your plot';

  @override
  String get onboardingPlotBody =>
      'Register your plots and crops to get funding from verified traders.';

  @override
  String get onboardingPlotImage => 'A new crop growing from a plot';

  @override
  String get onboardingEscrowTitle => 'Escrow financing';

  @override
  String get onboardingEscrowBody =>
      'Funds held in Escrow; released when each milestone is approved.';

  @override
  String get onboardingEscrowImage => 'A padlock representing protected funds';

  @override
  String get onboardingWeatherTitle => 'Free weather alerts';

  @override
  String get onboardingWeatherBody =>
      'Get frost, heavy rain and drought alerts to protect your crop.';

  @override
  String get onboardingWeatherImage => 'Sun and cloud representing weather alerts';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingBack => 'Back to role selection';

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
  String get plotsFilterApproved => 'Approved';

  @override
  String get plotsFilterPending => 'Pending';

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
  String get plotCurrentStage => 'Current stage:';

  @override
  String plotProgressComplete(int progress) {
    return '$progress% complete';
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
  String get merchantNoFunded => 'You have not funded any plots yet';

  @override
  String merchantActiveFundedPlots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count funded plots',
      one: '1 funded plot',
    );
    return '$_temp0';
  }

  @override
  String get merchantRainRiskTitle => 'Moderate rain risk';

  @override
  String merchantRainRiskBody(int count) {
    return '$count plot in Cusco needs monitoring';
  }

  @override
  String merchantRainRiskBodyPlural(int count) {
    return '$count plots in Cusco need monitoring';
  }

  @override
  String get merchantRainRiskTemp => '18°C';

  @override
  String get merchantShowReviewFirst => 'Show plots needing review first';

  @override
  String merchantMilestonesFraction(int approved, int total) {
    return 'Milestones: $approved/$total';
  }

  @override
  String get merchantInProgress => 'In progress';

  @override
  String get merchantStatusFundedChip => 'Funded';

  @override
  String get merchantNeedsYourReview => 'Needs your review';

  @override
  String get merchantCurrentMilestone => 'Current milestone:';

  @override
  String get merchantNextMilestone => 'Next:';

  @override
  String get merchantPlotDetails => 'Plot details';

  @override
  String get merchantAvailable => 'Available';

  @override
  String get merchantFinancialStatus => 'Financial status';

  @override
  String get merchantEscrowDeposit => 'Escrow deposit';

  @override
  String get merchantFundingDate => 'Funding date';

  @override
  String get merchantFundsReleased => 'Funds released';

  @override
  String get merchantEscrowBalance => 'Escrow balance';

  @override
  String merchantApprovedProgress(int approved, int total, int percent) {
    return 'Approved milestones: $approved/$total · $percent %';
  }

  @override
  String get merchantCropDetails => 'Crop details';

  @override
  String get merchantCropLabel => 'Crop';

  @override
  String get merchantAreaLabel => 'Area';

  @override
  String get merchantHarvestLabel => 'Estimated harvest';

  @override
  String get merchantPaymentPerMilestone => 'Payment per milestone';

  @override
  String merchantFarmerFunder(String farmer, String funder, String company) {
    return 'Farmer: $farmer · Funder: $funder ($company)';
  }

  @override
  String merchantContactFarmer(String name) {
    return 'Contact $name';
  }

  @override
  String get merchantFundPlot => 'Fund this plot';

  @override
  String get merchantFundTitle => 'Fund plot';

  @override
  String get merchantTotalInvestment => 'TOTAL INVESTMENT';

  @override
  String get merchantListedAmount => 'Amount listed by the farmer';

  @override
  String get merchantFixedAmount => 'Fixed amount';

  @override
  String get merchantDisbursement => 'DISBURSEMENT PLAN';

  @override
  String get merchantEscrowHow => 'HOW ESCROW PROTECTS YOU';

  @override
  String get merchantEscrowSafe => 'Your funds stay safe';

  @override
  String get merchantEscrowApprove => 'You approve each proof';

  @override
  String get merchantEscrowHarvest => 'You receive your harvest';

  @override
  String get merchantPaymentMethodTitle => 'PAYMENT METHOD';

  @override
  String get merchantPayCard => 'Card';

  @override
  String get merchantPayWallet => 'Wallet';

  @override
  String get merchantPayAgent => 'Agent deposit';

  @override
  String get merchantPayBank => 'Bank transfer';

  @override
  String get merchantFundTerms =>
      'I have read and accept the terms of the escrow financing agreement';

  @override
  String get merchantAcceptFirst => 'Accept the terms first';

  @override
  String get merchantContinue => 'Continue';

  @override
  String merchantConfirmAndPay(String amount) {
    return 'Confirm and pay $amount';
  }

  @override
  String get merchantFinancingConfirmed => 'Financing confirmed';

  @override
  String merchantFinancingConfirmedBody(String name, String method) {
    return '$name is funded by $method and the funds are held in escrow.';
  }

  @override
  String get merchantBackToMyPlots => 'Back to my plots';

  @override
  String get merchantPayFailed => 'The payment could not be registered.';

  @override
  String get merchantFundSuccessTitle => 'Payment confirmed';

  @override
  String get merchantFundsSecured => 'Funds secured in Escrow';

  @override
  String merchantSuccessBody(String plot, String farmer) {
    return '$plot is now financed.\n$farmer has received a confirmation.';
  }

  @override
  String get merchantAmountFunded => 'Amount funded';

  @override
  String get merchantPaymentMethodLabel => 'Payment method';

  @override
  String get merchantReceiptStatus => 'Status';

  @override
  String get merchantHeldInEscrow => 'Funds held in Escrow';

  @override
  String get merchantReceiptDate => 'Date';

  @override
  String get merchantReleaseNote =>
      'Payments will be released to the farmer as you approve each milestone.';

  @override
  String get merchantViewFinancedPlot => 'View financed plot';

  @override
  String get merchantDownloadReceipt => 'Download receipt';

  @override
  String merchantReceiptSaved(String path) {
    return 'Receipt saved to $path';
  }

  @override
  String get merchantReceiptSaveFailed => 'The receipt could not be saved.';

  @override
  String get muyuContactMissing => 'No valid contact email is available.';

  @override
  String get muyuContactUnavailable => 'No email app could be opened.';

  @override
  String get merchantVisitRequestTitle => 'Request visit';

  @override
  String get merchantVisitStatusTitle => 'Visit request';

  @override
  String get merchantVisitProposedDate => 'PROPOSED DATE';

  @override
  String get merchantVisitPreferredTime => 'PREFERRED TIME';

  @override
  String get merchantVisitMessage => 'Message to farmer (optional)';

  @override
  String get merchantVisitMessageHint => 'I’d like to review the irrigation system';

  @override
  String get merchantVisitDisclaimer =>
      'Requesting a visit does not reserve or fund the plot. The farmer will record whether an agreement was reached.';

  @override
  String get merchantVisitSending => 'Sending…';

  @override
  String merchantVisitSendError(String error) {
    return 'Could not send the visit request: $error';
  }

  @override
  String get merchantVisitSend => 'Send request';

  @override
  String get merchantVisitSent => 'Request sent';

  @override
  String merchantVisitSentBody(String name) {
    return '$name received your visit proposal.';
  }

  @override
  String merchantVisitToPlot(String name) {
    return 'Visit to $name';
  }

  @override
  String get merchantVisitDate => 'Date';

  @override
  String get merchantVisitTime => 'Time';

  @override
  String get merchantVisitPlace => 'Place';

  @override
  String get merchantVisitCoordinationOnly =>
      'Visit coordination only. It does not reserve or fund the plot. No charges or Escrow deposit.';

  @override
  String get merchantVisitBackPlot => 'Back to plot';

  @override
  String get merchantVisitConfirmed => 'Visit confirmed';

  @override
  String merchantVisitConfirmedBody(String name) {
    return '$name accepted your visit proposal.';
  }

  @override
  String get merchantVisitMeetingPoint => 'Meeting point';

  @override
  String get merchantVisitMeetingHint =>
      'Entrance to the plot near the main road. Coordinate with the farmer before arriving.';

  @override
  String get merchantViewEvidence => 'View evidence';

  @override
  String get merchantVisitRequestButton => 'Request visit';

  @override
  String get merchantHarvestReceiptPending => 'Harvest receipt · Pending';

  @override
  String get merchantExactLocation => 'Exact location';

  @override
  String get merchantFarmerStats => '12 years of experience · 8 plots completed';

  @override
  String get merchantApprovalRate => '94% approval rate';

  @override
  String merchantMilestoneApprovedLine(String date, String amount) {
    return '$date · Approved $amount';
  }

  @override
  String merchantMilestoneAwaitingLine(String date, String time, String amount) {
    return '$date · $time · Awaiting review · $amount';
  }

  @override
  String merchantMilestonePendingLine(String date, String amount) {
    return '$date · Pending $amount';
  }

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
  String get profileChangePhoto => 'Change photo';

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
  String get profileNewPlotAlerts => 'New plot alerts';

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
  String get ratingNoContracts => 'You have no finished contracts to rate yet.';

  @override
  String get reportUnavailable =>
      'Reports cannot be sent from the app yet. Call technical support and we will help you.';

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
  String get reportSendRequest => 'Send request';

  @override
  String get ratingTitle => 'Rate the buyer';

  @override
  String get ratingSection => 'Rate';

  @override
  String ratingContractEnded(String date) {
    return 'Contract ended · $date';
  }

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
  String get ratingPreviewNotice => 'Your rating is not saved on the server yet.';

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
  String profileRolePlace(String role, String place) {
    return '$role · $place';
  }

  @override
  String get paymentsTitle => 'Payment history';

  @override
  String get paymentsTotalReceived => 'TOTAL RECEIVED';

  @override
  String get paymentsTotalReleased => 'TOTAL RELEASED';

  @override
  String paymentsCompletedCount(int count) {
    return '$count completed payments';
  }

  @override
  String get paymentsEmptyTitle => 'No payments yet';

  @override
  String get paymentsEmptyBody =>
      'Payments appear here when evidence for a financed milestone is approved.';

  @override
  String get paymentsFilterAll => 'All';

  @override
  String get paymentsFilterCompleted => 'Completed';

  @override
  String get paymentsFilterPending => 'Pending';

  @override
  String get paymentDetailsTitle => 'Payment details';

  @override
  String get paymentTransactionDetails => 'TRANSACTION DETAILS';

  @override
  String get paymentLabelMilestone => 'Milestone';

  @override
  String get paymentLabelPlot => 'Plot';

  @override
  String get paymentLabelDate => 'Release date';

  @override
  String get paymentLabelAccount => 'Destination account';

  @override
  String get paymentLabelTxid => 'Transaction ID';

  @override
  String get paymentLabelAmount => 'Amount';

  @override
  String get paymentPendingDate => 'Awaiting approval';

  @override
  String get paymentEscrowExplanation =>
      'Funds are released only after the merchant approves the milestone evidence.';

  @override
  String get paymentMilestonePlanting => 'Planting';

  @override
  String get paymentMilestoneIrrigation => 'Irrigation';

  @override
  String get paymentMilestoneFertilization => 'Fertilization';

  @override
  String get paymentMilestoneHarvest => 'Harvest';

  @override
  String get weatherTitle => 'Weather alert';

  @override
  String get weatherLoading => 'Checking the weather for your plot…';

  @override
  String get weatherUnavailable => 'Weather is unavailable for this plot right now.';

  @override
  String get weatherStable => 'Stable conditions';

  @override
  String get weatherHeavyRain => 'Heavy rain expected';

  @override
  String get weatherModerateRain => 'Moderate rain expected';

  @override
  String get weatherFrost => 'Frost risk';

  @override
  String get weatherEstTemp => 'Now';

  @override
  String get weatherEstTime => 'Estimated time';

  @override
  String get weatherTonight => 'Tonight';

  @override
  String get weatherToday => 'Today';

  @override
  String get weatherForecast => '5-day forecast';

  @override
  String weatherCycle(String year) {
    return 'Cycle $year';
  }

  @override
  String get weatherRisk => 'Risk level';

  @override
  String get weatherRiskHigh => 'High';

  @override
  String get weatherRiskMedium => 'Medium';

  @override
  String get weatherRiskLow => 'Low';

  @override
  String get weatherRecommendations => 'Recommended measures';

  @override
  String get weatherMeasureDrainage => 'Check drainage and field access';

  @override
  String get weatherMeasureCover => 'Protect sensitive crops';

  @override
  String get weatherMeasureIrrigation => 'Adjust irrigation to the forecast';

  @override
  String get weatherMeasureMonitor => 'Monitor crop moisture and stress';

  @override
  String get weatherMeasuresPending => 'Pending attention';

  @override
  String get weatherMeasuresDone => 'Measures recorded';

  @override
  String get weatherMeasuresHint => 'Select the actions you took to protect your crop.';

  @override
  String get weatherMeasuresConfirm => 'Save measures taken';

  @override
  String get weatherMeasuresRequired => 'Select at least one measure.';

  @override
  String get merchantAlertsTitle => 'Alerts';

  @override
  String get merchantAlertsEmpty =>
      'When farmers send evidence or request extensions on your financed plots, you will see alerts here.';

  @override
  String get merchantAlertPayment => 'Payment review';

  @override
  String get merchantAlertWeather => 'Weather alert';

  @override
  String merchantAlertWeatherBody(String plot) {
    return 'Heavy rain expected near $plot over the next 24 hours.';
  }

  @override
  String merchantAlertPaymentBody(String farmer, String milestone, String amount) {
    return '$farmer sent $milestone evidence. Review it to release $amount.';
  }

  @override
  String get resetTitle => 'Recover password';

  @override
  String get resetHeading => 'Let\'s get you back into your account';

  @override
  String get resetBody => 'Enter your email and we will show you the next recovery step.';

  @override
  String get resetEmailPrompt => 'Account email';

  @override
  String get resetNext => 'Continue';

  @override
  String get resetInvalidEmail => 'Enter a valid email address.';

  @override
  String get resetSentTitle => 'Check your email';

  @override
  String resetSentBody(String email) {
    return 'If an account exists for $email, you will receive recovery instructions.';
  }

  @override
  String get resetDemoNotice => 'Recovery preview: the server does not yet send reset emails.';

  @override
  String get resetBackLogin => 'Back to sign in';

  @override
  String get loginForgotPassword => 'Forgot your password?';
}
