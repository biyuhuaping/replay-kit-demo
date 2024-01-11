//
//  BlOtherHeartMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherHeartMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherHeartMessage::BlOtherHeartMessage()
: zy::BlOtherMessage()
{
}

BlOtherHeartMessage::~BlOtherHeartMessage()
{
    
}

bool BlOtherHeartMessage::buildRequest(uint8 heartType)
{
    m_data.body.cmdType = ZYBIOtherHeart;
    m_data.body.status = heartType;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherHeartMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherHeartMessage::MSG_BODY);

    assert(size >= bodySize - 1);
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    
    int offset = bodySize - 1;
    if (size >= offset + sizeof(errorType)) {
        memcpy(&errorType, data+offset, sizeof(errorType));
        offset += sizeof(errorType);
    }
    if (size >= bodySize - 1 + sizeof(battery)+ sizeof(errorType)) {
          memcpy(&battery, data + bodySize - 1 +sizeof(battery), sizeof(battery));
    }
  
    return true;
}

int BlOtherHeartMessage::subType() const
{
    return ZYBIOtherHeart;
}

NAMESPACE_ZY_END
