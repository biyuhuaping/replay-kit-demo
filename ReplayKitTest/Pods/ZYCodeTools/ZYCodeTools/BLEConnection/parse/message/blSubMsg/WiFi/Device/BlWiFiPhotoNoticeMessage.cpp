//
//  BlWiFiPhotoInfoMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlWiFiPhotoNoticeMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlWiFiPhotoNoticeMessage::BlWiFiPhotoNoticeMessage()
: zy::BlWiFiPhotoMessage()
{
}

BlWiFiPhotoNoticeMessage::~BlWiFiPhotoNoticeMessage()
{
    
}

bool BlWiFiPhotoNoticeMessage::buildRequest(int photoParaId)
{
    m_data.body.cmdType = ZYBIWiFiDeviceCmdPhoto;
    m_data.body.photoCmdType = ZYBleInteractWifiCmdPhotoNotice;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventWifi;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlWiFiPhotoNoticeMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlWiFiPhotoNoticeMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlWiFiPhotoNoticeMessage::subPhotoType() const
{
    return ZYBleInteractWifiCmdPhotoNotice;
}

NAMESPACE_ZY_END
