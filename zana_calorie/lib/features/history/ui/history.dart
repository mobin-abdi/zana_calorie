import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zana_calorie/common/http_client.dart';
import 'package:zana_calorie/features/history/ui/history_bloc/history_bloc.dart';
import 'package:zana_calorie/theme/light_theme.dart';
import 'package:zana_calorie/widget/loading_state_widget.dart';
import 'package:zana_calorie/widget/navigation_bar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryBloc(dio: httpClient)..add(HistoryStarted()),
      child: Scaffold(
        bottomNavigationBar: CustomNavigationBar(activeIndex: 2),
        body: const SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: HistoryBody(),
          ),
        ),
      ),
    );
  }
}

class HistoryBody extends StatelessWidget {
  const HistoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: LoadingState());
        }

        if (state is HistoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<HistoryBloc>().add(HistoryStarted()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text("تلاش مجدد", style: TextStyle(color: AppColors.background),),
                ),
              ],
            ),
          );
        }

        if (state is HistoryLoaded) {
          if (state.meals.isEmpty) {
            return const Center(
              child: Text("هنوز هیچ وعده غذایی ثبت نشده است."),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HistoryBloc>().add(HistoryStarted());
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 32, 24, 16),
                    child: Text(
                      state.dateRange,
                      style: themeData.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.meals.length,
                    itemBuilder: (context, index) {
                      final meal = state.meals[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
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
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: meal.image ?? '',
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.fastfood, size: 30),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.mealType,
                                    style: themeData.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    meal.title,
                                    style: themeData.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                      style: themeData.textTheme.bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "کالری",
                                      style: themeData.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
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
