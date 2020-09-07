//
//  BlStoryCtrlPositionMessage.c
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#include "BlStoryCtrlPositionMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlStoryCtrlPositionMessage::BlStoryCtrlPositionMessage()
: zy::BlStoryMessage()
{
}

BlStoryCtrlPositionMessage::~BlStoryCtrlPositionMessage()
{
    
}

bool BlStoryCtrlPositionMessage::buildRequest(uint16 pitchDegree,uint16 rollDegree,uint16 yawDegree,uint16 duration)
{
    m_data.body.cmdType = ZYBISTORY_CMD_CTRL_POSITION;
    
    m_data.body.pitchDegree = pitchDegree;
    m_data.body.rollDegree = rollDegree;
    m_data.body.yawDegree = yawDegree;
    m_data.body.duration = duration;

    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventSTORY;
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlStoryCtrlPositionMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlStoryCtrlPositionMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlStoryCtrlPositionMessage::subType() const
{
    return ZYBISTORY_CMD_CTRL_POSITION;
}

NAMESPACE_ZY_END
