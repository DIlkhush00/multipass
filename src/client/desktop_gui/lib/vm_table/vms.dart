import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart' hide Table, Switch;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalogue.dart';
import '../providers.dart';
import '../sidebar.dart';
import '../switch.dart';
import 'bulk_actions.dart';
import 'cell_builders.dart';
import 'header_selection.dart';
import 'search_box.dart';
import 'table.dart';
import 'vm_table_headers.dart';

final runningOnlyProvider = StateProvider((_) => false);
final selectedVmsProvider = StateProvider<BuiltSet<String>>((ref) {
  // if any filter is applied (either name or show running only), the provider
  // will be invalidated and return the empty set again
  ref.watch(runningOnlyProvider);
  ref.watch(searchNameProvider);
  // look for changes in available vms and make sure this set does not contain
  // vm names that are no longer present
  ref.listen(vmNamesProvider, (_, availableNames) {
    ref.controller.update(availableNames.intersection);
  });

  return BuiltSet();
});

class Vms extends ConsumerWidget {
  const Vms({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    goToCatalogue() {
      ref.read(sidebarKeyProvider.notifier).state = CatalogueScreen.sidebarKey;
    }

    final heading = Row(children: [
      const Expanded(
        child: Text(
          'All Instances',
          style: TextStyle(fontSize: 37, fontWeight: FontWeight.w300),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      TextButton(
        onPressed: goToCatalogue,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xff0E8620),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
        child: const Text('Launch image'),
      )
    ]);

    final searchName = ref.watch(searchNameProvider);
    final runningOnly = ref.watch(runningOnlyProvider);
    final vmFilters = Row(children: [
      Switch(
        value: runningOnly,
        onChanged: (v) => ref.read(runningOnlyProvider.notifier).state = v,
      ),
      const SizedBox(width: 8),
      const Expanded(
        child: Text(
          'Show running instances only',
          style: TextStyle(fontSize: 16),
        ),
      ),
      const SearchBox(),
      const SizedBox(width: 8),
      const HeaderSelection(),
    ]);

    final enabledHeaderNames = ref.watch(enabledHeadersProvider);
    final enabledHeaders =
        headers.where((h) => enabledHeaderNames[h.name]!).toList();

    var infos = ref.watch(vmInfosProvider);

    updateCpuUsages(infos);

    infos = infos
        .where((i) => !runningOnly || i.instanceStatus.status == Status.RUNNING)
        .where((i) => i.name.contains(searchName))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 52),
      child: Column(children: [
        heading,
        const SizedBox(height: 35),
        vmFilters,
        const BulkActionsBar(),
        const SizedBox(height: 10),
        SizedBox(
          height: (infos.length + 2) * 50 + 10,
          child: Table<VmInfo>(
            headers: enabledHeaders,
            data: infos.toList(),
            finalRow: totalUsageRow(infos, enabledHeaderNames.asMap()),
          ),
        ),
      ]),
    );
  }
}
