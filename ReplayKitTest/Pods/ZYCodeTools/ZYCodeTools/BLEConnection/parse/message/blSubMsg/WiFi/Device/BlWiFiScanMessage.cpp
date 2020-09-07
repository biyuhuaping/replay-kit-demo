//
//  BlWiFiScanMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiScanMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiScanMessage::BlWiFiScanMessage()
: zy::BlWiFiMessage()
{
}

BlWiFiScanMessage::~BlWiFiScanMessage()
{
    
}

bool BlWiFiScanMessage::buildRequest(int onOff)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdScan;
    m_data.body.status = onOff;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiScanMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlWiFiScanMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiScanMessage::subType() const
{
    return ZYBIWiFiDeviceCmdScan;
}

NAMESPACE_ZY_END
