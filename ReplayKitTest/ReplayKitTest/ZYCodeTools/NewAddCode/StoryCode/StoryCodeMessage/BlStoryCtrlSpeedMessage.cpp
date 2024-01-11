//
//  BlStoryCtrlSpeedMessage.c
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#include "BlStoryCtrlSpeedMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlStoryCtrlSpeedMessage::BlStoryCtrlSpeedMessage()
: zy::BlStoryMessage()
{
}

BlStoryCtrlSpeedMessage::~BlStoryCtrlSpeedMessage()
{
    
}

bool BlStoryCtrlSpeedMessage::buildRequest(uint16 pitchSpeed,uint16 rollSpeed,uint16 yawSpeed,uint16 duration)
{
    m_data.body.cmdType = ZYBISTORY_CMD_CTRL_SPEED;
    
    m_data.body.pitchSpeed = pitchSpeed;
    m_data.body.rollSpeed = rollSpeed;
    m_data.body.yawSpeed = yawSpeed;
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
bool BlStoryCtrlSpeedMessage::buildResponse(BYTE* data, int size)
{
     assert(size == sizeof(BlStoryCtrlSpeedMessage::MSG_BODY));
       memcpy(m_data.buff, data, size);
       setBody((BYTE*)data, size, true);
       return true;
}

int BlStoryCtrlSpeedMessage::subType() const
{
    return ZYBISTORY_CMD_CTRL_SPEED;
}

NAMESPACE_ZY_END
