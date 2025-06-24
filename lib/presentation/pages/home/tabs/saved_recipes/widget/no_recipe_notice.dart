import 'package:cooki/app/constants/app_colors.dart';
import 'package:cooki/presentation/widgets/under_line_text.dart';
import 'package:flutter/material.dart';

class NoRecipeNotice extends StatelessWidget {
  const NoRecipeNotice({super.key, required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/icons/cancel.png', width: 48, height: 48),
        Text('아직 ${category == "전체" ? "레시피" : category}가 없어요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        SizedBox(height: 8),
        Text('최근에 맛있게 먹은 음식이 생각나시나요?', style: TextStyle(fontSize: 12)),
        Text('사진 한 장, 간단한 설명이면 충분해요', style: TextStyle(fontSize: 12)),
        SizedBox(height: 24),
        SizedBox(
          height: 44,
          width: 280,
          child: ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/cooki_logo_white_no_text.png', width: 24, height: 24),
                SizedBox(width: 4),

                Text('레시피 생성하기', style: TextStyle(color: AppColors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(18), child: UnderLineText(text: "커뮤니티 둘러보기", textSize: 14)),
      ],
    );
  }
}
