#include "MoonlightManager.h"
#include "RemotePC.h"
#include <QProcess>
#include <QWidget>
#include <QWindow>
#include <QVBoxLayout>
#include <QLabel>
#include <QFile>
#include <QDebug>
#include <QCoreApplication>

MoonlightManager::MoonlightManager(QObject *parent)
    : QObject(parent)
{
    m_moonlightPath = findMoonlightExecutable();
    if (m_moonlightPath.isEmpty()) {
        qWarning() << "Moonlight executable not found!";
    }
}

MoonlightManager::~MoonlightManager()
{
    disconnectAll();
}

QString MoonlightManager::findMoonlightExecutable()
{
    // Try to find Moonlight executable in common locations
    QStringList possiblePaths = {
        "../moonlight-qt/build/app/moonlight",
        "/usr/bin/moonlight",
        "/usr/local/bin/moonlight",
        "C:/Program Files/Moonlight/Moonlight.exe",
        QCoreApplication::applicationDirPath() + "/moonlight"
    };
    
    for (const QString &path : possiblePaths) {
        if (QFile::exists(path)) {
            return path;
        }
    }
    
    // Try to find it in PATH
    return "moonlight";
}

QStringList MoonlightManager::buildMoonlightArgs(const RemotePC &pc)
{
    QStringList args;
    
    // Direct connection without pairing UI
    args << "stream";
    args << pc.address();
    args << "Desktop";  // Stream desktop instead of specific app
    
    // Performance and security settings
    args << "--no-quit-dialog";  // Don't show quit dialog
    args << "--windowed";        // Run in windowed mode for embedding
    args << "--framerate" << "60";
    args << "--bitrate" << "20000";  // 20 Mbps for local network
    args << "--no-audio-on-host";    // Don't play audio on host
    
    return args;
}

QWidget* MoonlightManager::connectToPC(const RemotePC &pc, int index)
{
    // Disconnect existing instance if any
    disconnect(index);
    
    // Create container widget
    auto container = std::make_unique<QWidget>();
    auto layout = new QVBoxLayout(container.get());
    layout->setContentsMargins(0, 0, 0, 0);
    
    // For now, create a placeholder
    // In production, we would embed the Moonlight window here
    auto placeholder = new QLabel(QString("Moonlight Stream: %1\n\nAddress: %2:%3\n\n"
                                         "In production, Moonlight window would be embedded here.")
                                 .arg(pc.name())
                                 .arg(pc.address())
                                 .arg(pc.port()));
    placeholder->setAlignment(Qt::AlignCenter);
    placeholder->setStyleSheet("QLabel { background-color: #2b2b2b; color: white; "
                              "font-size: 16px; padding: 20px; }");
    layout->addWidget(placeholder);
    
    // Create process for Moonlight
    auto process = std::make_unique<QProcess>();
    
    // Set up process connections
    connect(process.get(), &QProcess::errorOccurred,
            [this, index](QProcess::ProcessError error) {
                qDebug() << "Moonlight process error for PC" << index << ":" << error;
                emit errorOccurred(index, "Process error occurred");
            });
    
    connect(process.get(), 
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [this, index](int exitCode, QProcess::ExitStatus exitStatus) {
                qDebug() << "Moonlight process finished for PC" << index 
                         << "Exit code:" << exitCode;
                emit connectionStateChanged(index, false);
            });
    
    // Start Moonlight process (commented out for safety in development)
    // process->start(m_moonlightPath, buildMoonlightArgs(pc));
    
    // Store instance
    MoonlightInstance instance;
    instance.process = std::move(process);
    instance.widget = std::move(container);
    instance.connected = true;
    
    auto* widgetPtr = instance.widget.get();
    m_instances[index] = std::move(instance);
    
    emit connectionStateChanged(index, true);
    return widgetPtr;
}

void MoonlightManager::disconnect(int index)
{
    auto it = m_instances.find(index);
    if (it != m_instances.end()) {
        if (it->second.process && it->second.process->state() != QProcess::NotRunning) {
            it->second.process->terminate();
            if (!it->second.process->waitForFinished(5000)) {
                it->second.process->kill();
            }
        }
        m_instances.erase(it);
        emit connectionStateChanged(index, false);
    }
}

void MoonlightManager::handleProcessError(QProcess::ProcessError error)
{
    // Find which instance this process belongs to
    QProcess *process = qobject_cast<QProcess*>(sender());
    if (!process) return;
    
    for (auto &[index, instance] : m_instances) {
        if (instance.process.get() == process) {
            QString errorString;
            switch (error) {
                case QProcess::FailedToStart:
                    errorString = "Failed to start Moonlight";
                    break;
                case QProcess::Crashed:
                    errorString = "Moonlight crashed";
                    break;
                case QProcess::Timedout:
                    errorString = "Connection timed out";
                    break;
                default:
                    errorString = "Unknown error occurred";
            }
            emit errorOccurred(index, errorString);
            break;
        }
    }
}

void MoonlightManager::handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    // Find which instance this process belongs to
    QProcess *process = qobject_cast<QProcess*>(sender());
    if (!process) return;
    
    for (auto &[index, instance] : m_instances) {
        if (instance.process.get() == process) {
            instance.connected = false;
            emit connectionStateChanged(index, false);
            
            if (exitStatus == QProcess::CrashExit) {
                emit errorOccurred(index, "Moonlight crashed unexpectedly");
            }
            break;
        }
    }
}

void MoonlightManager::disconnectAll()
{
    for (auto& [index, instance] : m_instances) {
        if (instance.process && instance.process->state() != QProcess::NotRunning) {
            instance.process->terminate();
            if (!instance.process->waitForFinished(5000)) {
                instance.process->kill();
            }
        }
    }
    m_instances.clear();
}