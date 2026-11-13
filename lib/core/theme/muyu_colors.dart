import 'package:flutter/material.dart';

/// Muyu palette: the Figma design tokens, plus colors from `ui/theme/Color.kt`
/// that have no token yet. Add colors here as more screens are ported.
abstract final class MuyuColors {
  static const background = Color(0xFFEAFAE9);
  static const forest = Color(0xFF213D09);
  static const field = Color(0xFFFFFEFE);
  static const lime = Color(0xFF8FDA51);
  static const olive = Color(0xFF3F7B00);
  static const skip = Color(0xFFCBF5B8);
  static const action = Color(0xFF4A7C1E);
  static const header = Color(0xFF477B1C);
  static const navBar = Color(0xFF0F3F0D);
  static const navSelected = Color(0xFF3E661F);
  static const surface = Color(0xFFFBFBFB);
  static const weatherChip = Color(0xFF92C7C1);
  static const weatherCard = Color(0xFFECF4FF);
  static const statCard = Color(0xFFDFFFC4);
  static const farmerPaymentsHero = Color(0xFFC4ECA8);
  static const farmerPaymentsMuted = Color(0xFF4F7A3A);
  static const merchantPaymentsHero = Color(0xFF454388);
  static const merchantPaymentsPage = Color(0xFFDDF3DC);
  static const escrowNote = Color(0xFFD6E9F8);
  static const paymentCompletedHero = Color(0xFFC8E6C9);
  static const paymentCompletedText = Color(0xFF2E6930);
  static const financedBackground = Color(0xFFC8DBFF);
  static const financedText = Color(0xFF244398);
  static const approvedBg = Color(0xFFB8DF98);
  static const pendingBackground = Color(0xFFFED2BD);
  static const pendingText = Color(0xFF774308);
  static const homeFundedPanel = Color(0xFF362216);
  static const homeFundedTrack = Color(0xFF70442A);
  static const homeApprovedPanel = Color(0xFF626E23);
  static const homeApprovedTrack = Color(0xFFBFCE6C);
  static const homePendingPanel = Color(0xFF765B2F);
  static const homePendingTrack = Color(0xFFA0814F);
  static const offlineBackground = Color(0xFFFFF3E0);
  static const offlineText = Color(0xFF9A5B00);
  static const dangerBackground = Color(0xFFFFD9D9);
  static const dangerMessage = Color(0xFF9E2F2F);
  static const textSecondary = Color(0xFF555555);
  static const nearText = Color(0xFF579226);
  static const mutedFooter = Color(0xFF5F675F);
  static const pageGray = Color(0xFFF2F2F2);
  static const verifiedChipBg = Color(0xFFFEF7FF);
  static const verifiedChipText = Color(0xFF4F378A);
  static const logoutRed = Color(0xFFB84444);
  static const checkbox = Color(0xFFD9D9D9);
  static const grayChip = Color(0xE6D9D9D9);
  static const cardOutline = Color(0xFFCAC4D0);
  static const onSurface = Color(0xFF1D1B20);
  static const weatherBannerStart = Color(0xFF162A50);
  static const weatherBannerEnd = Color(0xFF524FA0);
  static const termsBg = Color(0xFFF1F1F1);
  static const secondaryText = Color(0xFF4F5A50);
  static const fundBanner = Color(0xFF57802A);
  static const escrowInfo = Color(0xFFBCD6F3);
  static const escrowStep = Color(0xFF829AC1);
  static const receiptGreen = Color(0xFF174E16);
  static const infoBlue = Color(0xFF496A88);

  static const errorBorder = Color(0xFFE5484D);
  static const errorText = Color(0xFFFFC7C7);
}

/// Spacing tokens from Figma (Muyu - Spacing).
abstract final class MuyuSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s24 = 24;
  static const double s48 = 48;
}
