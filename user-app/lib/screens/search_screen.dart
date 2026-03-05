import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme/app_theme.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_card.dart';
import '../widgets/shimmer_doctor_list.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchCtrl = useTextEditingController();
    final query = useState('');

    useEffect(() {
      void listener() {
        query.value = searchCtrl.text;
        ref.read(searchQueryProvider.notifier).state = searchCtrl.text;
      }

      searchCtrl.addListener(listener);
      return () => searchCtrl.removeListener(listener);
    }, [searchCtrl]);

    final searchAsync = ref.watch(searchDoctorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchCtrl,
          autofocus: true,
          style: GoogleFonts.poppins(color: AppTheme.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search doctors, specialties...',
            hintStyle: GoogleFonts.poppins(
              color: AppTheme.white.withAlpha(179),
              fontSize: 15,
            ),
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          cursorColor: AppTheme.white,
        ),
        actions: [
          if (query.value.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.close_circle, color: AppTheme.white),
              onPressed: () {
                searchCtrl.clear();
                query.value = '';
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.value.isEmpty
          ? _EmptySearch()
          : searchAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.search_status,
                          size: 64,
                          color: AppTheme.textGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results for "${query.value}"',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGrey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching by name or specialty',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (_, i) => DoctorCard(
                    doctor: doctors[i],
                    onTap: () =>
                        context.push('/doctor-detail', extra: doctors[i]),
                  ),
                );
              },
              loading: () => const ShimmerDoctorList(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final List<String> _suggestions = const [
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedic',
    'Gynecologist',
    'Dentist',
    'General Physician',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      // handled via AppBar search field
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.search_normal,
                            size: 14,
                            color: AppTheme.textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withAlpha(38)),
            ),
            child: Row(
              children: [
                const Icon(
                  Iconsax.search_normal,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your Doctor',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Type a doctor name or specialty above',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
