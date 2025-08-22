#include <QApplication>
#include "MainWindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Photon Master");
    app.setOrganizationName("Photon");
    
    MainWindow window;
    window.show();
    
    return app.exec();
}