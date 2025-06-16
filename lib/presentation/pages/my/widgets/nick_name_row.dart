import 'package:cooki/core/utils/general_util.dart';
import 'package:cooki/presentation/user_global_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NickNameRow extends ConsumerStatefulWidget {
  const NickNameRow({super.key});

  @override
  ConsumerState<NickNameRow> createState() => _NickNameRowState();
}

class _NickNameRowState extends ConsumerState<NickNameRow> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentName = ref.read(userGlobalViewModelProvider)?.name ?? '';
    _controller = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final vm = ref.read(userGlobalViewModelProvider.notifier);
    final newName = _controller.text.trim();
    if (newName.isNotEmpty) {
      vm.setName(newName);
      vm.saveUserToDatabase();
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userGlobalViewModelProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 40, // 🔒 Row 전체 높이를 고정
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(strings(context).nickName, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  _isEditing
                      ? SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onSubmitted: (_) => _submit(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      )
                      : SizedBox(
                        width: 120,
                        child: Text(
                          user?.name ?? '',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_isEditing) {
                  _submit();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Icon(_isEditing ? Icons.check : Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
