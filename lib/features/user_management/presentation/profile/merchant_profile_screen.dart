import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/merchant_bottom_bar.dart';
import '../../../../core/storage/user_preferences.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/merchant_payment_controller.dart';
import '../../application/session_controller.dart';
import '../../domain/bank_card.dart';
import '../../domain/merchant_wallet.dart';
import '../legal/legal_document_screen.dart';
import '../password/change_password_screen.dart';
import 'add_bank_card_screen.dart';
import 'edit_digital_wallet_screen.dart';
import 'editable_profile_avatar.dart';

enum _AlertChannel { call, push, whatsapp }

/// Merchant profile, matching Figma node 1270:3977 and `MerchantProfileScreen` in Kotlin.
class MerchantProfileScreen extends ConsumerStatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  ConsumerState<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends ConsumerState<MerchantProfileScreen> {
  late final TextEditingController _legalName;
  late final TextEditingController _activity;
  late final TextEditingController _ruc;
  late final TextEditingController _location;
  late final TextEditingController _email;
  _AlertChannel _channel = _AlertChannel.call;
  bool _editingContact = false;
  String _emailKey = '';

  @override
  void initState() {
    super.initState();
    _legalName = TextEditingController();
    _activity = TextEditingController();
    _ruc = TextEditingController();
    _location = TextEditingController();
    _email = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(sessionProvider).user;
    final email = user?.email ?? '';
    if (email == _emailKey) return;
    _emailKey = email;
    final prefs = ref.read(userPreferencesProvider);
    _legalName.text = prefs.loadString(email, UserPreferences.keyCompanyLegalName) ?? '';
    _activity.text = prefs.loadString(email, UserPreferences.keyCompanyActivity) ?? '';
    _ruc.text = prefs.loadString(email, UserPreferences.keyCompanyRuc) ?? '';
    _location.text = prefs.loadString(email, UserPreferences.keyCompanyLocation) ?? '';
    _email.text = user?.email ?? '';
    _channel = _AlertChannel.values.firstWhere(
      (value) => value.name == prefs.loadString(email, UserPreferences.keyAlertChannel),
      orElse: () => _AlertChannel.call,
    );
  }

  @override
  void dispose() {
    _legalName.dispose();
    _activity.dispose();
    _ruc.dispose();
    _location.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    final prefs = ref.read(userPreferencesProvider);
    await prefs.saveString(_emailKey, UserPreferences.keyCompanyLegalName, _legalName.text.trim());
    await prefs.saveString(_emailKey, UserPreferences.keyCompanyActivity, _activity.text.trim());
    await prefs.saveString(_emailKey, UserPreferences.keyCompanyRuc, _ruc.text.trim());
    await prefs.saveString(_emailKey, UserPreferences.keyCompanyLocation, _location.text.trim());
    setState(() => _editingContact = false);
  }

  Future<void> _selectChannel(_AlertChannel channel) async {
    setState(() => _channel = channel);
    if (_emailKey.isEmpty) return;
    await ref
        .read(userPreferencesProvider)
        .saveString(_emailKey, UserPreferences.keyAlertChannel, channel.name);
  }

