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

#include "glcubeitem.h"

namespace qtquickvcp {

GLCubeItem::GLCubeItem(QQuickItem *parent) :
    GLItem(parent),
    m_cubePointer(nullptr),
    m_size(QVector3D(1,1,1)),
    m_color(QColor(Qt::yellow)),
    m_centered(false),
    m_selected(false)
{
    connect(this, &GLCubeItem::sizeChanged,
            this, &GLCubeItem::needsUpdate);
    connect(this, &GLCubeItem::colorChanged,
            this, &GLCubeItem::needsUpdate);
    connect(this, &GLCubeItem::centeredChanged,
            this, &GLCubeItem::needsUpdate);
}

void GLCubeItem::paint(GLView *glView)
{
    glView->prepare(this);

    glView->reset();
    glView->beginUnion();
    glView->color(m_color);
    m_cubePointer = glView->cube(m_size, m_centered);
    glView->endUnion();
}

void GLCubeItem::selectDrawable(void *pointer)
{
    if (m_cubePointer == nullptr)
    {
        return;
    }

    bool selected = (pointer == m_cubePointer);

    if (selected != m_selected)
    {
        m_selected = selected;
        emit selectedChanged(m_selected);
    }
}
} // namespace qtquickvcp
