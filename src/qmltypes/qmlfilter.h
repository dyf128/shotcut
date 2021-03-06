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

#ifndef FILTER_H
#define FILTER_H

#include <QObject>
#include <QString>
#include <QVariant>
#include <MltFilter.h>
#include "models/attachedfiltersmodel.h"
#include "qmlmetadata.h"

class MeltJob;

class QmlFilter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isNew READ isNew)
    Q_PROPERTY(QString path READ path)
    Q_PROPERTY(QStringList presets READ presets NOTIFY presetsChanged)

public:
    explicit QmlFilter(AttachedFiltersModel& model, const QmlMetadata& metadata, int row, QObject *parent = 0);
    ~QmlFilter();

    bool isNew() const { return m_isNew; }

    Q_INVOKABLE QString get(QString name);
    Q_INVOKABLE void set(QString name, QString value);
    Q_INVOKABLE void set(QString name, double value);
    Q_INVOKABLE void set(QString name, int value);
    QString path() const { return m_path; }
    Q_INVOKABLE void loadPresets();
    QStringList presets() const { return m_presets; }
    /// returns the index of the new preset
    Q_INVOKABLE int  savePreset(const QStringList& propertyNames, const QString& name = QString());
    Q_INVOKABLE void deletePreset(const QString& name);
    Q_INVOKABLE void stabilizeVideo();

public slots:
    void preset(const QString& name);

signals:
    void presetsChanged();
    void stabilizeFinished(bool isSuccess);

private:
    AttachedFiltersModel& m_model;
    const QmlMetadata& m_metadata;
    Mlt::Filter* m_filter;
    QString m_path;
    bool m_isNew;
    QStringList m_presets;
    
    QString objectNameOrService();

private slots:
    void onStabilizeFinished(MeltJob* job, bool isSuccess);
};

#endif // FILTER_H
