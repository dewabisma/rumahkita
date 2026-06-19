import 'package:flutter/material.dart';
import 'package:rumah/domain/entities/house_entities.dart';
import 'package:rumah/domain/enums/member_status.dart';
import 'package:rumah/theme/app_colors.dart';

class MemberRosterList extends StatelessWidget {
  const MemberRosterList({super.key, required this.members});

  final List<Housemate> members;

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.defaultTheme();

    if (members.isEmpty) {
      return Center(
        child: Text(
          'No roommates yet — invite someone to get started.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.successSurface,
              child: Text(
                member.nickname.isNotEmpty
                    ? member.nickname[0].toUpperCase()
                    : '?',
              ),
            ),
            title: Text(member.nickname),
            subtitle: Text('Rotation #${member.rotationOrderIndex ?? '-'}'),
            trailing: Icon(
              member.memberStatus == MemberStatus.active
                  ? Icons.check_circle
                  : Icons.pause_circle,
              color: member.memberStatus == MemberStatus.active
                  ? colors.sproutGreen
                  : colors.textMuted,
            ),
          ),
        );
      },
    );
  }
}
