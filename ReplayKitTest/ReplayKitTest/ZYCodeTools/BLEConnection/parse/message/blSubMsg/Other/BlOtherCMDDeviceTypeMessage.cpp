//
//  BlOtherCMDDeviceTypeMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/21.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCMDDeviceTypeMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMDDeviceTypeMessage::BlOtherCMDDeviceTypeMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMDDeviceTypeMessage::~BlOtherCMDDeviceTypeMessage()
{
    
}

bool BlOtherCMDDeviceTypeMessage::buildRequest(uint8 direct, uint8 type)
{
    m_data.body.cmdType = ZYBIOtherCmdDeviceType;
    m_data.body.direct = direct;
    m_data.body.type = type;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCMDDeviceTypeMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherCMDDeviceTypeMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMDDeviceTypeMessage::subType() const
{
    return ZYBIOtherCmdDeviceType;
}

NAMESPACE_ZY_END
