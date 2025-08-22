#pragma once

#include <QString>

class RemotePC
{
public:
    RemotePC(const QString &name, const QString &address, int port);
    
    const QString& name() const { return m_name; }
    const QString& address() const { return m_address; }
    int port() const { return m_port; }
    
    bool isConnected() const { return m_connected; }
    void setConnected(bool connected) { m_connected = connected; }
    
private:
    QString m_name;
    QString m_address;
    int m_port;
    bool m_connected = false;
};