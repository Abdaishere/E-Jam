enum StreamStatus {
  created,
  queued,
  running,
  finished,
  error,
  stopped,
}

// convert stream status to StreamStatus enum
StreamStatus streamStatusFromString(String status) {
  switch (status) {
    case 'Created':
      return StreamStatus.created;
    case 'Sent':
      return StreamStatus.queued;
    case 'Queued':
      return StreamStatus.queued;
    case 'Running':
      return StreamStatus.running;
    case 'Finished':
      return StreamStatus.finished;
    case 'Error':
      return StreamStatus.error;
    case 'Stopped':
      return StreamStatus.stopped;
    default:
      return StreamStatus.created;
  }
}

String streamStatusToString(StreamStatus streamStatus) {
  switch (streamStatus) {
    case StreamStatus.created:
      return 'Created';
    case StreamStatus.queued:
      return 'Queued';
    case StreamStatus.running:
      return 'Running';
    case StreamStatus.finished:
      return 'Finished';
    case StreamStatus.error:
      return 'Error';
    case StreamStatus.stopped:
      return 'Stopped';
    default:
      return 'Created';
  }
}

enum TransportLayerProtocol {
  tcp,
  udp,
}

// convert transport layer protocol to TransportLayerProtocol enum
TransportLayerProtocol transportLayerProtocolFromString(String protocol) {
  switch (protocol) {
    case 'TCP':
      return TransportLayerProtocol.tcp;
    case 'UDP':
      return TransportLayerProtocol.udp;
    default:
      return TransportLayerProtocol.tcp;
  }
}

String transportLayerProtocolToString(TransportLayerProtocol protocol) {
  switch (protocol) {
    case TransportLayerProtocol.tcp:
      return 'TCP';
    case TransportLayerProtocol.udp:
      return 'UDP';
    default:
      return 'TCP';
  }
}

enum FlowType {
  backToBack,
  bursts,
}

// convert flow type to FlowType enum
FlowType flowTypeFromString(String flowType) {
  switch (flowType) {
    case 'BackToBack':
      return FlowType.backToBack;
    case 'Bursts':
      return FlowType.bursts;
    default:
      return FlowType.backToBack;
  }
}

String flowTypeToString(FlowType flowType) {
  switch (flowType) {
    case FlowType.backToBack:
      return 'BackToBack';
    case FlowType.bursts:
      return 'Bursts';
    default:
      return 'BackToBack';
  }
}
