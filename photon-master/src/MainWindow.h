#pragma once

#include <QMainWindow>
#include <QStackedWidget>
#include <QListWidget>
#include <memory>
#include <vector>

class MoonlightManager;
class RemotePC;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

protected:
    void keyPressEvent(QKeyEvent *event) override;

private slots:
    void onPCSelected(int index);
    void onPCDoubleClicked(QListWidgetItem *item);
    void switchToPC(int index);
    void refreshPCList();

private:
    void setupUI();
    void loadRemotePCs();
    
    QStackedWidget *m_stackedWidget;
    QListWidget *m_pcListWidget;
    std::unique_ptr<MoonlightManager> m_moonlightManager;
    std::vector<std::unique_ptr<RemotePC>> m_remotePCs;
    int m_currentPCIndex = -1;
};