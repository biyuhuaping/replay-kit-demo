//
//  BlWiFiDisconnectMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiDisconnectMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiDisconnectMessage::BlWiFiDisconnectMessage()
: zy::BlWiFiMessage()
{
}

BlWiFiDisconnectMessage::~BlWiFiDisconnectMessage()
{
    
}

bool BlWiFiDisconnectMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdDisconnect;
    m_data.body.flag = 0;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiDisconnectMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlWiFiDisconnectMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiDisconnectMessage::subType() const
{
    return ZYBIWiFiDeviceCmdDisconnect;
}

NAMESPACE_ZY_END
