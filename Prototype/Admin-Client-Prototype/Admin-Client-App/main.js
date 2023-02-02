const path = require("path");
const {app, BrowserWindow, Menu, ipcMain, shell} = require("electron");
const {v4: uuid} = require("uuid");
const os = require("os");
const fs = require("fs");
const moment = require("moment");
const {Kafka} = require("kafkajs");

const {SchemaRegistry} = require('@kafkajs/confluent-schema-registry');
const registry = new SchemaRegistry({host: 'http://localhost:8081', clientId: "consumer_0"})

// Kafka API
let topics = ["statistics"];
const kafka = new Kafka({
    clientId: 'E-Jam App', brokers: ['localhost:9092']
})
const consumer = kafka.consumer({groupId: 'statistics_value_0'})

console.log("-==================- Starting -===================-")
fn = async function () {
    console.log(await registry.getLatestSchemaId("statistics-value"))
}

fn()

const isDev = true;
const saveLogonClose = true;
const isMac = process.platform === "darwin";

let mainWindow;
Menu.setApplicationMenu(null);

const date = function () {
    return moment().format("YYYY-MM-DD__HH-mm-ss");
};

let logData = {
    admin: os.hostname(), startTime: date(), logs: [],
};

const createMainWindow = () => {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        icon: `${__dirname}/assets/icons/Icon_256x256.ico`,
        resizable: isDev,
        webPreferences: {
            nodeIntegration: true, contextIsolation: true, preload: path.join(__dirname, "preload.js"),
        },
    });
    if (isDev) mainWindow.webContents.openDevTools({mode: 'undocked'});

    mainWindow
        .loadFile(path.join(__dirname, "./renderer/index.html"))
        .then(() => {
            logData.logs.push(formatLog("App", "App Loaded", "App loaded Main window and ready to connect", 0));
            connect();
        });
};

app.whenReady().then(() => {
    logData.logs.push(formatLog("App", "App Activate", "Creating Main Window", 1));

    createMainWindow();

    // Quit when all windows are closed.
    app.on("window-all-closed", () => {
        logData.logs.push(formatLog("App", "All Windows closed", `Quiting App${saveLogonClose ? `and Saving Logs to "${onCloseSave}"` : ""}`, 1));

        if (saveLogonClose) {
            saveLogs(logData, onCloseSave, false);
        }

        if (!isMac) app.quit();
    });

    // Open a window if none are open (macOS)
    app.on("activate", () => {
        if (BrowserWindow.getAllWindows().length === 0) createMainWindow();
    });

    // Remove variable from memory
    mainWindow.on("closed", () => {
        logData.logs.push(formatLog("App", "Main window closed", "Removing variable from memory", 1));
        mainWindow = null;
        disconnect();
    });
});

// Logs
function formatLog(logger, msg, data, logLvl = 0) {

    if (typeof data === "string" && msg !== "Data Received") data = {
        Details: data,
    };

    let newLog = {
        Timestamp: date(),
        AppName: "E-Jam Admin-Client",
        Env: isDev ? "Dev" : "Prod",
        PLT: process.platform,
        Loc: __dirname,
        Logger: logger,
        Msgs: {
            Msg: msg, Data: data, Level: ["INFO", "Debug", "Error"][logLvl], id: uuid(),
        },
    };
    if (saveLogonClose) console.log(newLog);
    return newLog;
}

const logsFile = path.join(os.homedir(), "logs");
const onCloseSave = path.join(__dirname, "logs");

// save Log
async function saveLogs(data, dest, showDir) {
    try {

        // Create destination folder if it doesn't exist
        if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest);
        }

        let name = `log_${date()}.json`;
        dest = path.join(dest, name);
        logData.logs.push(formatLog("App", "Saving Logs Data", {
            Details: "Attempting to Save Log to System Files", Target: dest,
        }, 0));
        // Write the file to the destination folder in ASCII
        fs.writeFileSync(dest, JSON.stringify(data, null, 2), "ASCII");


        logData.logs.push(formatLog("App", "Logs Saved Successfully", {
            Details: "Logs saved in System Files", Location: dest,
        }, 0));
        // Open the folder in the file explorer
        if (showDir) await shell.showItemInFolder(dest);
        return true
    } catch (err) {
        logData.logs.push(formatLog("App", "Cannot Save Logs", err, 3));
        return false
    }
}

// Respond to the save log event
ipcMain.on("snapshot", () => {
    saveLogs(logData, logsFile, true).then((r) => {
        if (r)
            mainWindow.webContents.send("done");
    });
});


consumer.on(consumer.events.CRASH, function (err) {
    mainWindow.webContents.send("error");
    logData.logs.push(formatLog("Kafka", "An error has occurred", err, 2));
});

// kafka functions
function connect() {

    consumer.subscribe({topic: topics[0], fromBeginning: false})

    consumer.run({
        eachMessage: async ({topic, message}) => {
            try {
                const decodedKey = await message.key
                const decodedValue = await registry.decode(message.value)

                logData.logs.push(formatLog("Kafka", `in ${topic} from ${decodedKey}  data Received`, decodedValue, 0));

                if (mainWindow != null) mainWindow.webContents.send("stats", decodedValue);
            } catch (e) {
                logData.logs.push(formatLog("Avro", `Cannot Deserialize`, e, 0));
            }
        },
    })
    consumer.on(consumer.events.CONNECT, () => {
        mainWindow.webContents.send("connected");
        logData.logs.push(formatLog("Kafka", "Connected", `Consumer connected and subscribed to '${topics}'`, 0));
    })
}

function disconnect() {
    consumer.disconnect();
}

function resume() {
    try {
        consumer.resume([{topic: topics[0]}]);
        mainWindow.webContents.send("play");
        logData.logs.push(formatLog("Kafka", "Consumption Resumed", "Resuming Data consumption from Server"));
    } catch (e) {
        logData.logs.push(formatLog("Kafka", "Cannot Resume Consumption", e, 2));
    }
}

function pause() {
    try {

        consumer.pause([{topic: topics[0]}]);
        mainWindow.webContents.send("pause");
        logData.logs.push(formatLog("Kafka", "Consumption Paused", "Pausing Data consumption from Server"));
    } catch (e) {
        logData.logs.push(formatLog("Kafka", "Cannot Pause Consumption", e, 2));
    }
}

ipcMain.on("play", () => {
    resume();
});

ipcMain.on("pause", () => {
    pause();
});

