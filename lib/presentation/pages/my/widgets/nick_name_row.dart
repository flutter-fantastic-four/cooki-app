import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NickNameRow extends ConsumerWidget {
  const NickNameRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(strings(context).nickName, style: TextStyle(fontSize: 16)),
          Spacer(),
          Text(ref.read(userGlobalViewModelProvider)!.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(child: Icon(Icons.edit_outlined)),
        ],
      ),
    );
  }
}
