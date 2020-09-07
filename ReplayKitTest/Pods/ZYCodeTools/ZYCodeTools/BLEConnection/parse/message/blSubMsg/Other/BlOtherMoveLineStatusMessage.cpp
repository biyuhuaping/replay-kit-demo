//
//  BlOtherMoveLineStatusMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherMoveLineStatusMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlOtherMoveLineStatusMessage::BlOtherMoveLineStatusMessage()
: zy::BlOtherMessage()
{
}

BlOtherMoveLineStatusMessage::~BlOtherMoveLineStatusMessage()
{
    
}

bool BlOtherMoveLineStatusMessage::buildRequest(uint8 status)
{
    m_data.body.cmdType = ZYBIOtherCmdMoveLineStatue;
    
    m_data.body.status = status;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherMoveLineStatusMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherMoveLineStatusMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherMoveLineStatusMessage::subType() const
{
    return ZYBIOtherCmdMoveLineStatue;
}

NAMESPACE_ZY_END
