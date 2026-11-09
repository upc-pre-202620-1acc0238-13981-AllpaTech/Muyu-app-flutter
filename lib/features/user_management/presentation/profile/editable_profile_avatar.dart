import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/designsystem/components/farmer_avatar.dart';
import '../../../../core/theme/muyu_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/session_controller.dart';

const _cameraGreen = Color(0xFF2E7D32);
const _initialsBg = Color(0xFF618840);

/// Profile photo with a camera badge, matching Kotlin `EditableProfileAvatar`.
class EditableProfileAvatar extends ConsumerWidget {
  const EditableProfileAvatar({super.key, required this.name, required this.size});

  final String name;
  final double size;

  Future<void> _pick(WidgetRef ref) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final docs = await getApplicationDocumentsDirectory();
    final safeEmail = user.email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final dest = File('${docs.path}/muyu_avatar_$safeEmail.jpg');
    await File(picked.path).copy(dest.path);
    await ref.read(sessionProvider.notifier).updateAvatar(dest.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final avatarUri = ref.watch(sessionProvider).user?.avatarUri ?? '';
    final photo = File(avatarUri);
    final hasPhoto = avatarUri.isNotEmpty && photo.existsSync();

    return Semantics(
      button: true,
      label: l10n.profileChangePhoto,
      child: GestureDetector(
        onTap: () => _pick(ref),
        child: SizedBox(
          width: size + 6,
          height: size + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _initialsBg,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: hasPhoto
                    ? Image.file(
                        photo,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        semanticLabel: name,
                        errorBuilder: (_, _, _) => _Initials(name: name, size: size),
                      )
                    : _Initials(name: name, size: size),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cameraGreen,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.photo_camera_outlined, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      initialsOf(name),
      style: TextStyle(
        fontFamily: MuyuFonts.urbanist,
        fontWeight: FontWeight.w700,
        fontSize: size * 0.36,
        color: Colors.white,
        height: 1,
      ),
    );
  }
}
