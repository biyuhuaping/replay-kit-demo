//
//  UsbMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbMessage.h"
#include <memory.h>
#include <string>

NAMESPACE_ZY_BEGIN

UsbMessage::UsbMessage()
: m_buff(NULL)
, m_buffSize(0)
, m_free(true)
{
}

UsbMessage::~UsbMessage()
{
    if (m_free && m_buff) {
        free(m_buff);
        m_buff = NULL;
        m_buffSize = 0;
    }
}

BYTE* UsbMessage::getHeadPtr() const
{
    return 0;
}

int UsbMessage::getHeadSize() const
{
    return 0;
}

BYTE* UsbMessage::getBuff() const
{
    return m_buff;
}

int UsbMessage::getBuffSize() const
{
    return m_buffSize;
}

void UsbMessage::setBuff(BYTE* buff, int len, bool copy, bool freeWithDone)
{
    if (m_buff) {
        free(m_buff);
        m_buff = NULL;
        m_buffSize = 0;
    }
    m_free = freeWithDone;
    if (copy) {
        m_buff = (BYTE*)malloc(len);
        memcpy(m_buff, buff, len);
    } else {
        m_buff = buff;
    }
    
    m_buffSize = len;
}

unsigned short UsbMessage::getCrc() const
{
    return 0;
}

bool UsbMessage::buildResponse(BYTE* data, int size)
{
    //assert(false);
    return false;
}

int UsbMessage::messageType() const
{
    return ZYUMTBase;
}

int UsbMessage::genUID()
{
    static unsigned short idx = 0;
    if (idx == 65535) {
        idx = 0;
    }
    return idx++%65535+1;
}


NAMESPACE_ZY_END
