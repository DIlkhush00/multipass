import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../catalogue.dart';
import '../sidebar.dart';
import '../text_span_ext.dart';

class NoVms extends ConsumerWidget {
  const NoVms({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multipassLogo = SvgPicture.asset(
      'assets/multipass.svg',
      width: 40,
      colorFilter: const ColorFilter.mode(
        Color(0xffD9D9D9),
        BlendMode.srcIn,
      ),
    );

    goToCatalogue() {
      ref.read(sidebarKeyProvider.notifier).state = CatalogueScreen.sidebarKey;
    }

    final launchPrimary = TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xff0E8620),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: const Text('Launch primary image'),
    );

    return Center(
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            multipassLogo,
            const SizedBox(height: 22),
            const Text('Zero Instances', style: TextStyle(fontSize: 21)),
            const SizedBox(height: 8),
            Text.rich([
              'Return to the '.span,
              'Catalogue'.span.link(ref, goToCatalogue),
              ' to choose your instance or get started with the primary Ubuntu Image'
                  .span,
            ].spans.size(16)),
            const SizedBox(height: 24),
            launchPrimary,
          ],
        ),
      ),
    );
  }
}
