import 'dart:developer';

import 'package:cooki/core/utils/dialogue_util.dart';
import 'package:cooki/presentation/pages/generate/widgets/generate_button.dart';
import 'package:cooki/presentation/pages/generate/widgets/preference_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_constants.dart';

import '../../../data/repository/providers.dart';
import '../../widgets/input_decorations.dart';

class GenerateRecipePage extends StatefulWidget {
  const GenerateRecipePage({super.key});

  @override
  State<GenerateRecipePage> createState() => _GenerateRecipePageState();
}

class _GenerateRecipePageState extends State<GenerateRecipePage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showImageSourceActionSheet(BuildContext context) {
    DialogueUtil.showCustomCupertinoActionSheet(
      context,
      title: '이미지 선택',
      option1Text: '카메라로 찍기',
      option2Text: '갤러리에서 선택',
      onOption1: () {},
      onOption2: () {},
    );
  }

  Future<void> testApi(WidgetRef ref) async {
    final validationResult = await ref
        .read(recipeGenerationRepositoryProvider)
        .validateUserInput(_textController.text);
    log("IsValid: ${validationResult.isValid}");

    if (validationResult.isValid) {
      final recipe = await ref
          .read(recipeGenerationRepositoryProvider)
          .generateRecipe(textInput: _textController.text);
      log('Generated recipe: \n$recipe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close, size: 27),
          ),
          title: const Text('AI 레시피 생성', style: TextStyle(color: Colors.black)),
        ),
        bottomNavigationBar: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return GenerateButton(onTap: () => testApi(ref));
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: _buildLayout(context),
        ),
      ),
    );
  }

  ListView _buildLayout(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 10),
        const Text(
          '어떤 요리를 만들고 싶으신가요?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '사진 또는 텍스트만으로 레시피를 만들 수 있어요.\n사진을 사용할 경우, 어떤 음식인지 간단히 설명해 주세요.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
        ),
        const SizedBox(height: 22),
        _buildImageSelector(context),
        const SizedBox(height: 19),
        TextField(
          maxLines: 4,
          maxLength: 300,
          controller: _textController,
          decoration: getInputDecoration('예: 감자, 양파, 베이컨으로 만들 수 있는 간단한 요리'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...AppConstants.recipePreferences.map(
                  (label) => PreferenceChip(label: '+ $label'),
                ),
                // SizedBox(width: 4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Center(
            child: Text(
              '팁: 더 나은 결과를 위해 주재료, 조리 방법 또는 요리 유형을 포함하면 더 정확한 결과를 얻을 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector _buildImageSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[100]!,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.photo_on_rectangle,
            size: 48,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
