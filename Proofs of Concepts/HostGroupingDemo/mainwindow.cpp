#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "devicemanager.h"

#include <QListWidget>
#include <QScrollArea>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    fillDevicesTable();
    initStreamScrollArea();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::fillDevicesTable()
{
    auto deviceTable = ui->tableWidget_deviceTable;
    DeviceManager* deviceManager = DeviceManager::getInstance();
    deviceTable->setRowCount(deviceManager->getNumberOfDevices());

    for(int i=0; i<deviceManager->getNumberOfDevices();i++)
    {
        Device d = deviceManager->devices[i];
        QTableWidgetItem* item;
        for(int j=0; j<4; j++)
        {
            QString content;
            item = new QTableWidgetItem;
            if(j==0)
                content = QString::fromStdString(d.mac_address);
            else if(j==1)
                content = QString::fromStdString(d.ip);
            else if(j==2)
                content = QString::number(d.flags);
            else if(j==3)
                content = QString::fromStdString(d.iface);

            item->setText(content);
            deviceTable->setItem(i,j,item);
        }
    }
}

void MainWindow::initStreamScrollArea()
{
    d_scroll_area_layout = new QVBoxLayout(ui->scrollAreaWidgetContents_2);
    auto d_bottom_vertical_spacer = new QSpacerItem(100, 20, QSizePolicy::Minimum, QSizePolicy::Expanding);
    d_scroll_area_layout->addItem(d_bottom_vertical_spacer);
}

QFrame* MainWindow::generateStreamFrame(int streamNumber)
{
    //Init frame
    auto mainFrame = new QFrame();
    int frameHeight = 550;
    //int frameWidth  = ui->verticalLayout_streamsLayout->geometry().width();
    mainFrame->setFixedHeight(frameHeight);
    //mainFrame->setStyleSheet("background-color: rgb(80, 80, 80);"); //enforce a color out of palette


    //add grid layout
    auto layout = new QGridLayout;
    mainFrame->setLayout(layout);
    int row= 0;

    //add frame title
    auto lbl_frameTitle = new QLabel("Stream #"+ QString::number(streamNumber));
    lbl_frameTitle->setFont(QFont("Arial", 14, QFont::Bold));
    layout->addWidget(lbl_frameTitle,row,4,1,-1);
    row++;

    //add lists titles
    auto lbl_genTitle = new QLabel("Generating Devices");
    lbl_genTitle->setFont(QFont("Arial", 10, QFont::Bold));
    auto lbl_verTitle = new QLabel("Verifying Devices");
    lbl_verTitle->setFont(QFont("Arial", 10, QFont::Bold));
    layout->addWidget(lbl_genTitle,row,0);
    layout->addWidget(lbl_verTitle,row,8);
    row++;

    //generators list
    auto lst_genList = new QListView;
    layout->addWidget(lst_genList,row,0,1,4);

    //verfiyers list
    auto lst_verList = new QListView;
    layout->addWidget(lst_verList,row,5,1,4);
    row++;

    //generator plus, minus buttons
    auto pb_genPlus = new QPushButton;
    pb_genPlus->setText("add");
    layout->addWidget(pb_genPlus,row,1);
    auto pb_genMin = new QPushButton;
    pb_genMin->setText("remove");
    layout->addWidget(pb_genMin,row,2);

    //verfiyer plus, minus buttons
    auto pb_verPlus = new QPushButton;
    pb_verPlus->setText("add");
    layout->addWidget(pb_verPlus,row,6);
    auto pb_verMin = new QPushButton;
    pb_verMin->setText("remove");
    layout->addWidget(pb_verMin,row,7);
    row++;

    //edit packet format button
    auto pb_editPacket = new QPushButton;
    pb_editPacket->setText("Edit packet format...");
    layout->addWidget(pb_editPacket,row,0,1,-1);

    /*
    //Frame title
    auto lbl_frameTitle = new QLabel(mainFrame);
    lbl_frameTitle->setText("Stream #"+ QString::number(streamNumber));
    lbl_frameTitle->setGeometry(0.45*frameWidth,0.02*frameHeight,150,20);
    lbl_frameTitle->setFont(QFont("Arial", 14, QFont::Bold));

    //generators list
    auto lst_genList = new QListView(mainFrame);
    lst_genList->setGeometry(0.05*frameWidth,0.1*frameHeight,200,200);*/



    return mainFrame;
}

void MainWindow::on_pushButton_addStream_clicked()
{
    static int num = 1; //TODO replace with actual stream data (Stream manager)
    auto new_widget_item = generateStreamFrame(num++);
    d_scroll_area_layout->addWidget(new_widget_item);


    auto separator = new QFrame;
    separator->setFixedHeight(5);
    separator->setStyleSheet("background-color: rgb(120, 120, 120);");
    d_scroll_area_layout->addWidget(separator);
}

