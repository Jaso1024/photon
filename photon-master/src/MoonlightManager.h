#pragma once

#include <QObject>
#include <QProcess>
#include <QWidget>
#include <memory>
#include <map>

class RemotePC;

class MoonlightManager : public QObject
{
    Q_OBJECT

public:
    explicit MoonlightManager(QObject *parent = nullptr);
    ~MoonlightManager();
    
    // Connect to a PC and return a widget for display
    QWidget* connectToPC(const RemotePC &pc, int index);
    
    // Disconnect from a specific PC
    void disconnect(int index);
    
    // Disconnect from all PCs
    void disconnectAll();
    
signals:
    void connectionStateChanged(int index, bool connected);
    void errorOccurred(int index, const QString &error);
    
private slots:
    void handleProcessError(QProcess::ProcessError error);
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    
private:
    struct MoonlightInstance {
        std::unique_ptr<QProcess> process;
        std::unique_ptr<QWidget> widget;
        bool connected = false;
    };
    
    std::map<int, MoonlightInstance> m_instances;
    QString m_moonlightPath;
    
    QString findMoonlightExecutable();
    QStringList buildMoonlightArgs(const RemotePC &pc);
};