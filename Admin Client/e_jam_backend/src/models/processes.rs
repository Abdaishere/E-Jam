use serde::{Deserialize, Serialize};

/// Processes that are running on the device either a verification process or a generation process
/// each process has a status (Type: ProcessStatus) that can be one of the following
/// Idle, Running, Offline, Paused, Completed, Failed
/// each process has a name that is a string that represents both the name of the process and the device that is running the process (Device IP address + Port number)
/// ## Variants
/// * Generation
/// * Verification
/// * GenerationAndVerification
#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(tag = "processtype")]
pub enum ProcessType {
    #[serde(rename = "Generation")]
    Generation,
    #[serde(rename = "Verification")]
    Verification,
    #[serde(rename = "GenerationAndVerification")]
    GenerationaAndVerification,
}

/// process status
/// a process has a status that represents the current state of the stream in the specific device
/// each process has a type (Type: ProcessType) that can be one of the following
/// Generation, Verification, GenerationAndVerification
/// each process has a name that is a string that represents both the name of the process and the device that is running the process (Device IP address + Port number)
/// ## Variants
/// * Idle
/// * Running
/// * Offline
/// * Paused
/// * Completed
/// * Failed
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "processstatus")]
pub enum ProcessStatus {
    #[default]
    #[serde(rename = "Idle")]
    // the process is idle
    Idle,

    #[serde(rename = "Running")]
    // the process is running
    Running,

    #[serde(rename = "Offline")]
    // the process is offline
    Offline,

    #[serde(rename = "Paused")]
    // the process is paused
    Paused,

    #[serde(rename = "Completed")]
    // the process is successfully completed
    Completed,

    #[serde(rename = "Failed")]
    // the process is failed
    Failed,
}
