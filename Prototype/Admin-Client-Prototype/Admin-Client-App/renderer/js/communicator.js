import {renderHome} from "./homeRenderer.js";
import {renderTable} from "./tablesRenderer.js";
import {renderCharts} from "./chartsRenderer.js";

// #up-rate,#down-rate,#pending,#received,#error,#a-total,#r-total,#total
export let pendingNum = 0, ErrorsTotalNum = 0, AcceptedTotalNum = 0, totalVal = 0;
export let acceptedNum = 0, errors = 0, downRateVal = 0, sentVal = 0, upRateVal = 0;

export async function updateData(value) {
    if (value["Verifier"] == true)
        updateDownData(value);
    else
        updateUpData(value)
}

export function updateDownData(value) {
    downRateVal = value["Rate"]
    errors = value["ErrorTotal"]

    acceptedNum = value["Total"] - errors
    pendingNum -= acceptedNum
    acceptedNum -= errors
    ErrorsTotalNum += errors
    AcceptedTotalNum += acceptedNum
}

export function updateUpData(value) {
    upRateVal = value["Rate"]
    sentVal = value["Total"]

    totalVal += sentVal
    pendingNum += sentVal
}

export function alertSuccess(message) {
    Toastify.toast({
        text: message,
        duration: 2000,
        close: false,
        style: {
            background: "green",
            color: "white",
            textAlign: "center",
        },
    });
}

export function alertError(message) {
    Toastify.toast({
        text: message,
        duration: 3500,
        close: false,
        style: {
            background: "red",
            color: "white",
            textAlign: "center",
        },
    });
}

export function alertMessage(message) {
    Toastify.toast({
        text: message,
        duration: 1500,
        close: false,
        style: {
            background: "darkorange",
            color: "white",
            textAlign: "center",
        },
    });
}

// When done saving logs, show message
ipcRenderer.on("done", () => alertSuccess(`Logs Saved Successfully`));

// When paused, show message
ipcRenderer.on("pause", () => alertMessage(`Monitoring Paused`));

// When played, show message
ipcRenderer.on("play", () => alertMessage(`Monitoring Resumed`));

// When connected, show message
ipcRenderer.on("connected", () => alertSuccess(`Connected to Stream`));

// When error in stream, show message
ipcRenderer.on("error", () => alertError(`Cannot Connect to Stream`));

ipcRenderer.on("stats", async (value) => {
    console.log(value)
    updateData(value).then(() => {
        renderHome(value["Verifier"])
        renderTable(value);
        renderCharts(value["Verifier"]);
    })
});