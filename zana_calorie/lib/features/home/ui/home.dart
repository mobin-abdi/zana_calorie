import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zana_calorie/common/http_client.dart';
import 'package:zana_calorie/features/home/data/repo/home_repository.dart';
import 'package:zana_calorie/features/home/data/source/home_data_source.dart';
import 'package:zana_calorie/features/home/ui/home_bloc/home_bloc.dart';
import 'package:zana_calorie/features/scan/ui/scan.dart';
import 'package:zana_calorie/theme/light_theme.dart';
import 'package:zana_calorie/widget/loading_state_widget.dart';
import 'package:zana_calorie/widget/navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        homeRepository: HomeRepository(
          dataSource: HomeRemoteDataSource(dio: httpClient),
        ),
      )..add(HomeStarted()),
      child: Scaffold(
        bottomNavigationBar: const CustomNavigationBar(activeIndex: 0),
        body: const SafeArea(
          child: HomeBody(),
        ),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth * 0.88;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: LoadingState());
        }

        if (state is HomeLoaded) {
          final dashboardData = state.data;

          // محاسبه مطمئن درصدها بین 0.0 و 1.0 برای LinearProgressIndicator
          final double carbsProgress = dashboardData.macros.carbs.percentage > 1.0
              ? dashboardData.macros.carbs.percentage / 100.0
              : dashboardData.macros.carbs.percentage;

          final double proteinProgress = dashboardData.macros.protein.percentage > 1.0
              ? dashboardData.macros.protein.percentage / 100.0
              : dashboardData.macros.protein.percentage;

          final double fatProgress = dashboardData.macros.fat.percentage > 1.0
              ? dashboardData.macros.fat.percentage / 100.0
              : dashboardData.macros.fat.percentage;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(HomeStarted());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: containerWidth,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              "پیشرفت امروز",
                              style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 180,
                                width: 180,
                                child: CircularProgressIndicator(
                                  value: dashboardData.summary.targetCalories > 0
                                      ? (dashboardData.summary.totalCalories / dashboardData.summary.targetCalories)
                                      : 0.0,
                                  strokeWidth: 12,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${dashboardData.summary.totalCalories}",
                                    style: themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "کالری مصرف شده",
                                    style: themeData.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 16,
                                          width: 6,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("باقی مانده امروز", style: themeData.textTheme.bodySmall),
                                      ],
                                    ),
                                    Text(
                                      "${dashboardData.summary.remainingCalories}",
                                      style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InfoBox(
                                  key: ValueKey("carbs_${dashboardData.macros.carbs.current}"),
                                  subject: "کربوهیدرات",
                                  value: "${dashboardData.macros.carbs.current} گرم",
                                  progressValue: carbsProgress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.green,
                                ),
                                InfoBox(
                                  key: ValueKey("protein_${dashboardData.macros.protein.current}"),
                                  subject: "پروتئین",
                                  value: "${dashboardData.macros.protein.current} گرم",
                                  progressValue: proteinProgress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.redAccent,
                                ),
                                InfoBox(
                                  key: ValueKey("fat_${dashboardData.macros.fat.current}"),
                                  subject: "چربی",
                                  value: "${dashboardData.macros.fat.current} گرم",
                                  progressValue: fatProgress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: containerWidth,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.primary,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              "assets/images/img.jpg",
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // اصلاح خطای تایپی اینجا انجام شد
                              children: [
                                Text(
                                  "اسکن هوشمند غذا",
                                  style: themeData.textTheme.bodyMedium!.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "با هوش مصنوعی کالری وعده غذایی خود را در چند ثانیه تشخیص دهید.",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: themeData.textTheme.bodySmall!.copyWith(
                                    color: AppColors.background.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ScanScreen(),));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.background,
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  ),
                                  icon: const Icon(Icons.camera_alt_rounded, size: 16),
                                  label: Text("شروع اسکن", style: themeData.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // لیست وعده‌ها
                    SizedBox(
                      width: containerWidth,
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("وعده‌های امروز", style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "مشاهده همه",
                                    style: themeData.textTheme.bodySmall!.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: dashboardData.todayMeals.length,
                            itemBuilder: (context, index) {
                              final meal = dashboardData.todayMeals[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl: meal.image ?? '',
                                            width: 65,
                                            height: 65,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => const Icon(Icons.fastfood, size: 30),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              meal.title,
                                              style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              meal.mealType,
                                              style: themeData.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${meal.calories}",
                                                style: themeData.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                "کالری",
                                                style: themeData.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<HomeBloc>().add(HomeStarted());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("تلاش مجدد"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class InfoBox extends StatelessWidget {
  final String subject;
  final String value;
  final double progressValue;
  final Color? backgroundColor;
  final Color? color;

  const InfoBox({
    super.key,
    required this.subject,
    required this.value,
    required this.progressValue,
    required this.backgroundColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(subject, style: themeData.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: themeData.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 6),
        SizedBox(
          width: 65,
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 6,
            backgroundColor: backgroundColor,
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}