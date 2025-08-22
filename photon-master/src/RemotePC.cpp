#include "RemotePC.h"

RemotePC::RemotePC(const QString &name, const QString &address, int port)
    : m_name(name)
    , m_address(address)
    , m_port(port)
{
}