/*
 * Copyright (c) 2013 Meltytech, LLC
 * Author: Dan Dennedy <dan@dennedy.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "qmlutilities.h"
#include <QCoreApplication>

QmlUtilities::QmlUtilities(QObject *parent) :
    QObject(parent)
{
}

QDir QmlUtilities::qmlDir()
{
    QDir dir(qApp->applicationDirPath());
#if defined(Q_OS_UNIX) && !defined(Q_OS_MAC)
    dir.cdUp();
#endif
    dir.cd("share");
    dir.cd("shotcut");
    dir.cd("qml");
    return dir;
}

