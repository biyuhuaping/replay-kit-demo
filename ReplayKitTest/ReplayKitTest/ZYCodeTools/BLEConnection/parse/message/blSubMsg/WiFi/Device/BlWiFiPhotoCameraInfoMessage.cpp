//
//  BlWiFiPhotoCameraInfoMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiPhotoCameraInfoMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiPhotoCameraInfoMessage::BlWiFiPhotoCameraInfoMessage()
: zy::BlWiFiPhotoMessage()
{
}

BlWiFiPhotoCameraInfoMessage::~BlWiFiPhotoCameraInfoMessage()
{
    
}

bool BlWiFiPhotoCameraInfoMessage::buildRequest(uint8 flag,uint8 value)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdPhoto;
    m_data.body.photoCmdType = ZYBleInteractWifiCmdCameraInfo;
    m_data.body.value = (flag & 0xf0)|(value & 0x0f);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiPhotoCameraInfoMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlWiFiPhotoCameraInfoMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiPhotoCameraInfoMessage::subPhotoType() const
{
    return ZYBleInteractWifiCmdCameraInfo;
}

NAMESPACE_ZY_END
