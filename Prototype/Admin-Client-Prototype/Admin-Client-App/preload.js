const os = require("os");
const path = require("path");
const Toastify = require("toastify-js");
const {contextBridge, ipcRenderer} = require("electron");


// adds security to the Inter Process Communication
contextBridge.exposeInMainWorld("ipcRenderer", {
    send: (channel, data) => {

        // whitelist channels to listen to.
        let validChannels = ["connected", "play", "pause", "snapshot", "Toastify", "wStats", "stats", "connected"];
        if (validChannels.includes(channel)) {
            console.log(channel)
            // Send an asynchronous message to the main process
            // via channel, along with arguments.
            ipcRenderer.send(channel, data);
        }
    }, on: (channel, func) => {

        // whitelist channels to listen to.
        let validChannels = ["createChart", "addToChart", // chartjs
            "wStats", "stats", // pop Stats or Main window Stats
            "done", "connected", "error", "Toastify", // toasts
            "play", "pause", "snapshot" // controls
        ];

        if (validChannels.includes(channel)) {
            console.log(channel)
            // Listens to channel,
            // when a new message arrives listener would be called with listener(event, args...).
            ipcRenderer.on(channel, (event, ...args) => func(...args));
        }
    }
});


contextBridge.exposeInMainWorld("os", {
    homedir: () => os.homedir(),
});

contextBridge.exposeInMainWorld("path", {
    join: () => path.join(),
});

contextBridge.exposeInMainWorld("Toastify", {
    toast: (options) => Toastify(options).showToast(),
});

