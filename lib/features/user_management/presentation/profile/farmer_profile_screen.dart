import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/designsystem/components/farmer_bottom_bar.dart';
import '../../../../core/storage/user_preferences.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';
import '../../domain/registration_validator.dart';
import '../incident/report_incident_screen.dart';
import '../legal/legal_document_screen.dart';
import '../password/change_password_screen.dart';
import '../pin/change_pin_screen.dart';
import '../rating/rate_buyer_screen.dart';
import 'bank_account_screen.dart';
import 'editable_profile_avatar.dart';

enum _AlertChannel { call, push, whatsapp }

const _cardRadius = 20.0;
const _darkGreen = Color(0xFF2E6930);
const _verifiedBg = Color(0xFFDCF0DD);
const _logoutRed = Color(0xFFC63939);

class FarmerProfileScreen extends ConsumerStatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  ConsumerState<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends ConsumerState<FarmerProfileScreen> {
  late final TextEditingController _phone;
  late final TextEditingController _email;
  var _editingContact = false;
  String? _phoneError;
  String? _emailError;
  var _syncWifiOnly = true;
  _AlertChannel _channel = _AlertChannel.call;
  String _emailKey = '';

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController();
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
    _phone.text = localPhoneDigits(
      prefs.loadString(email, UserPreferences.keyContactPhone) ?? user?.phone ?? '',
    );
    _email.text = user?.email ?? '';
    _channel = _AlertChannel.values.firstWhere(
      (value) => value.name == prefs.loadString(email, UserPreferences.keyAlertChannel),
      orElse: () => _AlertChannel.call,
    );
    _syncWifiOnly = prefs.loadBool(email, UserPreferences.keySyncWifiOnly) ?? true;
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) {
    return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _saveContact() async {
    final l10n = AppLocalizations.of(context);
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final phoneError = RegistrationValidator.isValidPhone(phone) ? null : l10n.registerPhoneInvalid;
    final emailError = RegistrationValidator.isValidContactEmail(email)
        ? null
        : l10n.registerEmailInvalid;
    if (phoneError != null || emailError != null) {
      setState(() {
        _phoneError = phoneError;
        _emailError = emailError;
      });
      return;
    }
    await ref.read(sessionProvider.notifier).updateContact(phone: phone);
    if (mounted) {
      setState(() {
        _editingContact = false;
        _phoneError = null;
        _emailError = null;
      });
    }
  }

  Future<void> _selectChannel(_AlertChannel channel) async {
    setState(() => _channel = channel);
    if (_emailKey.isEmpty) return;
    await ref
        .read(userPreferencesProvider)
        .saveString(_emailKey, UserPreferences.keyAlertChannel, channel.name);
  }

  Future<void> _toggleSync() async {
    final next = !_syncWifiOnly;
    setState(() => _syncWifiOnly = next);
    if (_emailKey.isEmpty) return;
    await ref
        .read(userPreferencesProvider)
        .saveBool(_emailKey, UserPreferences.keySyncWifiOnly, next);
  }

  Future<void> _callSupport() async {
    final phone = AppLocalizations.of(context).profileSupportPhone;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).user;
    final name = (user?.displayName.trim().isNotEmpty ?? false) ? user!.displayName : l10n.appName;

    return ColoredBox(
      color: MuyuColors.background,
      child: Column(
        children: [
          _Header(name: name, subtitle: l10n.roleFarmerShort),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, farmerScrollBottomInset),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(number: '0', label: l10n.farmerStatPlots),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(number: '0', label: l10n.farmerStatMilestones),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(number: '0', label: l10n.farmerStatCrop),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profileContactDetails),
                _Card(child: _editingContact ? _contactEditor(l10n) : _contactPreview(l10n)),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profileNotificationPrefs),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileWeatherAlertsQuestion,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Chip(
                              label: l10n.profileChannelCall,
                              selected: _channel == _AlertChannel.call,
                              onTap: () => _selectChannel(_AlertChannel.call),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _Chip(
                              label: l10n.profileChannelPush,
                              selected: _channel == _AlertChannel.push,
                              onTap: () => _selectChannel(_AlertChannel.push),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _Chip(
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
                const SizedBox(height: 20),
                _SectionTitle(l10n.profileSync),
                _Card(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.profileSyncWifi,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Material(
                        color: _syncWifiOnly ? _darkGreen : Colors.grey[400],
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _toggleSync,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              _syncWifiOnly ? l10n.actionYes : l10n.actionNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.profilePayment),
                _Card(
                  onTap: () => _open(const BankAccountScreen()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileBankAccount,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.profileBankAccountBody,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Card(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _NavRow(
                        label: l10n.profileChangePassword,
                        onTap: () => _open(const ChangePasswordScreen()),
                      ),
                      const Divider(height: 1),
                      _NavRow(
                        label: l10n.profileChangePin,
                        onTap: () => _open(const ChangePinScreen()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _OutlinedAction(label: l10n.profileCallSupport, onTap: _callSupport),
                const SizedBox(height: 12),
                _OutlinedAction(
                  label: l10n.profileReportIssue,
                  onTap: () => _open(const ReportIncidentScreen()),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => _open(const RateBuyerScreen()),
                    child: Text(
                      l10n.profileRateContract,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: _darkGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
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
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () => ref.read(sessionProvider.notifier).logout(),
                    style: FilledButton.styleFrom(
                      backgroundColor: _logoutRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_cardRadius),
                      ),
                    ),
                    child: Text(
                      l10n.profileLogout,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
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
    final phone = formatProfilePhone(_phone.text);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                phone.isEmpty ? l10n.profilePhoneLabel : phone,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(_email.text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: _editDecoration(
            l10n.profilePhoneLabel,
            prefix: '+51 ',
            errorText: _phoneError,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _email,
          readOnly: true,
          enableInteractiveSelection: false,
          keyboardType: TextInputType.emailAddress,
          decoration: _editDecoration(l10n.profileEmailLabel, errorText: _emailError),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton(
              onPressed: () {
                final user = ref.read(sessionProvider).user;
                setState(() {
                  _phone.text = localPhoneDigits(user?.phone ?? '');
                  _email.text = user?.email ?? '';
                  _phoneError = null;
                  _emailError = null;
                  _editingContact = false;
                });
              },
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

  InputDecoration _editDecoration(String hint, {String? prefix, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      errorText: errorText,
      isDense: true,
      filled: true,
      fillColor: MuyuColors.pageGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.subtitle});

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
          padding: const EdgeInsets.fromLTRB(27, 16, 27, 24),
          child: Row(
            children: [
              EditableProfileAvatar(name: name, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: MuyuFonts.urbanist,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _verifiedBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.profileVerified,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _darkGreen,
                        ),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF616161)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(color: _darkGreen.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _darkGreen : const Color(0xFFE0E0E0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkGreen,
          side: const BorderSide(color: _darkGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
          backgroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: MuyuFonts.urbanist,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        child: Text(label),
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
      child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }
}

String localPhoneDigits(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('51') && digits.length > 9) digits = digits.substring(2);
  return digits.length <= 9 ? digits : digits.substring(digits.length - 9);
}

String formatProfilePhone(String phone) {
  final digits = localPhoneDigits(phone);
  if (digits.isEmpty) return '';
  return '+51 $digits';
}
