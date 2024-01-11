//
//  BlWiFiHotspotCHNMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/14.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include <stdio.h>
#include "BlWiFiHotspotCHNMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN
BlWiFiHotspotCHNMessage::BlWiFiHotspotCHNMessage():zy::BlWiFiMessage()
{
    memset(chn_info, 0, 4);
}

BlWiFiHotspotCHNMessage::~BlWiFiHotspotCHNMessage()
{
    
}

bool BlWiFiHotspotCHNMessage::buildRequest(uint8 opt, uint8 status, char *str)
{
    m_data.body.cmdType = ZYBIWiFiHotspotCmdCHN;
    
    int dataLength = (int)(sizeof(MSG_BODY)+2*sizeof(uint8)+strlen(str)+1);
    BYTE *data = (BYTE *)calloc(1, dataLength);
    
    memcpy(data, m_data.buff, sizeof(MSG_BODY));
    
    int offset = sizeof(MSG_BODY);
    memcpy(data+offset, &opt, sizeof(uint8));
    
    offset += sizeof(uint8);
    memcpy(data+offset, &status, sizeof(uint8));
    
    offset += sizeof(uint8);
    memcpy(data+offset, str, strlen(str)+1);
    
    setBody((BYTE*)data, dataLength, false);
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLength;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    return true;
}

bool BlWiFiHotspotCHNMessage::buildResponse(BYTE *data, int size)
{
    int bodySize = sizeof(BlWiFiHotspotCHNMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&opt, data+offset, 1);
    offset += 1;
    
    memcpy(&status, data+offset, 1);
    offset += 1;
    
    char *tmp = (char *)(data+offset);
    int strLen = (int)(strlen(tmp)+1);
    memcpy(chn_info, data+offset, strLen);
    
    offset += strLen;
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiHotspotCHNMessage::subType() const
{
    return ZYBIWiFiHotspotCmdCHN;
}
NAMESPACE_ZY_END
