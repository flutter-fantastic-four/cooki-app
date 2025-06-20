import 'package:cooki/core/utils/sharing_util.dart';
import 'package:cooki/data/repository/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entity/recipe.dart';

class ShareExample extends StatelessWidget {
  const ShareExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Example')),
      body: Center(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return ElevatedButton(
              onPressed: () async {
                final testRecipe = Recipe(
                  ratingCount: 10,
                  ratingSum: 3.5,
                  id: 'test001',
                  recipeName: '김치볶음밥',
                  ingredients: [
                    '밥 2공기',
                    '김치 200g',
                    '돼지고기 100g',
                    '대파 1대',
                    '마늘 3쪽',
                    '참기름 1큰술',
                    '식용유 2큰술',
                    '김치국물 3큰술',
                    '간장 1큰술',
                    '설탕 1작은술',
                    '달걀 2개',
                    '김 1장',
                  ],
                  steps: [
                    '김치는 한 입 크기로 썰고, 돼지고기는 작게 썰어 준비합니다.',
                    '대파는 송송 썰고, 마늘은 다져 줍니다.',
                    '팬에 식용유를 두르고 달걀을 스크램블로 만든 후 따로 빼둡니다.',
                    '같은 팬에 돼지고기를 볶아 익힙니다.',
                    '돼지고기가 익으면 다진 마늘과 김치를 넣고 볶습니다.',
                    '김치가 볶아지면 김치국물과 간장, 설탕을 넣고 간을 맞춥니다.',
                    '밥을 넣고 김치와 잘 섞이도록 볶습니다.',
                    '스크램블 달걀과 대파를 넣고 한 번 더 볶습니다.',
                    '마지막에 참기름을 넣고 섞은 후 그릇에 담습니다.',
                    '김을 올려 완성합니다.',
                  ],
                  cookTime: 15,
                  calories: 450,
                  category: '한식',
                  tags: ['볶음밥', '김치', '간단요리', '집밥', '15분요리'],
                  userId: 'user123',
                  userName: '홍길동',
                  userProfileImage: 'https://picsum.photos/50/50',
                  isPublic: true,
                  imageUrl: 'https://picsum.photos/600/400', // Recipe image
                );
                await SharingUtil.shareRecipe(context, testRecipe, ref.read(imageDownloadRepositoryProvider));
              },
              child: const Text('Share Image + Text'),
            );
          },
        ),
      ),
    );
  }
}
