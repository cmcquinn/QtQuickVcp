/****************************************************************************
**
** Copyright (C) 2014 Alexander Rössler
** License: LGPL version 2.1
**
** This file is part of QtQuickVcp.
**
** All rights reserved. This program and the accompanying materials
** are made available under the terms of the GNU Lesser General Public License
** (LGPL) version 2.1 which accompanies this distribution, and is available at
** http://www.gnu.org/licenses/lgpl-2.1.html
**
** This library is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** Lesser General Public License for more details.
**
** Contributors:
** Alexander Rössler @ The Cool Tool GmbH <mail DOT aroessler AT gmail DOT com>
**
****************************************************************************/
#include "servicediscoveryitem.h"

namespace qtquickvcp {

/*!
    \qmltype ServiceDiscoveryItem
    \instantiates QServiceDiscoveryItem
    \inqmlmodule Machinekit.HalRemote
    \brief Service discovery item
    \ingroup halremote

    This component is used to store information and data of resolved services.
    The properties \l{uuid}, \l{uri} and \l{version} are provided for
    convenience reasons and filled with the corresponding data from the
    \l txtRecords.

    \sa Service
*/

/*! \qmlproperty string ServiceDiscoveryItem::type

    This property holds the type of the service.
*/

/*! \qmlproperty string ServiceDiscoveryItem::name

    This property holds the name of the service.
*/

/*! \qmlproperty string ServiceDiscoveryItem::uri

    This property holds the uri of the service.
*/

/*! \qmlproperty string ServiceDiscoveryItem::uuid

    This property holds the uuid of the service. The uuid can be used to
    create a filter for filtering instances.
*/

/*! \qmlproperty int ServiceDiscoveryItem::version

    This property holds the version of the service. This property is \c 0
    if no version is specified within the service.
*/

/*! \qmlproperty int ServiceDiscoveryItem::port

    This property holds the port of the service.
*/

/*! \qmlproperty string ServiceDiscoveryItem::hostAddress

    This property holds the host address of the service.
*/

/*! \qmlproperty string ServiceDiscoveryItem::hostName

    This property holds the host name of the service.
*/

/*! \qmlproperty list<string> ServiceDiscoveryItem::txtRecords

    This property holds the TXT records of the service.
*/

ServiceDiscoveryItem::ServiceDiscoveryItem(QObject *parent) :
    QObject(parent),
    m_name(""),
    m_type(""),
    m_uri(""),
    m_uuid(""),
    m_version(0),
    m_port(0),
    m_hostName(""),
    m_hostAddress(""),
    m_txtRecords(QStringList()),
    m_outstandingRequests(QSet<int>()),
    m_updated(false),
    m_errorCount(0)
{
}

QString ServiceDiscoveryItem::uri() const
{
    return m_uri;
}

int ServiceDiscoveryItem::port() const
{
    return m_port;
}

QString ServiceDiscoveryItem::hostName() const
{
    return m_hostName;
}

QString ServiceDiscoveryItem::hostAddress() const
{
    return m_hostAddress;
}

QString ServiceDiscoveryItem::name() const
{
    return m_name;
}

QString ServiceDiscoveryItem::type() const
{
    return m_type;
}

QStringList ServiceDiscoveryItem::txtRecords() const
{
    return m_txtRecords;
}

QString ServiceDiscoveryItem::uuid() const
{
    return m_uuid;
}

QSet<int> ServiceDiscoveryItem::outstandingRequests() const
{
    return m_outstandingRequests;
}

bool ServiceDiscoveryItem::hasOutstandingRequests()
{
    return (!m_outstandingRequests.isEmpty());
}

int ServiceDiscoveryItem::version() const
{
    return m_version;
}

bool ServiceDiscoveryItem::updated() const
{
    return m_updated;
}

int ServiceDiscoveryItem::errorCount() const
{
    return m_errorCount;
}

void ServiceDiscoveryItem::setUri(const QString &arg)
{
    if (m_uri != arg) {
        m_uri = arg;
        emit uriChanged(arg);
    }
}

void ServiceDiscoveryItem::setPort(int arg)
{
    if (m_port != arg) {
        m_port = arg;
        emit portChanged(arg);
    }
}

void ServiceDiscoveryItem::setHostName(const QString &arg)
{
    if (m_hostName != arg) {
        m_hostName = arg;
        emit hostNameChanged(arg);
    }
}

void ServiceDiscoveryItem::setHostAddress(const QString &arg)
{
    if (m_hostAddress != arg) {
        m_hostAddress = arg;
        emit hostAddressChanged(arg);
    }
}

void ServiceDiscoveryItem::setName(const QString &arg)
{
    if (m_name != arg) {
        m_name = arg;
        emit nameChanged(arg);
    }
}

void ServiceDiscoveryItem::setType(const QString &arg)
{
    if (m_type != arg) {
        m_type = arg;
        emit typeChanged(arg);
    }
}

void ServiceDiscoveryItem::setUuid(const QString &arg)
{
    if (m_uuid != arg) {
        m_uuid = arg;
        emit uuidChanged(arg);
    }
}

void ServiceDiscoveryItem::addOutstandingRequest(int arg)
{
    m_outstandingRequests.insert(arg);
}

void ServiceDiscoveryItem::removeOutstandingRequest(int arg)
{
    m_outstandingRequests.remove(arg);
}

void ServiceDiscoveryItem::clearOutstandingRequests()
{
    m_outstandingRequests.clear();
}

void ServiceDiscoveryItem::setVersion(int arg)
{
    if (m_version != arg) {
        m_version = arg;
        emit versionChanged(arg);
    }
}

void ServiceDiscoveryItem::setUpdated(bool arg)
{
    if (m_updated != arg) {
        m_updated = arg;
        emit updatedChanged(arg);
    }
}

void ServiceDiscoveryItem::setErrorCount(int errorCount)
{
    if (m_errorCount == errorCount)
        return;

    m_errorCount = errorCount;
}

void ServiceDiscoveryItem::resetErrorCount()
{
    m_errorCount = 0;
}

void ServiceDiscoveryItem::increaseErrorCount()
{
    m_errorCount += 1;
}

void ServiceDiscoveryItem::setTxtRecords(const QStringList &arg)
{
    if (m_txtRecords != arg) {
        m_txtRecords = arg;

        QString uri("");
        QString uuid("");
        int version(0);

        for (const QString &string: qAsConst(m_txtRecords))
        {
            QStringList keyValue;
            keyValue = string.split("=");

            if (keyValue.at(0) == "dsn")
            {
                uri = keyValue.at(1);
            }
            else if (keyValue.at(0) == "uuid")
            {
                uuid = keyValue.at(1);
            }
            else if (keyValue.at(0) == "version")
            {
                version = keyValue.at(1).toInt();
            }
        }

        setUri(uri);
        setUuid(uuid);
        setVersion(version);
        emit txtRecordsChanged(arg);
    }
}
} // namespace qtquickvcp
