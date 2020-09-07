//
//  BlOtherCustomFileMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCustomFileMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCustomFileMessage::BlOtherCustomFileMessage()
: zy::BlOtherMessage()
{
}

BlOtherCustomFileMessage::~BlOtherCustomFileMessage()
{
    
}

bool BlOtherCustomFileMessage::buildRequest(int page,uint8 direction,uint8 dataLen, BYTE* data)
{
    m_data.body.cmdType = ZYBIOtherCmdCustomFile;
    m_data.body.page = page;
    m_data.body.direction = direction;
    if (data != NULL) {
        memset(m_data.body.data, 0, sizeof(m_data.body.data));
        uint8 lenth = sizeof(m_data.body.data) > dataLen?dataLen:sizeof(m_data.body.data);
        memcpy(m_data.body.data, data, lenth);
    }
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCustomFileMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherCustomFileMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCustomFileMessage::subType() const
{
    return ZYBIOtherCmdCustomFile;
}

NAMESPACE_ZY_END
