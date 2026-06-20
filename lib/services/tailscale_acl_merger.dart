import 'package:rumah/services/tailscale_acl_builder.dart';

/// Merges rumahkita house policy fragments into a full Tailscale policy document.
class TailscaleAclMerger {
  TailscaleAclMerger._();

  static final _houseTagPattern = RegExp(r'^tag:house-');

  static bool usesGrantsSyntax(Map<String, dynamic> policy) {
    return TailscaleAclBuilder.detectSyntax(policy) ==
        TailscalePolicySyntax.grants;
  }

  /// Ensures [policy] has a baseline ACL document Tailscale accepts on POST.
  static Map<String, dynamic> normalizePolicy(Map<String, dynamic> policy) {
    if (usesGrantsSyntax(policy)) {
      return Map<String, dynamic>.from(policy);
    }

    final normalized = Map<String, dynamic>.from(policy);
    final acls = normalized['acls'];
    if (acls == null || (acls is List && acls.isEmpty)) {
      normalized['acls'] = [
        {'action': 'accept', 'src': ['*'], 'dst': ['*:*']},
      ];
    }
    return normalized;
  }

  /// Merges [houseFragments] into [currentPolicy], prepending rumah house rules
  /// before non-rumah rules and preserving unrelated policy sections.
  static Map<String, dynamic> merge({
    required Map<String, dynamic> currentPolicy,
    required List<Map<String, dynamic>> houseFragments,
  }) {
    final merged = usesGrantsSyntax(currentPolicy)
        ? Map<String, dynamic>.from(currentPolicy)
        : normalizePolicy(currentPolicy);

    _mergeTagOwners(merged, houseFragments);

    if (usesGrantsSyntax(merged)) {
      _mergeGrants(merged, houseFragments);
      return merged;
    }

    _mergeAcls(merged, houseFragments);
    return merged;
  }

  static void _mergeTagOwners(
    Map<String, dynamic> merged,
    List<Map<String, dynamic>> houseFragments,
  ) {
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
  }

  static void _mergeGrants(
    Map<String, dynamic> merged,
    List<Map<String, dynamic>> houseFragments,
  ) {
    final existingGrants = (merged['grants'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        <Map<String, dynamic>>[];

    final nonRumahGrants = existingGrants.where(_isNonRumahGrant).toList();

    final rumahGrants = <Map<String, dynamic>>[];
    for (final fragment in houseFragments) {
      final fragmentGrants = (fragment['grants'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          <Map<String, dynamic>>[];
      rumahGrants.addAll(fragmentGrants);
    }

    merged['grants'] = [...rumahGrants, ...nonRumahGrants];
  }

  static void _mergeAcls(
    Map<String, dynamic> merged,
    List<Map<String, dynamic>> houseFragments,
  ) {
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
  }

  static bool _isNonRumahGrant(Map<String, dynamic> rule) {
    return !_isRumahHouseGrant(rule);
  }

  static bool _isRumahHouseGrant(Map<String, dynamic> rule) {
    final src = rule['src'];
    final dst = rule['dst'];
    if (src is! List || dst is! List || src.length != 1 || dst.length != 1) {
      return false;
    }
    final srcTag = src.first;
    final dstTag = dst.first;
    return srcTag is String &&
        dstTag is String &&
        srcTag == dstTag &&
        _houseTagPattern.hasMatch(srcTag);
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
    if (usesGrantsSyntax(policy)) {
      final grants = policy['grants'];
      if (grants != null && grants is! List) {
        return false;
      }
      final tagOwners = policy['tagOwners'];
      if (tagOwners != null && tagOwners is! Map) {
        return false;
      }
      return true;
    }

    final normalized = normalizePolicy(policy);
    final acls = normalized['acls'];
    if (acls != null && acls is! List) {
      return false;
    }
    final tagOwners = normalized['tagOwners'];
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
