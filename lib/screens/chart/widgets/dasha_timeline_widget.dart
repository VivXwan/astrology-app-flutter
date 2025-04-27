import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/dasha_model.dart';
import '../../../providers/dasha_provider.dart';
import 'package:intl/intl.dart';

class DashaTimelineWidget extends StatelessWidget {
  const DashaTimelineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DashaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final dashaData = provider.dashaData;
        if (dashaData == null) {
          return const Center(
            child: Text('No Dasha data available'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Vimshottari Dasha Timeline',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (provider.showingAntarDasha || provider.showingPratyantar) ...[
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () {
                        if (provider.showingPratyantar) {
                          provider.backToAntarDasha();
                        } else {
                          provider.backToMahaDasha();
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        provider.showingPratyantar
                            ? 'Back to Antar Dashas'
                            : 'Back to Maha Dashas',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                height: 170,  // Increased height to accommodate arrows
                child: _buildCurrentView(provider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentView(DashaProvider provider) {
    if (provider.showingPratyantar && provider.selectedAntarDasha != null) {
      return _buildPratyantarDashaTimeline(
        provider.selectedMahaDasha!,
        provider.selectedAntarDasha!,
      );
    } else if (provider.showingAntarDasha && provider.selectedMahaDasha != null) {
      return _buildAntarDashaTimeline(provider.selectedMahaDasha!, provider);
    } else {
      return _buildMahaDashaTimeline(provider.dashaData!, provider);
    }
  }

  Widget _buildNavigationArrows(
    DashaProvider provider,
    bool canGoBack,
    bool canGoForward,
    VoidCallback onBack,
    VoidCallback onForward,
  ) {
    return SizedBox(
      height: 30,  // Fixed height for arrow container
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: canGoBack ? onBack : null,
            icon: Icon(
              Icons.arrow_back,
              color: canGoBack ? Colors.black87 : Colors.black26,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: canGoForward ? onForward : null,
            icon: Icon(
              Icons.arrow_forward,
              color: canGoForward ? Colors.black87 : Colors.black26,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMahaDashaTimeline(DashaTimelineData data, DashaProvider provider) {
    return ListView.separated(
      key: const ValueKey('maha_dasha_list'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: data.mahaDashas.length,
      separatorBuilder: (context, index) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        final dasha = data.mahaDashas[index];
        return _buildDashaPeriod(
          dasha,
          onTap: () => provider.selectMahaDasha(dasha),
          isMahaDasha: true,
        );
      },
    );
  }

  Widget _buildAntarDashaTimeline(DashaPeriod mahaDasha, DashaProvider provider) {
    if (mahaDasha.antardashas == null || mahaDasha.antardashas!.isEmpty) {
      return const Center(child: Text('No Antar Dasha data available'));
    }

    final currentMahaIndex = provider.dashaData!.mahaDashas.indexOf(mahaDasha);
    final canGoBackMaha = currentMahaIndex > 0;
    final canGoForwardMaha = currentMahaIndex < provider.dashaData!.mahaDashas.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.separated(
            key: const ValueKey('antar_dasha_list'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mahaDasha.antardashas!.length + 1,  // +1 for main dasha
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Only the Maha Dasha container gets navigation arrows
                return Column(
                  children: [
                    Expanded(
                      child: _buildDashaPeriod(
                        mahaDasha,
                        isMainDasha: true,
                        isMahaDasha: true,
                      ),
                    ),
                    _buildNavigationArrows(
                      provider,
                      canGoBackMaha,
                      canGoForwardMaha,
                      () {
                        final prevMaha = provider.dashaData!.mahaDashas[currentMahaIndex - 1];
                        provider.selectMahaDasha(prevMaha);
                      },
                      () {
                        final nextMaha = provider.dashaData!.mahaDashas[currentMahaIndex + 1];
                        provider.selectMahaDasha(nextMaha);
                      },
                    ),
                  ],
                );
              }
              
              final antarDasha = mahaDasha.antardashas![index - 1];
              return _buildDashaPeriod(
                antarDasha,
                isAntarDasha: true,
                onTap: antarDasha.pratyantarDashas != null &&
                        antarDasha.pratyantarDashas!.isNotEmpty
                    ? () => provider.selectAntarDasha(antarDasha)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPratyantarDashaTimeline(
    DashaPeriod mahaDasha,
    DashaPeriod antarDasha,
  ) {
    if (antarDasha.pratyantarDashas == null ||
        antarDasha.pratyantarDashas!.isEmpty) {
      return const Center(child: Text('No Pratyantar Dasha data available'));
    }

    return Consumer<DashaProvider>(
      builder: (context, provider, child) {
        final currentMahaIndex = provider.dashaData!.mahaDashas.indexOf(mahaDasha);
        final canGoBackMaha = currentMahaIndex > 0;
        final canGoForwardMaha = currentMahaIndex < provider.dashaData!.mahaDashas.length - 1;

        final currentAntarIndex = mahaDasha.antardashas!.indexOf(antarDasha);
        final canGoBackAntar = currentAntarIndex > 0;
        final canGoForwardAntar = currentAntarIndex < mahaDasha.antardashas!.length - 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.separated(
                key: const ValueKey('pratyantar_dasha_list'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: antarDasha.pratyantarDashas!.length + 2,  // +2 for maha and antar dashas
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Maha Dasha container with navigation arrows
                    return Column(
                      children: [
                        Expanded(
                          child: _buildDashaPeriod(
                            mahaDasha,
                            isMainDasha: true,
                            isMahaDasha: true,
                          ),
                        ),
                        _buildNavigationArrows(
                          provider,
                          canGoBackMaha,
                          canGoForwardMaha,
                          () {
                            final prevMaha = provider.dashaData!.mahaDashas[currentMahaIndex - 1];
                            provider.selectMahaDasha(prevMaha);
                          },
                          () {
                            final nextMaha = provider.dashaData!.mahaDashas[currentMahaIndex + 1];
                            provider.selectMahaDasha(nextMaha);
                          },
                        ),
                      ],
                    );
                  }
                  if (index == 1) {
                    // Antar Dasha container with navigation arrows
                    return Column(
                      children: [
                        Expanded(
                          child: _buildDashaPeriod(
                            antarDasha,
                            isMainDasha: true,
                            isAntarDasha: true,
                          ),
                        ),
                        _buildNavigationArrows(
                          provider,
                          canGoBackAntar,
                          canGoForwardAntar,
                          () {
                            final prevAntar = mahaDasha.antardashas![currentAntarIndex - 1];
                            provider.selectAntarDasha(prevAntar);
                          },
                          () {
                            final nextAntar = mahaDasha.antardashas![currentAntarIndex + 1];
                            provider.selectAntarDasha(nextAntar);
                          },
                        ),
                      ],
                    );
                  }
                  
                  final pratyantarDasha = antarDasha.pratyantarDashas![index - 2];
                  return _buildDashaPeriod(
                    pratyantarDasha,
                    isPratyantarDasha: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashaPeriod(
    DashaPeriod dasha, {
    VoidCallback? onTap,
    bool isMainDasha = false,
    bool isAntarDasha = false,
    bool isPratyantarDasha = false,
    bool isMahaDasha = false,
  }) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    
    // Calculate duration in years, months, and days
    final Duration duration = dasha.endDate.difference(dasha.startDate);
    final int years = duration.inDays ~/ 365;
    final int months = (duration.inDays % 365) ~/ 30;
    final int days = (duration.inDays % 365) % 30;
    
    // Format duration to only show non-zero units
    String formattedDuration = '';
    if (years > 0) formattedDuration += '${years}Y ';
    if (months > 0 || (years > 0 && days > 0)) formattedDuration += '${months}M ';
    if (days > 0 || formattedDuration.isEmpty) formattedDuration += '${days}D';
    formattedDuration = formattedDuration.trim();

    // Fixed dimensions for all dasha types
    const double tileWidth = 120.0;
    const double containerHeight = 110.0;  // Reduced from 120
    const double fontSize = 14.0;
    const double dateFontSize = 10.0;
    const double durationFontSize = 12.0;
    const double paddingSize = 6.0;  // Reduced from 8

    // Get planet color for text
    final planetColor = _getPlanetColor(dasha.planet);

    return SizedBox(
      width: tileWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: containerHeight,
              width: double.infinity,
              padding: const EdgeInsets.all(paddingSize),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.black.withOpacity(isMahaDasha ? 0.8 : isAntarDasha ? 0.6 : 0.4),
                  width: isMahaDasha ? 2 : isAntarDasha ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    dasha.planet,
                    style: TextStyle(
                      color: planetColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From - ${dateFormat.format(dasha.startDate)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: dateFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'To - ${dateFormat.format(dasha.endDate)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: dateFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Only show touch indicator for pratyantar dasha containers
                  if (onTap != null && isPratyantarDasha) ...[
                    const Icon(
                      Icons.touch_app,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedDuration,
            style: const TextStyle(
              fontSize: durationFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanetColor(String planet) {
    switch (planet.toLowerCase()) {
      case 'sun':
        return Colors.orange;
      case 'moon':
        return Colors.blue;
      case 'mars':
        return Colors.red;
      case 'mercury':
        return Colors.green;
      case 'jupiter':
        return Colors.purple;
      case 'venus':
        return Colors.pink;
      case 'saturn':
        return Colors.grey;
      case 'rahu':
        return Colors.brown;
      case 'ketu':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}