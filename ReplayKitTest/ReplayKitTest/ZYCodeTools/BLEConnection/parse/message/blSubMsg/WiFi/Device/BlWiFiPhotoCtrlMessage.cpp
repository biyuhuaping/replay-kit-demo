//
//  BlWiFiPhotoCtrlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiPhotoCtrlMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiPhotoCtrlMessage::BlWiFiPhotoCtrlMessage()
: zy::BlWiFiPhotoMessage()
{
}

BlWiFiPhotoCtrlMessage::~BlWiFiPhotoCtrlMessage()
{
    
}

bool BlWiFiPhotoCtrlMessage::buildRequest(int photoParamId, int photoCrtlValue)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdPhoto;
    m_data.body.photoCmdType = ZYBleInteractWifiCmdPhotoCtrl;
    m_data.body.photoParamId = photoParamId;
    m_data.body.photoCrtlValue = photoCrtlValue;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiPhotoCtrlMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlWiFiPhotoCtrlMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiPhotoCtrlMessage::subPhotoType() const
{
    return ZYBleInteractWifiCmdPhotoCtrl;
}

NAMESPACE_ZY_END
