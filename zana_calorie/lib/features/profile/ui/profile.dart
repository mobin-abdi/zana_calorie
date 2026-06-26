import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zana_calorie/common/http_client.dart';
import 'package:zana_calorie/features/profile/data/model/profile_model.dart';
import 'package:zana_calorie/features/profile/data/repo/profile_repository.dart';
import 'package:zana_calorie/features/profile/data/source/profile_data_source.dart';
import 'package:zana_calorie/features/profile/ui/profile_bloc/profile_bloc.dart';
import 'package:zana_calorie/theme/light_theme.dart';
import 'package:zana_calorie/widget/loading_state_widget.dart';
import 'package:zana_calorie/widget/navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        profileRepository: ProfileRepository(
          dataSource: ProfileRemoteDataSource(dio: httpClient),
        ),
      )..add(ProfileStarted()),
      child: Scaffold(
        bottomNavigationBar: CustomNavigationBar(activeIndex: 3),
        body: const SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ProfileBody(),
          ),
        ),
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: LoadingState());
        }

        if (state is ProfileError) {
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
                      context.read<ProfileBloc>().add(ProfileStarted()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text("تلاش مجدد"),
                ),
              ],
            ),
          );
        }

        if (state is ProfileLoaded) {
          final profile = state.profile;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name.isNotEmpty ? profile.name : "کاربر زانا",
                        style: themeData.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "عضویت از: ${profile.dateJoined.split('T').first}",
                        style: themeData.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(endIndent: 32, indent: 32, thickness: 1.5),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "اطلاعات حساب کاربری",
                        style: themeData.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      UserInfoRow(
                        icon: Icons.email_outlined,
                        title: "ایمیل",
                        value: profile.email,
                      ),
                      const SizedBox(height: 12),
                      UserInfoRow(
                        icon: Icons.account_circle_outlined,
                        title: "نام کاربری",
                        value: profile.username,
                      ),
                    ],
                  ),
                ),
                const Divider(indent: 24, endIndent: 24, thickness: 1.5),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "اهداف تغذیه روزانه (تنظیمات زانا)",
                            style: themeData.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: () => _showEditGoalsBottomSheet(
                              context,
                              profile.goals,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GoalCard(
                              title: "پروتئین هدف",
                              value: "${profile.goals.targetProtein} گرم",
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GoalCard(
                              title: "چربی هدف",
                              value: "${profile.goals.targetFat} گرم",
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(indent: 24, endIndent: 24, thickness: 1.5),
                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.88,
                    height: 48,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "خروج از حساب کاربری",
                            style: themeData.textTheme.bodyMedium?.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.logout_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class UserInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const UserInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: themeData.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: themeData.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showEditGoalsBottomSheet(
  BuildContext context,
  ProfileGoalsModel currentGoals,
) {
  // ۱. رفع باگ کاربردپذیری: قرار دادن مقادیر فعلی دیتابیس به عنوان مقدار اولیه
  final caloriesController = TextEditingController(
    text: currentGoals.targetCalories.toString(),
  );
  final carbsController = TextEditingController(
    text: currentGoals.targetCarbs.toString(),
  );
  final proteinController = TextEditingController(
    text: currentGoals.targetProtein.toString(),
  );
  final fatController = TextEditingController(
    text: currentGoals.targetFat.toString(),
  );

  final formKey = GlobalKey<FormState>();
  final profileBloc = context.read<ProfileBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // این حتماً باید true باشه تا اجازه بده ارتفاع تغییر کنه
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomSheetContext) {
      // استفاده از MediaQuery برای گرفتن سایز کیبورد
      final keyboardHeight = MediaQuery.of(
        bottomSheetContext,
      ).viewInsets.bottom;

      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          // ۲. رفع باگ اورفلو: ایجاد پدینگ پویا بر اساس ارتفاع کیبورد زنده گوشی
          padding: EdgeInsets.only(
            bottom: keyboardHeight + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              // اضافه کردن فیزیک اسکرول برای باز شدن راحت فیلدها موقع بالا آمدن کیبورد
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "تنظیم اهداف جدید تغذیه",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "هدف کالری روزانه (kcal)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "لطفاً مقدار را وارد کنید" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // تراز کردن ارورهای ولیدیتور در یک خط
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "کربوهیدرات (گرم)",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? "اجباری" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "پروتئین (گرم)",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? "اجباری" : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "چربی (گرم)",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? "اجباری" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          profileBloc.add(
                            ProfileUpdateGoals({
                              "target_calories": int.parse(
                                caloriesController.text,
                              ),
                              "target_carbs": int.parse(carbsController.text),
                              "target_protein": int.parse(
                                proteinController.text,
                              ),
                              "target_fat": int.parse(fatController.text),
                            }),
                          );
                          Navigator.pop(bottomSheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        "ذخیره اهداف جدید",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class GoalCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const GoalCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: themeData.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: themeData.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
