//
//  BlWiFiDeviceMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiDeviceMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiDeviceMessage::BlWiFiDeviceMessage()
: zy::BlWiFiMessage()
{
    memset(m_ssid, 0, sizeof(m_ssid));
}

BlWiFiDeviceMessage::~BlWiFiDeviceMessage()
{
    
}

bool BlWiFiDeviceMessage::buildRequest(int num)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdDevice;
    m_data.body.num = num;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiDeviceMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiDeviceMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
//    size_t len = strlen((const char*)(data+offset));
//    if (len > MAX_NAME_SIZE-1) {
//        return false;
//    }
//    memcpy(m_ssid, data+offset, len+1);
//    offset += len+1;
    //TODO 临时测试
    memcpy(m_ssid, data+offset, size-bodySize);
    offset += size-bodySize;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiDeviceMessage::subType() const
{
    return ZYBIWiFiDeviceCmdDevice;
}

NAMESPACE_ZY_END
