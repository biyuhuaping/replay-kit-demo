//
//  BlOtherSystemTimeMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherSystemTimeMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherSystemTimeMessage::BlOtherSystemTimeMessage()
: zy::BlOtherMessage()
{
}

BlOtherSystemTimeMessage::~BlOtherSystemTimeMessage()
{
    
}

bool BlOtherSystemTimeMessage::buildRequest(unsigned int sec, unsigned int usec)
{
    m_data.body.cmdType = ZYBIOtherCmdSystemTime;
    m_data.body.status = 0x00;
    m_data.body.times = sec;
    m_data.body.timeus = usec;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherSystemTimeMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherSystemTimeMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherSystemTimeMessage::subType() const
{
    return ZYBIOtherCmdSystemTime;
}

NAMESPACE_ZY_END
