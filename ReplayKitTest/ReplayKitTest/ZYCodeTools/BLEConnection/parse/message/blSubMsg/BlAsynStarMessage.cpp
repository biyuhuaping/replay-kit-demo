//
//  BlAsynStarMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlAsynStarMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlAsynStarMessage::BlAsynStarMessage()
: zy::BlMessage()
{
}

BlAsynStarMessage::~BlAsynStarMessage()
{
    
}

bool BlAsynStarMessage::buildRequest(uint16 code, uint16 param)
{
    static char idx = 0;
    m_data.body.cmdId = idx++%255+1;
    
    //star转bl时 star内容地址为统一为0x01
    m_data.body.starData.data.adrs = 0x01;
    //star转bl时 star指令地址为统一为0x00
    m_data.body.starData.data.code = code&0xF0FF;
    m_data.body.starData.data.param = param;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+1+5;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventAsyn;
    
    //m_body = m_data.buff;
    //m_bodySize = sizeof(MSG_BODY);
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlAsynStarMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlAsynStarMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

NAMESPACE_ZY_END
