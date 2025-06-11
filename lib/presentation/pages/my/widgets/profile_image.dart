import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cooki/presentation/user_global_view_model.dart';

class ProfileImage extends ConsumerWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userGlobalViewModelProvider);

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!, width: 2)),
        child: ClipOval(
          child:
              user?.profileImage != null && user!.profileImage!.isNotEmpty
                  ? Image.network(
                    user.profileImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                        child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                      );
                    },
                  )
                  : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                    child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                  ),
        ),
      ),
    );
  }
}
