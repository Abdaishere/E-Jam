// default
import {
    pendingNum,
    ErrorsTotalNum,
    downRateVal,
    totalVal,
    errors,
    upRateVal,
    AcceptedTotalNum,
    acceptedNum,
    updateData
} from "./communicator.js";

export function renderHome(down) {
    if (down == null) {
        renderUpStream();
        renderDownStream();
        return;
    }

    if (down === true) {
        renderDownStream();
    } else {
        renderUpStream();
    }
}

function renderDownStream() {
    if (document.getElementById("home") == null) return;
    const downRate = document.getElementById("down-rate")
    const received = document.getElementById("received")
    const error = document.getElementById("error")
    const ATotal = document.getElementById("a-total")
    const RTotal = document.getElementById("r-total")
    const pending = document.getElementById("pending")

    pending.innerHTML = shortenLargeNumber(pendingNum)
    received.innerHTML = shortenLargeNumber(acceptedNum)
    error.innerHTML = shortenLargeNumber(errors)
    downRate.innerHTML = formatBytes(downRateVal)
    RTotal.innerHTML = shortenLargeNumber(ErrorsTotalNum, 8)
    ATotal.innerHTML = shortenLargeNumber(AcceptedTotalNum, 8)
}

function renderUpStream() {
    if (document.getElementById("home") == null) return;
    const upRate = document.getElementById("up-rate")
    const pending = document.getElementById("pending")
    const total = document.getElementById("total")

    pending.innerHTML = shortenLargeNumber(pendingNum)
    upRate.innerHTML = formatBytes(upRateVal)
    total.innerHTML = shortenLargeNumber(totalVal, 6)
}

// utilities
export function shortenLargeNumber(number, decimals) {
    if (!+number) return '0 <b>Pkt</b>'

    const k = 1000
    const sizes = ['<b>Pkt</b>', '<b>kPkt</b>', '<b>MPkt</b>', '<b>BPkt</b>', '<b>tPkt</b>', '<b>qPkt</b>', '<b>QPkt</b>', '<b>sPkt</b>'];

    if (number < 999999 * (decimals / 2)) return `${parseFloat(number)} ${sizes[0]}`

    const i = Math.floor(Math.log(number) / Math.log(k))
    const dm = decimals < 3 ? Math.min(i + 3, 5) : decimals

    return `${parseFloat((number / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`

}

export function formatBytes(bytes, decimals) {
    if (!+bytes) return '0 <b>Bytes/s</b>'

    const k = 1024
    const sizes = ['<b>Bytes/s</b>', '<b>KB/s</b>', '<b>MB/s</b>', '<b>GB/s</b>', '<b>TB/s</b>', '<b>PB/s</b>', '<b>EB/s</b>', '<b>ZB/s</b>', '<b>YB/s</b>'];

    if (bytes < 999999) return `${parseFloat(bytes)} ${sizes[0]}`

    const i = Math.floor(Math.log(bytes) / Math.log(k))
    const dm = decimals < 3 ? Math.min(i + 3, 5) : decimals

    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`
}

ipcRenderer.on('wStats', async value => {
    updateData(value).then(() => renderHome(value["Verifier"]))
})
