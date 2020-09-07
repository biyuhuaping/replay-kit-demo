//
//  BlOtherOTAWaitMessage.cpp
//  ZYCamera
//
//  Created by wpj on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherOTAWaitMessage.h"

#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherOTAWaitMessage::BlOtherOTAWaitMessage():zy::BlOtherMessage(){
    
}

BlOtherOTAWaitMessage::~BlOtherOTAWaitMessage(){
    
}

bool BlOtherOTAWaitMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIOtherCmdOTAWAIT;
    m_data.body.status = 0x00;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherOTAWaitMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherOTAWaitMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherOTAWaitMessage::subType() const{
    return ZYBIOtherCmdOTAWAIT;
}

NAMESPACE_ZY_END
