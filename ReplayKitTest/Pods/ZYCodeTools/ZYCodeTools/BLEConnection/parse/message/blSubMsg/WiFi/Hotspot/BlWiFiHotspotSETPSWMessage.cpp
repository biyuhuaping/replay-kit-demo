//
//  BlWiFiHotspotSETPSWMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/17.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiHotspotSETPSWMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlWiFiHotspotSETPSWMessage::BlWiFiHotspotSETPSWMessage()
: zy::BlWiFiMessage()
{
    
}

BlWiFiHotspotSETPSWMessage::~BlWiFiHotspotSETPSWMessage()
{
    
}

bool BlWiFiHotspotSETPSWMessage::buildRequest(const char* wifiPsw)
{
    m_data.body.cmdType = ZYBIWiFiHotspotCmdSetPSW;
    
    
    BYTE* buff = m_data.buff;
    FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), wifiPsw, int(strlen(wifiPsw)+1));
    setBody((BYTE*)data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
//
//
//    m_head.headCode = BL_HEAD_CODE_SEND;
//    m_head.lenght = 1+1+sizeof(MSG_BODY);
//    //APP发送指令包头地址统一为0x01
//    m_head.address = 0x01;
//    m_head.command = ZYBleInteractEvent;
//    m_head.status = ZYBleInteractEventWifi;
//
//    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiHotspotSETPSWMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiHotspotSETPSWMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_wifiStatus, data+offset, 1);
    offset += 1;
//    memcpy(m_pwd, data+offset, size-offset);
    offset += size-offset;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiHotspotSETPSWMessage::subType() const
{
    return ZYBIWiFiHotspotCmdSetPSW;
}

NAMESPACE_ZY_END

