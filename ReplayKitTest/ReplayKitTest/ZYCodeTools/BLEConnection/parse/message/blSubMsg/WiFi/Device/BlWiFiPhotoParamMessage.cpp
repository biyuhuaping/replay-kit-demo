//
//  BlWiFiPhotoInfoMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiPhotoParamMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiPhotoParamMessage::BlWiFiPhotoParamMessage()
: zy::BlWiFiPhotoMessage()
{
}

BlWiFiPhotoParamMessage::~BlWiFiPhotoParamMessage()
{
    
}

bool BlWiFiPhotoParamMessage::buildRequest(int photoParaId)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdPhoto;
    m_data.body.photoCmdType = ZYBleInteractWifiCmdPhotoParam;
    m_data.body.photoParamId = photoParaId;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiPhotoParamMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlWiFiPhotoParamMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_photoParamValue, data+offset, sizeof(m_photoParamValue));
    offset += sizeof(m_photoParamValue);
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiPhotoParamMessage::subPhotoType() const
{
    return ZYBleInteractWifiCmdPhotoParam;
}

int BlWiFiPhotoParamMessage::subPhotoParamId() const
{
    return m_data.body.photoParamId;
}

NAMESPACE_ZY_END
