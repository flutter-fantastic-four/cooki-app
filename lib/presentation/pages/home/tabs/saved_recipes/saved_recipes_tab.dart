import 'package:flutter/material.dart';
import '../../../../../app/constants/app_constants.dart';
import '../../../../../core/utils/general_util.dart';

class Recipe {
  final String name;
  final int rating;
  final String category;
  final String cuisine;
  final int cookTime;
  final bool isSelected;

  Recipe({
    required this.name,
    required this.rating,
    required this.category,
    required this.cuisine,
    required this.cookTime,
    this.isSelected = false,
  });
}

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  String selectedCategory = AppConstants.recipeTabAll;
  List<String> selectedCuisines = [];
  String selectedSort = '';
  late PageController _pageController;

  // Diverse recipe samples from each cuisine
  final List<Recipe> allRecipes = [
    // Korean dishes with longer names
    Recipe(
      name: '매콤달콤 양념치킨과 크림 치즈 디핑 소스',
      rating: 4,
      category: '생성한 레시피',
      cuisine: '한식',
      cookTime: 45,
    ),
    Recipe(
      name: '통영식 해물짬뽕과 바삭한 군만두',
      rating: 5,
      category: '저장한 레시피',
      cuisine: '한식',
      cookTime: 35,
    ),
    Recipe(
      name: '제주도 흑돼지 김치찌개와 묵은지',
      rating: 4,
      category: '공유한 레시피',
      cuisine: '한식',
      cookTime: 40,
    ),

    // Chinese dishes with longer names
    Recipe(
      name: '매콤한 사천식 마라 샹궈와 꿔바로우',
      rating: 5,
      category: '생성한 레시피',
      cuisine: '중식',
      cookTime: 60,
    ),
    Recipe(
      name: '트러플 오일을 곁들인 블랙빈 소스 랍스터',
      rating: 4,
      category: '저장한 레시피',
      cuisine: '중식',
      cookTime: 45,
    ),
    Recipe(
      name: '대파 듬뿍 넣은 특제 소스 양꼬치와 칭따오',
      rating: 3,
      category: '공유한 레시피',
      cuisine: '중식',
      cookTime: 35,
    ),

    // Japanese dishes with longer names
    Recipe(
      name: '훈제 연어와 아보카도를 곁들인 스페셜 롤',
      rating: 5,
      category: '생성한 레시피',
      cuisine: '일식',
      cookTime: 50,
    ),
    Recipe(
      name: '부드러운 차슈와 면발이 일품인 돈코츠 라멘',
      rating: 4,
      category: '저장한 레시피',
      cuisine: '일식',
      cookTime: 180,
    ),
    Recipe(
      name: '계절 해산물을 올린 특선 치라시 스시',
      rating: 3,
      category: '공유한 레시피',
      cuisine: '일식',
      cookTime: 45,
    ),

    // Western dishes with longer names
    Recipe(
      name: '트러플 크림 소스를 곁들인 채끝 등심 스테이크',
      rating: 5,
      category: '생성한 레시피',
      cuisine: '양식',
      cookTime: 30,
    ),
    Recipe(
      name: '홈메이드 바질 페스토 파스타와 새우 구이',
      rating: 4,
      category: '저장한 레시피',
      cuisine: '양식',
      cookTime: 25,
    ),
    Recipe(
      name: '모짜렐라 치즈 듬뿍 미트볼 스파게티',
      rating: 3,
      category: '공유한 레시피',
      cuisine: '양식',
      cookTime: 40,
    ),

    // Thai dishes with longer names
    Recipe(
      name: '레몬그라스 향이 가득한 똠양꿍과 쌀국수',
      rating: 4,
      category: '생성한 레시피',
      cuisine: '태국식',
      cookTime: 50,
    ),
    Recipe(
      name: '코코넛 밀크로 맛을 낸 그린 커리와 난',
      rating: 3,
      category: '저장한 레시피',
      cuisine: '태국식',
      cookTime: 45,
    ),
    Recipe(
      name: '신선한 해산물이 들어간 팟타이 스페셜',
      rating: 5,
      category: '공유한 레시피',
      cuisine: '태국식',
      cookTime: 30,
    ),

    // Korean dishes
    Recipe(
      name: '김치볶음밥',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '한식',
      cookTime: 15,
      isSelected: true,
    ),
    Recipe(
      name: '불고기',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '한식',
      cookTime: 30,
    ),
    Recipe(
      name: '비빔밥',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '한식',
      cookTime: 20,
    ),
    Recipe(
      name: '된장찌개',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '한식',
      cookTime: 25,
    ),

    // Chinese dishes
    Recipe(
      name: '마파두부',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '중식',
      cookTime: 25,
    ),
    Recipe(
      name: '탕수육',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '중식',
      cookTime: 45,
    ),
    Recipe(
      name: '짜장면',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '중식',
      cookTime: 30,
    ),
    Recipe(
      name: '양꼬치',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '중식',
      cookTime: 20,
    ),

    // Japanese dishes
    Recipe(
      name: '초밥',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '일식',
      cookTime: 40,
    ),
    Recipe(
      name: '라멘',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '일식',
      cookTime: 35,
    ),
    Recipe(
      name: '돈까스',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '일식',
      cookTime: 25,
    ),
    Recipe(
      name: '우동',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '일식',
      cookTime: 20,
    ),

    // Thai dishes
    Recipe(
      name: '팟타이',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '태국식',
      cookTime: 20,
    ),
    Recipe(
      name: '톰얌꿍',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '태국식',
      cookTime: 30,
    ),
    Recipe(
      name: '그린커리',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '태국식',
      cookTime: 35,
    ),

    // Indian dishes
    Recipe(
      name: '버터치킨',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '인도식',
      cookTime: 45,
    ),
    Recipe(
      name: '치킨 티카 마살라',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '인도식',
      cookTime: 40,
    ),
    Recipe(
      name: '난브레드',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '인도식',
      cookTime: 60,
    ),

    // American dishes
    Recipe(
      name: '햄버거',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '미국식',
      cookTime: 20,
    ),
    Recipe(
      name: 'BBQ 립',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '미국식',
      cookTime: 180,
    ),
    Recipe(
      name: '맥앤치즈',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '미국식',
      cookTime: 25,
    ),

    // French dishes
    Recipe(
      name: '라따뚜이',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '프랑스식',
      cookTime: 50,
    ),
    Recipe(
      name: '코코뱅',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '프랑스식',
      cookTime: 120,
    ),
    Recipe(
      name: '크로와상',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '프랑스식',
      cookTime: 240,
    ),

    // Italian dishes
    Recipe(
      name: '스파게티 카르보나라',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '이탈리아식',
      cookTime: 20,
    ),
    Recipe(
      name: '마르게리타 피자',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '이탈리아식',
      cookTime: 30,
    ),
    Recipe(
      name: '리조또',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '이탈리아식',
      cookTime: 35,
    ),

    // Mediterranean dishes
    Recipe(
      name: '그릭 샐러드',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '지중해식',
      cookTime: 15,
    ),
    Recipe(
      name: '후무스',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '지중해식',
      cookTime: 10,
    ),
    Recipe(
      name: '팔라펠',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '지중해식',
      cookTime: 25,
    ),

    // Middle Eastern dishes
    Recipe(
      name: '케밥',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '중동식',
      cookTime: 30,
    ),
    Recipe(
      name: '바클라바',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '중동식',
      cookTime: 90,
    ),
    Recipe(
      name: '타불레',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '중동식',
      cookTime: 20,
    ),

    // Mexican dishes
    Recipe(
      name: '타코',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '멕시코식',
      cookTime: 25,
    ),
    Recipe(
      name: '엔칠라다',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '멕시코식',
      cookTime: 40,
    ),
    Recipe(
      name: '과카몰리',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '멕시코식',
      cookTime: 10,
    ),

    // Southeast Asian dishes
    Recipe(
      name: '나시고렝',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '동남아식',
      cookTime: 20,
    ),
    Recipe(
      name: '렌당',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '동남아식',
      cookTime: 120,
    ),
    Recipe(
      name: '쌀국수',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '동남아식',
      cookTime: 30,
    ),

    // African dishes
    Recipe(
      name: '타진',
      rating: 0,
      category: '생성한 레시피',
      cuisine: '아프리카식',
      cookTime: 90,
    ),
    Recipe(
      name: '쿠스쿠스',
      rating: 0,
      category: '저장한 레시피',
      cuisine: '아프리카식',
      cookTime: 25,
    ),
    Recipe(
      name: '인제라',
      rating: 0,
      category: '공유한 레시피',
      cuisine: '아프리카식',
      cookTime: 180,
    ),
  ];

  List<Recipe> get filteredRecipes {
    List<Recipe> recipes = allRecipes;

    // Filter by category first
    if (selectedCategory != AppConstants.recipeTabAll) {
      recipes = recipes.where((r) => r.category == selectedCategory).toList();
    }

    // Filter by cuisines if any selected
    if (selectedCuisines.isNotEmpty) {
      recipes =
          recipes.where((r) => selectedCuisines.contains(r.cuisine)).toList();
    }

    // Apply sort option if selected
    if (selectedSort == AppConstants.sortByRating) {
      recipes.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSort == AppConstants.sortByCookTimeAsc) {
      recipes.sort((a, b) => a.cookTime.compareTo(b.cookTime));
    }

    return recipes;
  }

  void _showCuisineFilter() {
    final cuisineCategories = AppConstants.recipeCategories(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFFF5F5F5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '카테고리',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: cuisineCategories.length,
                  itemBuilder: (context, index) {
                    final cuisine = cuisineCategories[index];
                    final isSelected = selectedCuisines.contains(cuisine);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      title: Text(
                        cuisine,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected
                                  ? const Color(0xFF1D8163)
                                  : Colors.black,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Color(0xFF1D8163),
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedCuisines.remove(cuisine);
                          } else {
                            selectedCuisines.add(cuisine);
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCuisines.clear();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('필터 초기화'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: AppConstants.recipeTabCategories(
        context,
      ).indexOf(selectedCategory),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = filteredRecipes;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '나의 레시피',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: FilterIconWithDot(
              showDot: selectedCuisines.isNotEmpty || selectedSort.isNotEmpty,
            ),
            onPressed: () async {
              String tempSort = selectedSort;
              List<String> tempCuisines = List.from(selectedCuisines);
              String tempCategory = selectedCategory;
              final cuisineCategories = AppConstants.recipeCategories(context);
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pill-shaped indicator
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                    ),
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E0E0),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '필터',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Sort options as chips at the top
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                tempSort =
                                                    tempSort ==
                                                            AppConstants
                                                                .sortByRating
                                                        ? ''
                                                        : AppConstants
                                                            .sortByRating;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    tempSort ==
                                                            AppConstants
                                                                .sortByRating
                                                        ? const Color(
                                                          0xFF1D8163,
                                                        )
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE0E0E0,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                AppConstants.sortByRating,
                                                style: TextStyle(
                                                  color:
                                                      tempSort ==
                                                              AppConstants
                                                                  .sortByRating
                                                          ? Colors.white
                                                          : const Color(
                                                            0xFF666666,
                                                          ),
                                                  fontSize: 12,
                                                  fontWeight:
                                                      tempSort ==
                                                              AppConstants
                                                                  .sortByRating
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setModalState(() {
                                                tempSort =
                                                    tempSort ==
                                                            AppConstants
                                                                .sortByCookTimeAsc
                                                        ? ''
                                                        : AppConstants
                                                            .sortByCookTimeAsc;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    tempSort ==
                                                            AppConstants
                                                                .sortByCookTimeAsc
                                                        ? const Color(
                                                          0xFF1D8163,
                                                        )
                                                        : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE0E0E0,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                AppConstants.sortByCookTimeAsc,
                                                style: TextStyle(
                                                  color:
                                                      tempSort ==
                                                              AppConstants
                                                                  .sortByCookTimeAsc
                                                          ? Colors.white
                                                          : const Color(
                                                            0xFF666666,
                                                          ),
                                                  fontSize: 12,
                                                  fontWeight:
                                                      tempSort ==
                                                              AppConstants
                                                                  .sortByCookTimeAsc
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Color(0xFFE0E0E0),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        '국가별',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            cuisineCategories.map((cuisine) {
                                              final isSelected = tempCuisines
                                                  .contains(cuisine);
                                              return GestureDetector(
                                                onTap: () {
                                                  setModalState(() {
                                                    if (isSelected) {
                                                      tempCuisines.remove(
                                                        cuisine,
                                                      );
                                                    } else {
                                                      tempCuisines.add(cuisine);
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isSelected
                                                            ? const Color(
                                                              0xFF1D8163,
                                                            )
                                                            : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          24,
                                                        ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFE0E0E0,
                                                      ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    cuisine,
                                                    style: TextStyle(
                                                      color:
                                                          isSelected
                                                              ? Colors.white
                                                              : const Color(
                                                                0xFF666666,
                                                              ),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.w600
                                                              : FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedSort = '';
                                                  selectedCuisines.clear();
                                                  selectedCategory =
                                                      tempCategory;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('초기화'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedSort = tempSort;
                                                  selectedCuisines = List.from(
                                                    tempCuisines,
                                                  );
                                                  selectedCategory =
                                                      tempCategory;
                                                });
                                                Navigator.pop(context);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF1D8163,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('적용하기'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).viewInsets.bottom +
                                      16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Category tabs at the top
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children:
                  AppConstants.recipeTabCategories(context).asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final isSelected = selectedCategory == category;
                      final isLastTab =
                          index ==
                          AppConstants.recipeTabCategories(context).length - 1;
                      return Padding(
                        padding: EdgeInsets.only(right: isLastTab ? 0 : 8),
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              AppConstants.recipeTabCategories(
                                context,
                              ).indexOf(category),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      isSelected
                                          ? const Color(0xFF1D8163)
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? const Color(0xFF1D8163)
                                        : const Color(0xFF666666),
                                fontSize: 12,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
            ),
          ),
          // Active filters display
          if (selectedCuisines.isNotEmpty || selectedSort.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  ...selectedCuisines
                      .map(
                        (cuisine) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D8163).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF1D8163),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cuisine,
                                style: const TextStyle(
                                  color: Color(0xFF1D8163),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCuisines.remove(cuisine);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Color(0xFF1D8163),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  if (selectedSort.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D8163).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF1D8163),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedSort,
                            style: const TextStyle(
                              color: Color(0xFF1D8163),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSort = '';
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF1D8163),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          // Recipe grid in PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  selectedCategory =
                      AppConstants.recipeTabCategories(context)[index];
                });
              },
              itemCount: AppConstants.recipeTabCategories(context).length,
              itemBuilder: (context, index) {
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        delegate: SliverChildBuilderDelegate((
                          context,
                          recipeIndex,
                        ) {
                          final recipe = filteredRecipes[recipeIndex];
                          return _RecipeCard(
                            title: recipe.name,
                            rating: recipe.rating,
                            category: recipe.category,
                            cuisine: recipe.cuisine,
                            cookTime: recipe.cookTime,
                            isSelected: recipe.isSelected,
                          );
                        }, childCount: filteredRecipes.length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String title;
  final int rating;
  final String category;
  final String cuisine;
  final int cookTime;
  final bool isSelected;

  const _RecipeCard({
    required this.title,
    required this.rating,
    required this.category,
    required this.cuisine,
    required this.cookTime,
    this.isSelected = false,
  });

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5F5F5), // AppColors.greyScale50
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 30,
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 12),
              ),

              _PhotoModalStyleCard(
                text: '커뮤니티 게시하기',
                icon: Icons.people_outline,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement community post action
                },
              ),

              _PhotoModalStyleCard(
                text: '공유하기',
                icon: Icons.share_outlined,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement share action
                },
              ),

              _PhotoModalStyleCard(
                text: '수정하기',
                icon: Icons.edit_outlined,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit action
                },
              ),

              _PhotoModalStyleCard(
                text: '삭제하기',
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete action
                },
              ),

              const SizedBox(height: 15),
              _PhotoModalStyleCard(
                text: '닫기',
                onTap: () => Navigator.pop(context),
                isCenter: true,
              ),
            ],
          ),
        );
      },
    );
  }

  //Card interface for each recipe
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe image placeholder with three-dot menu
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showOptionsModal(context),
                    child: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Recipe details
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height:
                        42, // Approximately 2 lines of text at fontSize 15 with 1.2 height
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.black,
                            size: 14,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this widget for the filter icon with notification dot
class FilterIconWithDot extends StatelessWidget {
  final bool showDot;
  const FilterIconWithDot({super.key, required this.showDot});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.filter_list, color: Colors.black, size: 24),
        if (showDot)
          Positioned(
            right: -2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF1D8163),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoModalStyleCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isCenter;
  final Color? textColor;
  final Color? iconColor;

  const _PhotoModalStyleCard({
    required this.text,
    this.icon,
    required this.onTap,
    this.isCenter = false,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 1),
        leading:
            !isCenter
                ? Padding(
                  padding: const EdgeInsets.only(left: 24, right: 4),
                  child: Icon(icon, color: iconColor ?? Colors.black87),
                )
                : null,
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
          textAlign: isCenter ? TextAlign.center : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
