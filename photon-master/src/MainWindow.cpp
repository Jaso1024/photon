#include "MainWindow.h"
#include "MoonlightManager.h"
#include "RemotePC.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QLabel>
#include <QKeyEvent>
#include <QSplitter>
#include <QGroupBox>
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , m_moonlightManager(std::make_unique<MoonlightManager>(this))
{
    setupUI();
    loadRemotePCs();
}

MainWindow::~MainWindow() = default;

void MainWindow::setupUI()
{
    setWindowTitle("Photon - Secure Multi-PC Control");
    resize(1200, 800);
    
    auto *centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    
    auto *mainLayout = new QHBoxLayout(centralWidget);
    
    // Left panel - PC list
    auto *leftPanel = new QGroupBox("Remote PCs", this);
    auto *leftLayout = new QVBoxLayout(leftPanel);
    
    m_pcListWidget = new QListWidget(this);
    m_pcListWidget->setMaximumWidth(250);
    connect(m_pcListWidget, &QListWidget::currentRowChanged, 
            this, &MainWindow::onPCSelected);
    connect(m_pcListWidget, &QListWidget::itemDoubleClicked,
            this, &MainWindow::onPCDoubleClicked);
    
    auto *refreshBtn = new QPushButton("Refresh", this);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPCList);
    
    leftLayout->addWidget(m_pcListWidget);
    leftLayout->addWidget(refreshBtn);
    
    // Right panel - Moonlight viewer
    m_stackedWidget = new QStackedWidget(this);
    
    // Add empty widget as default
    auto *emptyWidget = new QLabel("Select a PC to connect", this);
    emptyWidget->setAlignment(Qt::AlignCenter);
    m_stackedWidget->addWidget(emptyWidget);
    
    // Create splitter
    auto *splitter = new QSplitter(Qt::Horizontal, this);
    splitter->addWidget(leftPanel);
    splitter->addWidget(m_stackedWidget);
    splitter->setStretchFactor(1, 1);
    
    mainLayout->addWidget(splitter);
    
    // Status bar
    statusBar()->showMessage("Ready - Press Ctrl+[1-9] for quick switching");
}

void MainWindow::loadRemotePCs()
{
    // Load PC configurations (hardcoded for now, could be from config file)
    struct PCConfig {
        QString name;
        QString address;
        int port;
    };
    
    std::vector<PCConfig> configs = {
        {"PC1 - Development", "172.20.0.10", 47989},
        {"PC2 - Testing", "172.20.0.11", 47989},
        {"PC3 - Production", "172.20.0.12", 47989}
    };
    
    m_pcListWidget->clear();
    m_remotePCs.clear();
    
    for (const auto& config : configs) {
        auto pc = std::make_unique<RemotePC>(config.name, config.address, config.port);
        m_pcListWidget->addItem(config.name);
        m_remotePCs.push_back(std::move(pc));
    }
}

void MainWindow::keyPressEvent(QKeyEvent *event)
{
    // Quick switching with Ctrl+1 through Ctrl+9
    if (event->modifiers() & Qt::ControlModifier) {
        int key = event->key();
        if (key >= Qt::Key_1 && key <= Qt::Key_9) {
            int index = key - Qt::Key_1;
            if (index < m_remotePCs.size()) {
                switchToPC(index);
                return;
            }
        }
    }
    
    QMainWindow::keyPressEvent(event);
}

void MainWindow::onPCSelected(int index)
{
    if (index < 0 || index >= m_remotePCs.size()) {
        return;
    }
    
    statusBar()->showMessage(QString("Selected: %1").arg(m_remotePCs[index]->name()));
}

void MainWindow::onPCDoubleClicked(QListWidgetItem *item)
{
    int index = m_pcListWidget->row(item);
    switchToPC(index);
}

void MainWindow::switchToPC(int index)
{
    if (index < 0 || index >= m_remotePCs.size()) {
        return;
    }
    
    // Disconnect from current PC if connected
    if (m_currentPCIndex >= 0 && m_currentPCIndex != index) {
        m_moonlightManager->disconnect(m_currentPCIndex);
    }
    
    // Connect to new PC
    statusBar()->showMessage(QString("Connecting to %1...").arg(m_remotePCs[index]->name()));
    
    QWidget *viewer = m_moonlightManager->connectToPC(*m_remotePCs[index], index);
    if (viewer) {
        // Remove old viewer if exists
        if (m_stackedWidget->count() > index + 1) {
            m_stackedWidget->removeWidget(m_stackedWidget->widget(index + 1));
        }
        
        m_stackedWidget->insertWidget(index + 1, viewer);
        m_stackedWidget->setCurrentIndex(index + 1);
        m_currentPCIndex = index;
        m_pcListWidget->setCurrentRow(index);
        
        statusBar()->showMessage(QString("Connected to %1").arg(m_remotePCs[index]->name()));
    } else {
        QMessageBox::warning(this, "Connection Failed", 
                           QString("Failed to connect to %1").arg(m_remotePCs[index]->name()));
        statusBar()->showMessage("Connection failed");
    }
}

void MainWindow::refreshPCList()
{
    statusBar()->showMessage("Refreshing PC list...");
    loadRemotePCs();
    statusBar()->showMessage("PC list refreshed");
}