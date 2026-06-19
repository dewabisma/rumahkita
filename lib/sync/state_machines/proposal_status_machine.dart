import 'package:rumah/domain/enums/proposal_status.dart';

class ProposalStatusMachine {
  ProposalStatusMachine._();

  static const Set<ProposalStatus> terminalStates = {
    ProposalStatus.executed,
    ProposalStatus.cancelled,
    ProposalStatus.rejected,
  };

  static bool canTransition(ProposalStatus? from, ProposalStatus to) {
    if (from != null && terminalStates.contains(from)) {
      return false;
    }
    if (from == null) {
      return to == ProposalStatus.proposed;
    }
    switch (from) {
      case ProposalStatus.proposed:
        return {
          ProposalStatus.approved,
          ProposalStatus.readyToExecute,
          ProposalStatus.cancelled,
          ProposalStatus.rejected,
        }.contains(to);
      case ProposalStatus.approved:
        return to == ProposalStatus.readyToExecute;
      case ProposalStatus.readyToExecute:
        return to == ProposalStatus.executed;
      case ProposalStatus.executed:
      case ProposalStatus.cancelled:
      case ProposalStatus.rejected:
        return false;
    }
  }

  static bool isSelfRemovalShortcut(ProposalStatus? from, ProposalStatus to) {
    return from == ProposalStatus.proposed &&
        to == ProposalStatus.readyToExecute;
  }
}
