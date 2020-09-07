//
//  BlWiFiScanMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiConnectionMessage.h"
#include <assert.h>
#include <string.h>

NAMESPACE_ZY_BEGIN

BlWiFiConnectionMessage::BlWiFiConnectionMessage()
: zy::BlWiFiMessage()
{
    memset(m_ssid, 0, MAX_NAME_SIZE);
    memset(m_pwd, 0, MAX_NAME_SIZE);
}

BlWiFiConnectionMessage::~BlWiFiConnectionMessage()
{
    
}

bool BlWiFiConnectionMessage::buildRequest(const char* ssid, const char* pwd)
{
    strncpy(m_ssid, ssid, MAX_NAME_SIZE-1);
    strncpy(m_pwd, pwd, MAX_NAME_SIZE-1);
    
    m_data.body.cmdType = ZYBIWiFiDeviceCmdConnect;
    
    int bodySize = sizeof(MSG_BODY);
    int ssidSize = (int)strlen(m_ssid)+1;
    int pwdSize = (int)strlen(m_pwd)+1;
    int dataLen = bodySize+ssidSize+pwdSize;
    
    BYTE* data = (BYTE*)calloc(1, dataLen);
    int offset = 0;
    memcpy(data+offset, m_data.buff, bodySize);
    offset+=bodySize;
    memcpy(data+offset, m_ssid, ssidSize);
    offset+=ssidSize;
    memcpy(data+offset, m_pwd, pwdSize);
    offset+=pwdSize;
    
    assert(dataLen == offset);
    setBody(data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    return true;
}

bool BlWiFiConnectionMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiConnectionMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_flag, data+offset, sizeof(m_flag));
    offset += 1;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiConnectionMessage::subType() const
{
    return ZYBIWiFiDeviceCmdConnect;
}

NAMESPACE_ZY_END
