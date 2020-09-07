//
//  BlOtherCMD_TRACKING_MODEMessage.cpp
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#include "BlOtherCMD_TRACKING_MODEMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMD_TRACKING_MODEMessage::BlOtherCMD_TRACKING_MODEMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMD_TRACKING_MODEMessage::~BlOtherCMD_TRACKING_MODEMessage()
{
    
}

bool BlOtherCMD_TRACKING_MODEMessage::buildRequest(uint8 op,uint8 value)
{
    m_data.body.cmdType = ZYBIOtherTRACKING_MODE;
    m_data.body.op = op;
    m_data.body.value = value;
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCMD_TRACKING_MODEMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherCMD_TRACKING_MODEMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMD_TRACKING_MODEMessage::subType() const
{
    return ZYBIOtherTRACKING_MODE;
}

NAMESPACE_ZY_END
