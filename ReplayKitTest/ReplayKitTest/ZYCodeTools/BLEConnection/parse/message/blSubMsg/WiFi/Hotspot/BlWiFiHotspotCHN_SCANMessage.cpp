//
//  BlWiFiHotspotCHN_SCANMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/14.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include <stdio.h>
#include "BlWiFiHotspotCHN_SCANMessage.h"
#include <assert.h>
#include <string.h>

NAMESPACE_ZY_BEGIN
BlWiFiHotspotCHN_SCANMessage::BlWiFiHotspotCHN_SCANMessage():zy::BlWiFiMessage()
{
    for (int i = 0; i < 128; ++i)
        memset(infos[i].scan_info, 0, 128);
}

BlWiFiHotspotCHN_SCANMessage::~BlWiFiHotspotCHN_SCANMessage()
{
    
}

bool BlWiFiHotspotCHN_SCANMessage::buildRequest(uint8 type, char *str)
{
    m_data.body.cmdType = ZYBIWiFiHotspotCmdCHN_SCAN;
    
    int bodySize = sizeof(BlWiFiHotspotCHN_SCANMessage::MSG_BODY);
    int dataLength = (int)(bodySize+sizeof(uint8)+strlen(str)+1);
    BYTE *data = (BYTE *)calloc(1, dataLength);
    memcpy(data, m_data.buff, 1);
    
    int offset = bodySize;
    memcpy(data+offset, &type, sizeof(uint8));
    
    offset += sizeof(uint8_t);
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

bool BlWiFiHotspotCHN_SCANMessage::buildResponse(BYTE *data, int size)
{
    int bodySize = sizeof(BlWiFiHotspotCHN_SCANMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);

    int offset = bodySize;
    memcpy(&opt, data+offset, 1);
    offset += 1;
    
    int i = 0, current = offset;
    while (size > offset)
    {
        if (*(data+offset) == '\0' && *(data+offset-1) != ',' && *(data+offset-1) != '\0')
        {
            memcpy(infos[i++].scan_info, data+current, offset-current+1);
            current = offset+1;
            ++offset;
            continue;
        }
        
        ++offset;
    }
  
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiHotspotCHN_SCANMessage::subType() const
{
    return ZYBIWiFiHotspotCmdCHN_SCAN;
}
NAMESPACE_ZY_END
