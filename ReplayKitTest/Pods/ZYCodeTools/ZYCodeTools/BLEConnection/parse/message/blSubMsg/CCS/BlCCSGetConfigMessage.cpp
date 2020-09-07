//
//  BlCCSGetConfigMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlCCSGetConfigMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlCCSGetConfigMessage::BlCCSGetConfigMessage()
: zy::BlCCSMessage()
{
}

BlCCSGetConfigMessage::~BlCCSGetConfigMessage()
{
    
}

bool BlCCSGetConfigMessage::buildRequest(uint16 configIdx)
{
    m_data.body.cmdType = ZYBICCSCmdGetConfigValue;
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

bool BlCCSGetConfigMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlCCSGetConfigMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    //|| m_data.body.status == ZYBICCSCmdStatusGenErr
    if (m_data.body.status == ZYBICCSCmdStatusWait ) {
        setBody((BYTE*)data, size, true);
        return true;
    }
    
    int offset = bodySize;
    offset+=getCCSItemValueList(data+offset, size-bodySize, m_itemlist);
    
//    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlCCSGetConfigMessage::subType() const
{
    return ZYBICCSCmdGetConfigValue;
}

NAMESPACE_ZY_END