  Future<void> _open(Widget page) {
    return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    final headerName = (user?.displayName.trim().isNotEmpty ?? false)
        ? user!.displayName
        : (user?.email ?? '');
    final place = _location.text.trim();

    return ColoredBox(
      color: MuyuColors.pageGray,
      child: Column(
        children: [
          _ProfileHeader(
            name: headerName,
            subtitle: place.isEmpty
                ? l10n.roleMerchantShort
                : l10n.profileRolePlace(l10n.roleMerchantShort, place),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(21, 26, 21, merchantScrollBottomInset),
              children: [
                _SectionTitle(l10n.profileContactDetails),
                _ProfileCard(child: _editingContact ? _contactEditor(l10n) : _contactPreview(l10n)),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profileNotificationPrefs),
                _ProfileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.profileWeatherAlertsQuestion, style: _bodyStyle),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _ChannelChip(
                              label: l10n.profileChannelCall,
                              selected: _channel == _AlertChannel.call,
                              onTap: () => _selectChannel(_AlertChannel.call),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ChannelChip(
                              label: l10n.profileChannelPush,
                              selected: _channel == _AlertChannel.push,
                              onTap: () => _selectChannel(_AlertChannel.push),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ChannelChip(
                              label: l10n.profileChannelWhatsapp,
                              selected: _channel == _AlertChannel.whatsapp,
                              onTap: () => _selectChannel(_AlertChannel.whatsapp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ProfileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(l10n.profileNewPlotAlerts, style: _titleStyle)],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profilePayment),
                _PaymentMethodsCard(onOpen: _open),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profileSecurityHelp),
                _ProfileCard(
                  onTap: () => _open(const ChangePasswordScreen()),
                  child: Row(
                    children: [
                      Expanded(child: Text(l10n.profileChangePassword, style: _bodyStyle)),
                      const Icon(Icons.chevron_right, color: Colors.black54, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profileLegal),
                _ProfileCard(
                  radius: 20,
                  borderColor: MuyuColors.forest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegalLink(
                        label: l10n.profileTerms,
                        onTap: () => _open(const TermsAndConditionsScreen()),
                      ),
                      const SizedBox(height: 12),
                      _LegalLink(
                        label: l10n.profilePrivacy,
                        onTap: () => _open(const PrivacyPolicyScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 310,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => ref.read(sessionProvider.notifier).logout(),
                      style: FilledButton.styleFrom(
                        backgroundColor: MuyuColors.logoutRed,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        l10n.profileLogout,
                        style: const TextStyle(
                          fontFamily: MuyuFonts.urbanist,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactPreview(AppLocalizations l10n) {
    final rucLine = '${_activity.text.trim()} · RUC ${_ruc.text.trim()}';
    final locationLine = '${_location.text.trim()} · ${_email.text.trim()}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_legalName.text.trim(), style: _titleStyle),
              const SizedBox(height: 10),
              Text(rucLine, style: _bodyStyle),
              const SizedBox(height: 8),
              Text(locationLine, style: _bodyStyle),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.profileEditContact,
          onPressed: () => setState(() => _editingContact = true),
          icon: const Icon(Icons.edit_outlined, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _contactEditor(AppLocalizations l10n) {
    return Column(
      children: [
        _EditField(controller: _legalName, hint: l10n.profileCompanyNameLabel),
        const SizedBox(height: 10),
        _EditField(controller: _activity, hint: l10n.profileActivityLabel),
        const SizedBox(height: 10),
        _EditField(
          controller: _ruc,
          hint: l10n.profileRucLabel,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        _EditField(controller: _location, hint: l10n.profileLocationLabel),
        const SizedBox(height: 10),
        _EditField(
          controller: _email,
          hint: l10n.profileEmailLabel,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _editingContact = false),
              child: Text(l10n.profileCancel),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saveContact,
              style: FilledButton.styleFrom(backgroundColor: MuyuColors.header),
              child: Text(l10n.profileSaveContact),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: MuyuColors.navBar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Column(
                children: [
                  EditableProfileAvatar(name: name, size: 64),
                  const SizedBox(height: 8),
                  Container(
                    height: 23,
                    padding: const EdgeInsets.fromLTRB(11, 0, 10, 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: MuyuColors.verifiedChipBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.profileVerified,
                      style: const TextStyle(fontSize: 14, color: MuyuColors.verifiedChipText),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 28 / 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodsCard extends ConsumerWidget {
  const _PaymentMethodsCard({required this.onOpen});

  final Future<void> Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payment = ref.watch(merchantPaymentProvider);
    final card = payment.card;
    final wallet = payment.wallet;

    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileSavedMethods, style: _titleStyle),
          const SizedBox(height: 8),
          _PaymentMethodRow(
            label: card == null ? l10n.paymentNoCard : bankCardSummary(card),
            actions: [
              (
                card == null ? l10n.profileRegisterCard : l10n.profileChangeCard,
                () => onOpen(const AddBankCardScreen()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _PaymentMethodRow(
            label: wallet == null ? l10n.profileNoWallet : merchantWalletSummary(wallet),
            actions: wallet == null
                ? [
                    (
                      l10n.bankAccountYape,
                      () => onOpen(
                        const EditDigitalWalletScreen(provider: DigitalWalletProvider.yape),
                      ),
                    ),
                    (
                      l10n.bankAccountPlin,
                      () => onOpen(
                        const EditDigitalWalletScreen(provider: DigitalWalletProvider.plin),
                      ),
                    ),
                  ]
                : [
                    (
                      l10n.profileChangeWallet,
                      () => onOpen(EditDigitalWalletScreen(provider: wallet.provider)),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({required this.label, required this.actions});

  final String label;
  final List<(String, VoidCallback)> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: _bodyStyle)),
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: TextButton(
              onPressed: action.$2,
              style: TextButton.styleFrom(
                foregroundColor: MuyuColors.header,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontFamily: MuyuFonts.urbanist,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              child: Text(action.$1),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.black.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.child,
    this.onTap,
    this.radius = 16,
    this.borderColor = MuyuColors.lime,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), child: child),
      ),
    );
  }
}

class _ChannelChip extends StatelessWidget {
  const _ChannelChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MuyuColors.header : MuyuColors.checkbox,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 36,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MuyuFonts.urbanist,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: selected ? MuyuColors.field : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: MuyuFonts.urbanist,
          fontSize: 16,
          color: MuyuColors.forest,
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enableInteractiveSelection: !readOnly,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: MuyuColors.pageGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

const _titleStyle = TextStyle(
  fontFamily: MuyuFonts.urbanist,
  fontWeight: FontWeight.w600,
  fontSize: 16,
  color: Colors.black,
);

final _bodyStyle = TextStyle(
  fontFamily: MuyuFonts.urbanist,
  fontWeight: FontWeight.w300,
  fontSize: 16,
  color: Colors.black.withValues(alpha: 0.5),
);
