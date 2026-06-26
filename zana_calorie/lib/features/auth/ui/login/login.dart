import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zana_calorie/common/http_client.dart';
import 'package:zana_calorie/features/auth/data/repo/auth_repository.dart';
import 'package:zana_calorie/features/auth/data/source/auth_data_source.dart';
import 'package:zana_calorie/features/auth/ui/login/login_bloc/login_bloc.dart';
import 'package:zana_calorie/features/auth/ui/register/register.dart';
import 'package:zana_calorie/features/home/ui/home.dart';
import 'package:zana_calorie/theme/light_theme.dart';
import 'package:zana_calorie/widget/loading_state_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: "mobin");
  final TextEditingController _passwordController = TextEditingController(text: "mobin");

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => LoginBloc(
            authRepository: AuthRepository(
              dataSource: AuthRemoteDataSource(dio: httpClient),
            ),
          ),
          child: BlocConsumer<LoginBloc, LoginState>(
            // ۱. مدیریت رفتن به صفحه بعد و اسنک‌بار با لیسنر
            listener: (context, state) {
              if (state is LoginLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("ورود موفقیت‌آمیز بود"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else if (state is LoginError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${state.message} | دوباره تلاش کنید"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            // ۲. فقط رندر کردن یوآی با بیلدر
            builder: (context, state) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: SingleChildScrollView(
                    // اضافه کردن اسکرول برای جلوگیری از خطای کیبورد
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          "پیش‌بینی کالری هوشمند زانا",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "وارد حساب کاربری خود شوید تا مسیر سلامتی را ادامه دهید",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 0.5,
                                color: AppColors.grey,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      hintText: "نام کاربری",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true, // مخفی کردن پسورد
                                    decoration: InputDecoration(
                                      hintText: "رمز عبور",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "فراموشی رمز عبور؟",
                                      style: TextStyle(
                                        color: Color(0xffff0000),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    height: 55,
                                    width: double.infinity,
                                    child: TextButton(
                                      // غیرفعال کردن دکمه در حالت لودینگ برای جلوگیری از اسپم
                                      onPressed: state is LoginLoading
                                          ? null
                                          : () {
                                              if (_usernameController
                                                      .text
                                                      .isNotEmpty &&
                                                  _passwordController
                                                      .text
                                                      .isNotEmpty) {
                                                context.read<LoginBloc>().add(
                                                  LoginStarted(
                                                    username:
                                                        _usernameController
                                                            .text,
                                                    password:
                                                        _passwordController
                                                            .text,
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "لطفاً همه فیلدها را پر کنید",
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.background,
                                        disabledBackgroundColor: AppColors
                                            .grey, // رنگ دکمه زمان لودینگ
                                      ),
                                      child: state is LoginLoading
                                          ? LoadingState()
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("ورود به حساب"),
                                                SizedBox(width: 8),
                                                Icon(Icons.login_sharp),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("حساب کاربری ندارید؟"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text('ثبت نام کنید'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
