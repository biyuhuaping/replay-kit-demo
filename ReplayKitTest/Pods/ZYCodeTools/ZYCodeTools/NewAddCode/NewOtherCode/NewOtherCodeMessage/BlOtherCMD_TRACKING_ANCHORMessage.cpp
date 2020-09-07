//
//  BlOtherCMD_TRACKING_ANCHORMessage.cpp
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#include "BlOtherCMD_TRACKING_ANCHORMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMD_TRACKING_ANCHORMessage::BlOtherCMD_TRACKING_ANCHORMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMD_TRACKING_ANCHORMessage::~BlOtherCMD_TRACKING_ANCHORMessage()
{
    
}

bool BlOtherCMD_TRACKING_ANCHORMessage::buildRequest(uint8 op,uint16 x,uint16 y)
{
    m_data.body.cmdType = ZYBIOtherTRACKING_ANCHOR;
    
    m_data.body.op = op;
    m_data.body.x = x;
    m_data.body.y = y;    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCMD_TRACKING_ANCHORMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherCMD_TRACKING_ANCHORMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMD_TRACKING_ANCHORMessage::subType() const
{
    return ZYBIOtherTRACKING_ANCHOR;
}

NAMESPACE_ZY_END
