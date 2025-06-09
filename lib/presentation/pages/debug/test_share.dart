import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

const recipeTest = '''
김치볶음밥 레시피

📂 카테고리: 한식  
⏱️ 조리 시간: 15분  
🔥 칼로리: 450kcal  
🏷️ 태그: 볶음밥, 김치, 간단요리, 집밥, 15분요리  

▶ 재료  
• 밥 2공기  
• 김치 200g  
• 돼지고기 100g  
• 대파 1대  
• 마늘 3쪽  
• 참기름 1큰술  
• 식용유 2큰술  
• 김치국물 3큰술  
• 간장 1큰술  
• 설탕 1작은술  
• 달걀 2개  
• 김 1장  

▶ 만드는 방법  
1. 김치는 한 입 크기로 썰고, 돼지고기는 작게 썰어 준비합니다.  
2. 대파는 송송 썰고, 마늘은 다져 줍니다.  
3. 팬에 식용유를 두르고 달걀을 스크램블로 만든 후 따로 빼둡니다.  
4. 같은 팬에 돼지고기를 볶아 익힙니다.  
5. 돼지고기가 익으면 다진 마늘과 김치를 넣고 볶습니다.  
6. 김치가 볶아지면 김치국물과 간장, 설탕을 넣고 간을 맞춥니다.  
7. 밥을 넣고 김치와 잘 섞이도록 볶습니다.  
8. 스크램블 달걀과 대파를 넣고 한 번 더 볶습니다.  
9. 마지막에 참기름을 넣고 섞은 후 그릇에 담습니다.  
10. 김을 올려 완성합니다.
''';

class ShareExample extends StatelessWidget {
  const ShareExample({super.key});

  Future<void> _shareImageAndText() async {
    // Load asset image
    final byteData = await rootBundle.load('assets/icons/google.png');

    // Save it to a temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/google.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    // Share with text
    await SharePlus.instance.share(
      ShareParams(
        text: recipeTest,
        subject: '김치볶음밥 레시피 공유합니다!',
        files: [XFile(file.path)],
        previewThumbnail: XFile(file.path),
      ),
      // [XFile(file.path)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _shareImageAndText,
          child: const Text('Share Image + Text'),
        ),
      ),
    );
  }
}
