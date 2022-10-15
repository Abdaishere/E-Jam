#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QFrame>
#include <QMainWindow>
#include <QVBoxLayout>


QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_pushButton_addStream_clicked();

private:
    Ui::MainWindow *ui;
    QVBoxLayout* d_scroll_area_layout;
    void fillDevicesTable();
    void initStreamScrollArea();
    QFrame* generateStreamFrame(int);
};
#endif // MAINWINDOW_H
