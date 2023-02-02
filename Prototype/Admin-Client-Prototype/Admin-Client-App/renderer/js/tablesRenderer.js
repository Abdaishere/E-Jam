//render tables window

// fully independent of previous data
export async function renderTable(value) {
    const uploadData = document.getElementById("uploadData");
    const downloadData = document.getElementById("downloadData");

    if (downloadData == null) return;
    if (value["Verifier"] === true) {

        downloadData.innerHTML += `
<tr>
    <td class="d-date">${value["Date"]}</td>
    <td class="d-address">${value["Source"]}</td>
    <td class="d-rate">${value["Rate"]}</td>
    <td class="d-ac">${value["Total"]}</td>
    <td class="d-rj">${value["ErrorTotal"]}</td>
</tr>`;
    } else {

        uploadData.innerHTML += `
<tr>
    <td class="d-date">${value["Date"]}</td>
    <td class="d-address">${value["Source"]}</td>
    <td class="d-rate">${value["Rate"]}</td>
    <td class="d-snt">${value["Total"]}</td>
</tr>`;
    }
}

ipcRenderer.on("wStats", (value) => {
    renderTable(value);
});