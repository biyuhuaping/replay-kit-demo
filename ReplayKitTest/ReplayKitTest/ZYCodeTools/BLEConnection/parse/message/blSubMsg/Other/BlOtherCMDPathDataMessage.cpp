//
//  BlOtherCMDPathDataMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//
#include "BlOtherCMDPathDataMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMDPathDataMessage::BlOtherCMDPathDataMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMDPathDataMessage::~BlOtherCMDPathDataMessage()
{
    
}

bool BlOtherCMDPathDataMessage::buildRequest(uint8 flag, uint8 state)
{
    m_data.body.cmdType = ZYBIOtherCmdPathData;
    m_data.body.flag = flag;
    m_data.body.state = state;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCMDPathDataMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherCMDPathDataMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMDPathDataMessage::subType() const
{
    return ZYBIOtherCmdPathData;
}

NAMESPACE_ZY_END
