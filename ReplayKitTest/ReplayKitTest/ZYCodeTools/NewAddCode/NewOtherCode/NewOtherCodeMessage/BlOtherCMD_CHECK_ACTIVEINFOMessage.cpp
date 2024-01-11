//
//  BlOtherCMD_CHECK_ACTIVEINFOMessage.c
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCMD_CHECK_ACTIVEINFOMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMD_CHECK_ACTIVEINFOMessage::BlOtherCMD_CHECK_ACTIVEINFOMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMD_CHECK_ACTIVEINFOMessage::~BlOtherCMD_CHECK_ACTIVEINFOMessage()
{
    
}

bool BlOtherCMD_CHECK_ACTIVEINFOMessage::buildRequest()
{
    m_data.body.cmdType = ZYBIOtherCHECK_ACTIVEINFO;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCMD_CHECK_ACTIVEINFOMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherCMD_CHECK_ACTIVEINFOMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    if (size >= bodySize + 16) {
        int offset = bodySize;
        memcpy(buffData, data+offset, 16);
    }
    
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMD_CHECK_ACTIVEINFOMessage::subType() const
{
    return ZYBIOtherCHECK_ACTIVEINFO;
}

NAMESPACE_ZY_END
