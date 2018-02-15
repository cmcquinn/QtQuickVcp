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

#include "glcanvas.h"

namespace qtquickvcp {

GLCanvas::GLCanvas(QQuickItem *parent) :
    GLItem(parent),
    m_context(nullptr)
{
}

void GLCanvas::paint(GLView *glView)
{
    if (m_context != glView) {
        m_context = glView;
        emit contextChanged(glView);
    }

    emit paint();
}

void GLCanvas::selectDrawable(void *pointer)
{
    emit drawableSelected(pointer);
}
} // namespace qtquickvcp
