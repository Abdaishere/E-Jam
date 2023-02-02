import {AcceptedTotalNum, ErrorsTotalNum, pendingNum, downRateVal, upRateVal, updateData} from "./communicator.js";


const colors = {
    upload: {
        default: "rgba(149, 76, 233, 1)",
        half: "rgba(149, 76, 233, 0.5)",
        quarter: "rgba(149, 76, 233, 0.25)",
        zero: "rgba(149, 76, 233, 0)"
    }, download: {
        default: "rgba(12, 205, 163, 1)",
        half: "rgba(12, 205, 163, 0.5)",
        quarter: "rgba(12, 205, 163, 0.25)",
        zero: "rgba(12, 205, 163, 0)"
    }, indigo: {
        default: "rgb(165,184,201)", quarter: "rgba(215,202,202,0.8)"
    }
};

var lineChart, doughnutChart;

function loadLineChart() {
    const ctx = document.getElementById("canvasL").getContext("2d");

    let gradientUpload = ctx.createLinearGradient(0, 25, 0, 300);
    gradientUpload.addColorStop(0, colors.upload.half);
    gradientUpload.addColorStop(0.35, colors.upload.quarter);
    gradientUpload.addColorStop(1, colors.upload.zero);

    let gradientDownload = ctx.createLinearGradient(0, 25, 0, 300);
    gradientDownload.addColorStop(0, colors.download.half);
    gradientDownload.addColorStop(0.35, colors.download.quarter);
    gradientDownload.addColorStop(1, colors.download.zero);

    const config = {
        type: "line", data: {
            labels: [0], datasets: [{
                label: 'Upload',
                fill: true,
                backgroundColor: gradientUpload,
                pointBackgroundColor: colors.upload.default,
                borderColor: colors.upload.default,
                data: [0, 54353453, 5435, 33, 45],
                lineTension: 0.2,
                borderWidth: 2,
                pointRadius: 3,
            }, {
                label: 'Download',
                fill: true,
                backgroundColor: gradientDownload,
                pointBackgroundColor: colors.download.default,
                borderColor: colors.download.default,
                data: [0, 342, 2, 3, 4],
                lineTension: 0.2,
                borderWidth: 2,
                pointRadius: 3
            }]
        }, options: {
            layout: {
                padding: 10
            }, responsive: false, legend: {
                display: false
            },

            scales: {
                x: {
                    gridLines: {
                        display: false
                    }, ticks: {
                        padding: 10, autoSkip: false, maxRotation: 85, minRotation: 85
                    }
                }, y: {
                    scaleLabel: {
                        display: true, labelString: "Rate of Transfer", padding: 10
                    }, gridLines: {
                        display: true, color: colors.indigo.quarter
                    }, ticks: {
                        callback: function (value) {
                            return value + ' B/s';
                        }, padding: 10
                    }, beginAtZero: true
                }
            }, plugins: {
                zoom: {
                    pan: {
                        enabled: true,
                        modifierKey: 'ctrl'
                    }, limits: {
                        x: {min: 0},
                        y: {min: 0}
                    },
                    zoom: {
                        wheel: {
                            enabled: true,
                            mode: 'y'
                        }
                    }
                }
            }
        }
    };
    lineChart = new Chart(ctx, config);
}

function loadDoughnutChart() {
    const ctx = document.getElementById("canvasD").getContext("2d");

    const config = {
        type: 'doughnut', data: {
            labels: ['Accepted Packets', 'Rejected Packets', 'Pending Packets'], datasets: [{
                label: 'Total Packets', data: [0, 0, 0], backgroundColor: ['limegreen', 'red', 'orange'],
            }]
        }, options: {
            responsive: false, plugins: {
                legend: {
                    position: 'top',
                }, title: {
                    display: true, text: 'Total Packets'
                }
            }
        },
    };

    doughnutChart = new Chart(ctx, config);
}

window.onload = async function () {
    loadLineChart();
    loadDoughnutChart();
}

export function renderCharts(down) {
    if (down == null) {
        return;
    }
    const LData = lineChart.data;
    const DData = doughnutChart.data;

    if (down === true) {
        LData.datasets[1].data.push(downRateVal);
    } else {
        LData.datasets[0].data.push(upRateVal);
    }
    LData.labels.push("");

    DData.datasets[0].data = [AcceptedTotalNum, ErrorsTotalNum, pendingNum];


    doughnutChart.update();
    lineChart.update();
}

ipcRenderer.on("wStats", async (value) => {
    await updateData(value).then(() => renderCharts(value["Verifier"]))
});