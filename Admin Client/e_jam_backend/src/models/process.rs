use serde::{Deserialize, Serialize};

#[doc = r"Processes that are running on the device either a verification process or a generation process
each process has a status (Type: ProcessStatus) that can be one of the following
Idle, Running, Offline, Paused, Completed, Failed
each process has a name that is a string that represents both the name of the process and the device that is running the process (Device IP address + Port number)
## Variants
* `Generation` (the process is a generation process)
* `Verification` (the process is a verification process)
* `GenerationAndVerification` (the process is a generation and verification process)"]
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

impl ToString for ProcessType {
    fn to_string(&self) -> String {
        match self {
            ProcessType::Generation => "Generation".to_string(),
            ProcessType::Verification => "Verification".to_string(),
            ProcessType::GenerationaAndVerification => "GenerationaAndVerification".to_string(),
        }
    }
}

#[doc = r"process status
a process has a status that represents the current state of the stream in the specific device
each process has a type (Type: ProcessType) that can be one of the following
Generation, Verification, GenerationAndVerification
each process has a name that is a string that represents both the name of the process and the device that is running the process (Device IP address + Port number)
## Variants
* `Queued` (the process is idle and waiting to be started)
* `Running` (the process is running) 
* `Stopped` (the process is Stopped)
* `Completed` (the process is successfully completed)
* `Failed` (the process is failed)"]
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(tag = "processstatus")]
pub enum ProcessStatus {
    #[default]
    #[serde(rename = "Queued")]
    Queued,

    #[serde(rename = "Running")]
    Running,

    #[serde(rename = "Stopped")]
    Stopped,

    #[serde(rename = "Completed")]
    Completed,

    #[serde(rename = "Failed")]
    Failed,
}

impl ToString for ProcessStatus {
    fn to_string(&self) -> String {
        match self {
            ProcessStatus::Queued => "Queued".to_string(),
            ProcessStatus::Running => "Running".to_string(),
            ProcessStatus::Stopped => "Stopped".to_string(),
            ProcessStatus::Completed => "Completed".to_string(),
            ProcessStatus::Failed => "Failed".to_string(),
        }
    }
}
