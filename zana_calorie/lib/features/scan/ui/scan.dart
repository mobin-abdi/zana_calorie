import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zana_calorie/common/http_client.dart';
import 'package:zana_calorie/features/scan/data/repo/scan_repository.dart';
import 'package:zana_calorie/features/scan/data/source/scan_data_source.dart).dart';
import 'package:zana_calorie/features/scan/ui/scan_bloc/scan_bloc.dart';
import 'package:zana_calorie/theme/light_theme.dart';
import 'package:zana_calorie/widget/navigation_bar.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanBloc(
        scanRepository: ScanRepository(
          dataSource: ScanRemoteDataSource(dio: httpClient),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("اسکن هوشمند غذا")),
        body: const SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ScanBody(),
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(activeIndex: 1),
      ),
    );
  }
}

class ScanBody extends StatefulWidget {
  const ScanBody({super.key});

  @override
  State<ScanBody> createState() => _ScanBodyState();
}

class _ScanBodyState extends State<ScanBody> {
  File? _selectedImage;
  String _selectedMealType = "ناهار";
  final List<String> _mealTypes = ["صبحانه", "ناهار", "شام", "میان‌وعده"];

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return BlocConsumer<ScanBloc, ScanState>(
      listener: (context, state) {
        if (state is ScanSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✨ وعده غذایی با موفقیت ثبت شد!"),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (state is ScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red[400]),
          );
        }
      },
      builder: (context, state) {
        if (state is ScanLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text("هوش مصنوعی زانا در حال تحلیل و ثبت وعده شماست..."),
              ],
            ),
          );
        }

        if (state is ScanSuccess) {
          final response = state.responseData;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 72, color: AppColors.primary),
                const SizedBox(height: 16),
                Text("آنالیز خودکار با موفقیت انجام شد", style: themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("غذا تشخیص داده شده:", style: TextStyle(color: Colors.grey)),
                          Text(response['title'] ?? 'نامشخص', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("کالری کل ثبت شده:", style: TextStyle(color: Colors.grey)),
                          Text("🔥 ${response['calories']} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                      context.read<ScanBloc>().add(ScanResetEvent());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text(
                      "اسکن وعده جدید",
                      style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(labelText: "نوع وعده غذایی", border: OutlineInputBorder()),
                items: _mealTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedMealType = value!),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                      : const Center(child: Text("هنوز عکسی گرفته نشده است")),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePicture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.camera_alt_rounded, color: AppColors.background),
                      label: const Text("باز کردن دوربین", style: TextStyle(color: AppColors.background)),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<ScanBloc>().add(
                            ScanSubmitted(
                              imagePath: _selectedImage!.path,
                              mealType: _selectedMealType,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.cloud_upload_rounded, color: AppColors.background),
                        label: const Text("آنالیز و ثبت نهایی", style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}