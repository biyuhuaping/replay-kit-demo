//
//  BlWiFiHotspotDisableMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiHotspotDisableMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiHotspotDisableMessage::BlWiFiHotspotDisableMessage()
: zy::BlWiFiMessage()
, m_wifiStatus(0)
{
}

BlWiFiHotspotDisableMessage::~BlWiFiHotspotDisableMessage()
{
    
}

bool BlWiFiHotspotDisableMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIWiFiHotspotCmdDisable;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiHotspotDisableMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiHotspotDisableMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_wifiStatus, data+offset, 1);
    offset += 1;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiHotspotDisableMessage::subType() const
{
    return ZYBIWiFiHotspotCmdDisable;
}

NAMESPACE_ZY_END