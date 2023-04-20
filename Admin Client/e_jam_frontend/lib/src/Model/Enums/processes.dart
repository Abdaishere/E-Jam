enum ProcessStatus {
  queued,
  running,
  stopped,
  completed,
  failed,
}

ProcessStatus processStatusFromString(String status) {
  switch (status) {
    case 'Queued':
      return ProcessStatus.queued;
    case 'Running':
      return ProcessStatus.running;
    case 'Stopped':
      return ProcessStatus.stopped;
    case 'Completed':
      return ProcessStatus.completed;
    case 'Failed':
      return ProcessStatus.failed;
    default:
      return ProcessStatus.failed;
  }
}

String processStatusToString(ProcessStatus? processStatus) {
  switch (processStatus) {
    case ProcessStatus.queued:
      return 'Queued';
    case ProcessStatus.running:
      return 'Running';
    case ProcessStatus.stopped:
      return 'Stopped';
    case ProcessStatus.completed:
      return 'Completed';
    case ProcessStatus.failed:
      return 'Failed';
    default:
      return 'Failed';
  }
}

enum ProcessType {
  generation,
  verification,
  generatingAndVerification,
}

ProcessType processTypeFromString(String type) {
  switch (type) {
    case 'Generation':
      return ProcessType.generation;
    case 'Verification':
      return ProcessType.verification;
    case 'GeneratingAndVerification':
      return ProcessType.generatingAndVerification;
    default:
      return ProcessType.generatingAndVerification;
  }
}

String processTypeToString(ProcessType processType) {
  switch (processType) {
    case ProcessType.generation:
      return 'Generation';
    case ProcessType.verification:
      return 'Verification';
    case ProcessType.generatingAndVerification:
      return 'GeneratingAndVerification';
    default:
      return 'GeneratingAndVerification';
  }
}
