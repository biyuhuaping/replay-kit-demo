//
//  BlOtherFileAsynMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherFileAsynMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherFileAsynMessage::BlOtherFileAsynMessage()
: zy::BlOtherMessage()
{
}

BlOtherFileAsynMessage::~BlOtherFileAsynMessage()
{
    
}

bool BlOtherFileAsynMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIOtherCmdFileAsyn;
    m_data.body.status = ZYBIOtherCmdValueFileSyn;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherFileAsynMessage::buildResponse(BYTE* data, int size)
{
    assert(size == sizeof(BlOtherFileAsynMessage::MSG_BODY));
    memcpy(m_data.buff, data, size);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherFileAsynMessage::subType() const
{
    return ZYBIOtherCmdFileAsyn;
}

NAMESPACE_ZY_END
