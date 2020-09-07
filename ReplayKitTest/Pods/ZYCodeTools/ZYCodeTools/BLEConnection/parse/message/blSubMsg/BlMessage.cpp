//
//  BlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlMessage.h"
#include <memory.h>
#include <string>

NAMESPACE_ZY_BEGIN

BlMessage::BlMessage()
: m_body(NULL)
, m_bodySize(0)
, m_crc(0)
, m_free(true)
{
    memset(&m_head, 0, sizeof(head));
}

BlMessage::~BlMessage()
{
    if (m_free && m_body) {
        free(m_body);
        m_body = NULL;
        m_bodySize = 0;
    }
}

void BlMessage::setHead(const head& head)
{
    m_head = head;
}

BlMessage::head& BlMessage::getHead() const
{
    return const_cast<BlMessage::head&>(m_head);
}

BYTE* BlMessage::getBody() const
{
    return m_body;
}

int BlMessage::getBodySize() const
{
    return m_bodySize;
}

void BlMessage::setBody(BYTE* body, int len, bool copy, bool freeWithDone)
{
    if (m_body) {
        free(m_body);
        m_body = NULL;
        m_bodySize = 0;
    }
    m_free = freeWithDone;
    if (copy) {
        if (len > 0) {
            m_body = (BYTE*)malloc(len);
            memcpy(m_body, body, len);
        } else {
            m_body = NULL;
        }
    } else {
        m_body = body;
    }
    
    m_bodySize = len;
}

unsigned short BlMessage::getCrc() const
{
    return m_crc;
}

void BlMessage::setCrc(unsigned short crc)
{
    m_crc = crc;
}

bool BlMessage::buildResponse(BYTE* data, int size)
{
    //assert(false);
    setBody((BYTE*)data, size, true);
    return false;
}

NAMESPACE_ZY_END
