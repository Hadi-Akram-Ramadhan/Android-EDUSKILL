import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/roadmap_node.dart';
import '../../widgets/unit_banner.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    final auth = context.watch<AuthProvider>();
    final activeCourse = courseProv.activeCourse;

    if (courseProv.isLoading && activeCourse == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    if (courseProv.errorMessage != null && activeCourse == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 56, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text(
                courseProv.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => courseProv.fetchCourses(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await courseProv.fetchCourses();
        await auth.checkAuthStatus();
      },
      child: CustomScrollView(
        slivers: [
          // Course Header / Switcher Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlueLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.code_rounded, color: AppTheme.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: activeCourse?.id,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMain),
                        items: courseProv.courses.map((c) {
                          return DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(
                              c.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppTheme.textMain,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id != null) {
                            final target = courseProv.courses.firstWhere((c) => c.id == id);
                            courseProv.setActiveCourse(target);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Course Units & Lesson Nodes (Winding path)
          if (activeCourse != null && activeCourse.units.isNotEmpty) ...[
            for (int uIdx = 0; uIdx < activeCourse.units.length; uIdx++) ...[
              SliverToBoxAdapter(
                child: UnitBanner(
                  unit: activeCourse.units[uIdx],
                  unitNumber: uIdx + 1,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, lIdx) {
                    final unit = activeCourse.units[uIdx];
                    final lesson = unit.lessons[lIdx];
                    return RoadmapNode(
                      lesson: lesson,
                      index: lIdx,
                      onTap: () {
                        context.push('/lesson/${lesson.id}');
                      },
                    );
                  },
                  childCount: activeCourse.units[uIdx].lessons.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ] else ...[
            const SliverFillRemaining(
              child: Center(
                child: Text('Belum ada materi tersedia.', style: TextStyle(color: AppTheme.textMuted)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
