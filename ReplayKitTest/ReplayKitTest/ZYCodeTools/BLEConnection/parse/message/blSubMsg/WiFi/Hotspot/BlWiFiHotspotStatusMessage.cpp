//
//  BlWiFiHotspotStatusMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiHotspotStatusMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiHotspotStatusMessage::BlWiFiHotspotStatusMessage()
: zy::BlWiFiMessage()
, m_wifiStatus(0)
{
}

BlWiFiHotspotStatusMessage::~BlWiFiHotspotStatusMessage()
{
    
}

bool BlWiFiHotspotStatusMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIWiFiHotspotCmdStatus;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiHotspotStatusMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiHotspotStatusMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_wifiStatus, data+offset, 1);
    offset += 1;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiHotspotStatusMessage::subType() const
{
    return ZYBIWiFiHotspotCmdStatus;
}

NAMESPACE_ZY_END
