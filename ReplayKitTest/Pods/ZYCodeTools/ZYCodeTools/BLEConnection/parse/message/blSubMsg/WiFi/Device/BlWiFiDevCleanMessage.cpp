//
//  BlWiFiScanMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiDevCleanMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiDevCleanMessage::BlWiFiDevCleanMessage()
: zy::BlWiFiMessage()
{
    memset(m_ssid, 0, MAX_NAME_SIZE);
}

BlWiFiDevCleanMessage::~BlWiFiDevCleanMessage()
{
    
}

bool BlWiFiDevCleanMessage::buildRequest(const char* ssid)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdClean;
    
    int bodySize = sizeof(MSG_BODY);
    int ssidSize = (int)strlen(m_ssid)+1;
    int dataLen = bodySize+ssidSize;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    BYTE* data = (BYTE*)calloc(1, dataLen);
    int offset = 0;
    memcpy(data+offset, m_data.buff, bodySize);
    offset+=bodySize;
    memcpy(data+offset, m_ssid, ssidSize);
    offset+=ssidSize;
    
    assert(dataLen == offset);
    setBody(data, dataLen, false);
    
    return true;
}

bool BlWiFiDevCleanMessage::buildResponse(BYTE* data, int size)
{
    assert(size == (sizeof(BlWiFiDevCleanMessage::MSG_BODY)+sizeof(m_flag)));
    memcpy(m_data.buff, data, size);
    
    int offset = size;
    memcpy(&m_flag, data+offset, sizeof(m_flag));
    offset += 1;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiDevCleanMessage::subType() const
{
    return ZYBIWiFiDeviceCmdClean;
}

NAMESPACE_ZY_END
