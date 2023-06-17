use serde::{Deserialize, Serialize};

#[doc = r" ## ProcessType
Processes that are running on the device either a verification process or a generation process or both
## Variants
* `Generation` (the process is a generation process)
* `Verification` (the process is a verification process)
* `GenerationAndVerification` (the process is a generation and verification process)"]
#[derive(Serialize, Deserialize, Debug, Clone, PartialEq)]
#[serde(rename_all = "PascalCase")]
pub enum ProcessType {
    Generation,
    Verification,
    GeneratingAndVerification,
}

#[doc = r"## ProcessStatus
a process has a status that represents the current state of the stream in the specific device
each process has a type (Type: ProcessType) that can be one of the following
Generation, Verification, GenerationAndVerification
each process has a Mac Address (MacAddress: string) that represents the mac address of the device that is running the process.
## Variants
* `Queued` (the process is idle and waiting to be started)
* `Running` (the process is running) 
* `Stopped` (the process is Stopped)
* `Completed` (the process is successfully completed)
* `Failed` (the process is failed)
## See also
The Process State Machine: ./docs/process_state_machine.png
The Process State Machine is a state machine that represents the state of a process in the device and the possible transitions between states"]
#[derive(Serialize, Deserialize, Default, Debug, Clone, PartialEq)]
#[serde(rename_all = "PascalCase")]
pub enum ProcessStatus {
    #[default]
    Queued,
    Running,
    Stopped,
    Completed,
    Failed,
}
