//
//  UsbMediaMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbMediaMessage.h"
#include <memory.h>
#include <string>

NAMESPACE_ZY_BEGIN

UsbMediaMessage::UsbMediaMessage()
: m_body(NULL)
, m_bodySize(0)
, m_crc(0)
, m_free(true)
{
    memset(&m_head, 0, sizeof(head));
}

UsbMediaMessage::~UsbMediaMessage()
{
    if (m_free && m_body) {
        free(m_body);
        m_body = NULL;
        m_bodySize = 0;
    }
}

void UsbMediaMessage::setHead(const head& head)
{
    m_head = head;
}

UsbMediaMessage::head& UsbMediaMessage::getHead() const
{
    return const_cast<UsbMediaMessage::head&>(m_head);
}

BYTE* UsbMediaMessage::getBody() const
{
    return m_body;
}

int UsbMediaMessage::getBodySize() const
{
    return m_bodySize;
}

void UsbMediaMessage::setBody(BYTE* body, int len, bool copy, bool freeWithDone)
{
    if (m_body) {
        free(m_body);
        m_body = NULL;
        m_bodySize = 0;
    }
    m_free = freeWithDone;
    if (copy) {
        m_body = (BYTE*)malloc(len);
        memcpy(m_body, body, len);
    } else {
        m_body = body;
    }
    
    m_bodySize = len;
}

BYTE* UsbMediaMessage::getHeadPtr() const
{
    return (BYTE*)&m_head;
}

int UsbMediaMessage::getHeadSize() const
{
    return sizeof(UsbMediaMessage::head);
}

unsigned short UsbMediaMessage::getCrc() const
{
    return m_crc;
}

void UsbMediaMessage::setCrc(unsigned short crc)
{
    m_crc = crc;
}

bool UsbMediaMessage::buildResponse(BYTE* data, int size)
{
    //assert(false);
    return false;
}

int UsbMediaMessage::messageType() const
{
    return ZYUMTMedia;
}

NAMESPACE_ZY_END
