//
//  BlWiFiPhotoMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlHandleMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlHandleMessage::BlHandleMessage()
: BlMessage()
{
}

BlHandleMessage::~BlHandleMessage()
{
    
}

bool BlHandleMessage::buildRequest(uint8 cmd, uint16 arg)
{
    static char idx = 0;
    m_data.body.cmdId = idx++%255+1;
    m_data.body.cmd = cmd;
    m_data.body.arg = arg;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventHandle;
    
    //m_body = m_data.buff;
    //m_bodySize = sizeof(MSG_BODY);
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlHandleMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlHandleMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

NAMESPACE_ZY_END
