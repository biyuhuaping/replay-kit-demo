//
//  BlCCSGetAvailableConfigMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlCCSGetAvailableConfigMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlCCSGetAvailableConfigMessage::BlCCSGetAvailableConfigMessage()
: zy::BlCCSMessage()
{
}

BlCCSGetAvailableConfigMessage::~BlCCSGetAvailableConfigMessage()
{
    
}

bool BlCCSGetAvailableConfigMessage::buildRequest(int configIdx)
{
    m_data.body.cmdType = ZYBICCSCmdGetConfigItems;
    m_data.body.status = 0;
    
    BYTE* buff = m_data.buff;
    FILL_VALUE_WITH_2_FIELD_BV(buff, sizeof(MSG_BODY), configIdx, 2);
    setBody((BYTE*)data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventCCS;
        
    return true;
}

bool BlCCSGetAvailableConfigMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlCCSGetAvailableConfigMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    offset+=getCCSItemValueList(data+offset, size-bodySize, m_itemlist);
    
    setBody((BYTE*)data, size, true);
    return true;
}

int BlCCSGetAvailableConfigMessage::subType() const
{
    return ZYBICCSCmdGetConfigItems;
}

NAMESPACE_ZY_END
