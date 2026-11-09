import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/designsystem/components/green_title_header.dart';
import '../../../../core/theme/muyu_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';

/// A finished contract the farmer can rate.
class RatingContract {
  const RatingContract({
    required this.plotName,
    required this.buyerName,
    required this.companyName,
    required this.endedOn,
  });

  final String plotName;
  final String buyerName;
  final String companyName;
  final String endedOn;
}

class RateBuyerScreen extends ConsumerStatefulWidget {
  const RateBuyerScreen({super.key, this.contract});

  /// Null until the backend provides finished contracts.
  final RatingContract? contract;

  @override
  ConsumerState<RateBuyerScreen> createState() => _RateBuyerScreenState();
}

class _RateBuyerScreenState extends ConsumerState<RateBuyerScreen> {
  final _comment = TextEditingController();
  var _rating = 0;
  var _submitted = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contract = widget.contract;
    if (contract == null) return const _NoContractToRate();
    if (_submitted) {
      return _RatingSubmitted(
        contract: contract,
        rating: _rating,
        comment: _comment.text.trim(),
        farmerName: ref.watch(sessionProvider).user?.displayName.trim() ?? '',
        onBack: () => Navigator.of(context).pop(),
      );
    }

    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.ratingTitle, onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.ratingSection,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.ratingContractEnded(contract.endedOn),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  contract.plotName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(
                  l10n.ratingBuyer(contract.buyerName),
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(contract.companyName, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 16),
                Text(
                  l10n.ratingQuestion,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _Stars(value: _rating, onSelect: (value) => setState(() => _rating = value)),
                if (_rating > 0)
                  Text(
                    l10n.ratingSelected(_rating),
                    style: const TextStyle(fontSize: 12, color: MuyuColors.olive),
                  ),
                const SizedBox(height: 16),
                Text(
                  l10n.ratingCommentTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _comment,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: l10n.ratingCommentHint,
                    filled: true,
                    fillColor: MuyuColors.pageGray,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFB8C7B9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: MuyuColors.action),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _rating >= 1 && _rating <= 5
                        ? () => setState(() => _submitted = true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: MuyuColors.action,
                      disabledBackgroundColor: const Color(0xFFB8C7B9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      l10n.ratingSubmit,
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
}

class _NoContractToRate extends StatelessWidget {
  const _NoContractToRate();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.ratingTitle, onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  l10n.ratingNoContracts,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: MuyuColors.forest),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSubmitted extends StatelessWidget {
  const _RatingSubmitted({
    required this.contract,
    required this.rating,
    required this.comment,
    required this.farmerName,
    required this.onBack,
  });

  final RatingContract contract;
  final int rating;
  final String comment;
  final String farmerName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MuyuColors.background,
      body: Column(
        children: [
          GreenTitleHeader(title: l10n.ratingSubmittedTitle, onBack: onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: MuyuColors.lime.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.ratingLaterStage(contract.endedOn),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF854500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: MuyuColors.approvedBg,
                        child: const Icon(
                          Icons.check_circle_outline,
                          size: 32,
                          color: MuyuColors.forest,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.ratingThanks,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: MuyuColors.forest,
                        ),
                      ),
                      Text(
                        l10n.ratingThanksBody(contract.buyerName),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      _Stars(value: rating),
                      Text(
                        l10n.ratingSubmittedValue(rating),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: MuyuColors.forest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n.ratingSubmittedBy(farmerName, contract.buyerName, contract.companyName)} ${comment.isEmpty ? l10n.ratingNoComment : comment}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ratingPreviewNotice,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: MuyuColors.forest,
                  side: const BorderSide(color: MuyuColors.forest),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  l10n.ratingBackProfile,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, this.onSelect});

  final int value;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var score = 1; score <= 5; score++)
          IconButton(
            tooltip: l10n.ratingStarDescription(score),
            onPressed: onSelect == null ? null : () => onSelect!(score),
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: score <= value ? MuyuColors.action : const Color(0xFFD5DDD8),
              child: Icon(
                Icons.star_border,
                color: score <= value ? Colors.white : const Color(0xFF53605A),
              ),
            ),
          ),
      ],
    );
  }
}
