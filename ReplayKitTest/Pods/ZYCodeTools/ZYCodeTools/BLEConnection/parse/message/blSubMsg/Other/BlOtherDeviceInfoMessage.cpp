//
//  BlOtherDeviceInfoMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherDeviceInfoMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlOtherDeviceInfoMessage::BlOtherDeviceInfoMessage()
: zy::BlOtherMessage()
{
}

BlOtherDeviceInfoMessage::~BlOtherDeviceInfoMessage()
{
    
}

bool BlOtherDeviceInfoMessage::buildRequest(const char* szDeviceInfo)
{
    m_data.body.cmdType = ZYBIOtherCmdDeviceInfo;
    m_data.body.status = 0x00;
    
    BYTE* buff = m_data.buff;
    FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), szDeviceInfo, int(strlen(szDeviceInfo)+1));
    setBody((BYTE*)data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    return true;
}

bool BlOtherDeviceInfoMessage::buildResponse(BYTE* data, int size)
{    
    int bodySize = sizeof(BlOtherDeviceInfoMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(m_info, data+offset, std::min(size-offset, MAX_NAME_SIZE-1));
    offset += size-offset;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherDeviceInfoMessage::subType() const
{
    return ZYBIOtherCmdDeviceInfo;
}

NAMESPACE_ZY_END
