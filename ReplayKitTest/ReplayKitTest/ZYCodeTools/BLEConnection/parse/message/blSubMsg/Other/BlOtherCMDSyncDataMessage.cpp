//
//  BlOtherCMDSyncDataMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCMDSyncDataMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMDSyncDataMessage::BlOtherCMDSyncDataMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMDSyncDataMessage::~BlOtherCMDSyncDataMessage()
{
    
}

bool BlOtherCMDSyncDataMessage::buildRequest(int configIdx,uint8 msgId)
{
    m_data.body.cmdType = ZYBIOtherCmdSyncData;
    m_data.body.msgId = msgId;

    
    BYTE* buff = m_data.buff;
    int temp = 0;
    FILL_VALUE_WITH_3_FIELD_BV(buff, sizeof(MSG_BODY), configIdx, 1,temp,1);
    setBody((BYTE*)data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;

    return true;
}

bool BlOtherCMDSyncDataMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherCMDSyncDataMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    offset+=getSyncItemValueList(data+offset, size-bodySize, m_itemlist);
    
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMDSyncDataMessage::subType() const
{
    return ZYBIOtherCmdSyncData;
}

NAMESPACE_ZY_END

