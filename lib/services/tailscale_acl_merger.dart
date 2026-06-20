import 'package:rumah/services/tailscale_acl_builder.dart';

/// Merges rumahkita house ACL fragments into a full Tailscale policy document.
class TailscaleAclMerger {
  TailscaleAclMerger._();

  static final _houseTagPattern = RegExp(r'^tag:house-');

  /// Merges [houseFragments] into [currentPolicy], prepending rumah house ACL
  /// rules before non-rumah rules and preserving unrelated policy sections.
  static Map<String, dynamic> merge({
    required Map<String, dynamic> currentPolicy,
    required List<Map<String, dynamic>> houseFragments,
  }) {
    final merged = Map<String, dynamic>.from(currentPolicy);

    final tagOwners = Map<String, dynamic>.from(
      (merged['tagOwners'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    for (final key in tagOwners.keys.toList()) {
      if (_houseTagPattern.hasMatch(key)) {
        tagOwners.remove(key);
      }
    }
    for (final fragment in houseFragments) {
      final fragmentOwners =
          (fragment['tagOwners'] as Map?)?.cast<String, dynamic>() ?? {};
      tagOwners.addAll(fragmentOwners);
    }
    if (tagOwners.isNotEmpty) {
      merged['tagOwners'] = tagOwners;
    } else {
      merged.remove('tagOwners');
    }

    final existingAcls = (merged['acls'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        <Map<String, dynamic>>[];

    final nonRumahAcls = existingAcls.where(_isNonRumahAcl).toList();

    final rumahAcls = <Map<String, dynamic>>[];
    for (final fragment in houseFragments) {
      final fragmentAcls = (fragment['acls'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          <Map<String, dynamic>>[];
      rumahAcls.addAll(fragmentAcls);
    }

    merged['acls'] = [...rumahAcls, ...nonRumahAcls];
    return merged;
  }

  static bool _isNonRumahAcl(Map<String, dynamic> rule) {
    for (final field in ['src', 'dst']) {
      final values = rule[field];
      if (values is List) {
        for (final value in values) {
          if (value is String && _houseTagPattern.hasMatch(value)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Extracts rumah house IDs present in a policy's tagOwners.
  static Set<String> rumahHouseIdsInPolicy(Map<String, dynamic> policy) {
    final tagOwners =
        (policy['tagOwners'] as Map?)?.cast<String, dynamic>() ?? {};
    return tagOwners.keys
        .where(_houseTagPattern.hasMatch)
        .map((tag) => tag.substring('tag:house-'.length))
        .toSet();
  }

  /// Validates that [policy] has the minimum structure for a safe POST.
  static bool isWellFormedPolicy(Map<String, dynamic> policy) {
    if (policy.isEmpty) {
      return false;
    }
    final acls = policy['acls'];
    if (acls != null && acls is! List) {
      return false;
    }
    final tagOwners = policy['tagOwners'];
    if (tagOwners != null && tagOwners is! Map) {
      return false;
    }
    return true;
  }

  /// Whether a wildcard accept rule would take precedence over rumah denies.
  ///
  /// Tailscale evaluates ACLs top-to-bottom; rumah rules are prepended so house
  /// denies win over later wildcard accepts in the tailnet policy.
  static bool rumahRulesPrecedeWildcardAccept({
    required Map<String, dynamic> mergedPolicy,
    required String houseId,
  }) {
    final acls = (mergedPolicy['acls'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        <Map<String, dynamic>>[];
    final tag = TailscaleAclBuilder.houseTag(houseId);

    int? rumahDenyIndex;
    int? wildcardAcceptIndex;
    for (var i = 0; i < acls.length; i++) {
      final rule = acls[i];
      if (rule['action'] == 'deny' &&
          _ruleReferencesTag(rule, tag) &&
          rumahDenyIndex == null) {
        rumahDenyIndex = i;
      }
      if (rule['action'] == 'accept' && _isWildcardAccept(rule)) {
        wildcardAcceptIndex = i;
        break;
      }
    }
    if (rumahDenyIndex == null || wildcardAcceptIndex == null) {
      return true;
    }
    return rumahDenyIndex < wildcardAcceptIndex;
  }

  static bool _ruleReferencesTag(Map<String, dynamic> rule, String tag) {
    for (final field in ['src', 'dst']) {
      final values = rule[field];
      if (values is List && values.contains(tag)) {
        return true;
      }
    }
    return false;
  }

  static bool _isWildcardAccept(Map<String, dynamic> rule) {
    if (rule['action'] != 'accept') {
      return false;
    }
    final src = rule['src'];
    final dst = rule['dst'];
    return src is List &&
        src.contains('*') &&
        dst is List &&
        (dst.contains('*') || dst.isEmpty);
  }
}
