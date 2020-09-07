//
//  BlWiFiHotspotGET_CHNLISTMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/14.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include <stdio.h>
#include "BlWiFiHotspotGET_CHNLISTMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN
BlWiFiHotspotGET_CHNLISTMessage::BlWiFiHotspotGET_CHNLISTMessage() :zy::BlWiFiMessage()
{
    memset(chn_list, 0, 1024);
}

BlWiFiHotspotGET_CHNLISTMessage::~BlWiFiHotspotGET_CHNLISTMessage()
{
    
}

bool BlWiFiHotspotGET_CHNLISTMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIWiFiHotspotCmdGET_CHNLIST;

    int buffer_length = sizeof(MSG_BODY)+sizeof(uint8);
    uint8 *tmp = (uint8 *)calloc(1, buffer_length);
    memcpy(tmp, m_data.buff, sizeof(MSG_BODY));
    
    uint8 tmp_chn_status = 0x00;
    memcpy(tmp+sizeof(MSG_BODY), &tmp_chn_status, sizeof(uint8));
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)tmp, buffer_length, false);
    return true;
}

bool BlWiFiHotspotGET_CHNLISTMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiHotspotGET_CHNLISTMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&chn_status, data+offset, sizeof(MSG_BODY));
    
    offset += sizeof(uint8);
    memcpy(chn_list, data+offset, size-offset);
    offset += size-offset;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiHotspotGET_CHNLISTMessage::subType() const
{
    return ZYBIWiFiHotspotCmdGET_CHNLIST;
}
NAMESPACE_ZY_END
