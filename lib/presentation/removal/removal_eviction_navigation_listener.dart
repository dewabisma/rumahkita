import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/presentation/onboarding/onboarding_providers.dart';

/// Navigates to welcome when the local member is evicted.
class RemovalEvictionNavigationListener extends ConsumerWidget {
  const RemovalEvictionNavigationListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(localMemberProvider, (prev, next) {
      final prevStatus = prev?.asData?.value?.memberStatus;
      final nextStatus = next.asData?.value?.memberStatus;
      if (prevStatus != MemberStatus.evicted &&
          nextStatus == MemberStatus.evicted &&
          context.mounted) {
        context.pushReplacement('/welcome');
      }
    });

    ref.listen(activeHouseIdProvider, (prev, next) {
      final hadHouse = prev?.asData?.value != null;
      final noHouse = next.asData?.value == null;
      if (hadHouse && noHouse && context.mounted) {
        context.pushReplacement('/welcome');
      }
    });

    return child;
  }
}
