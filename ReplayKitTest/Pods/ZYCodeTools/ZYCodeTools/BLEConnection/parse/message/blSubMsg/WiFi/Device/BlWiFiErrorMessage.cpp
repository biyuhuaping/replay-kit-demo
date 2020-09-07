//
//  BlWiFiScanMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiErrorMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiErrorMessage::BlWiFiErrorMessage()
: zy::BlWiFiMessage()
{
}

BlWiFiErrorMessage::~BlWiFiErrorMessage()
{
    
}

bool BlWiFiErrorMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdErr;
    m_data.body.errCode = 0;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiErrorMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlWiFiErrorMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiErrorMessage::subType() const
{
    return ZYBIWiFiDeviceCmdErr;
}

NAMESPACE_ZY_END
