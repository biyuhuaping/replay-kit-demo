//
//  BlCCSSetConfigMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlCCSSetConfigMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlCCSSetConfigMessage::BlCCSSetConfigMessage()
: zy::BlCCSMessage()
, m_configValue(NULL)
{
    
}

BlCCSSetConfigMessage::~BlCCSSetConfigMessage()
{
    SAFE_RELEASE_PRT(m_configValue);
}

bool BlCCSSetConfigMessage::buildRequest(int configIdx, const char* szValue)
{
    m_data.body.cmdType = ZYBICCSCmdSetConfigValue;
    m_data.body.status = 0;
    m_data.body.configIdx = configIdx;
    
    BYTE* buff = m_data.buff;
    FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), szValue, int(strlen(szValue)+1));
    setBody((BYTE*)data, dataLen, false);
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataLen;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventCCS;
    return true;
}

bool BlCCSSetConfigMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlCCSSetConfigMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    if (m_data.body.status == ZYBICCSCmdStatusWait) {
        setBody((BYTE*)data, size, true);
        return true;
    }
    
    int offset = bodySize;
    //    size_t len = strlen((const char*)(data+offset));
    //    if (len > MAX_NAME_SIZE-1) {
    //        return false;
    //    }
    //    memcpy(m_info, data+offset, len+1);
    //    offset += len+1;
    //TODO 临时测试
    if (m_configValue == NULL) {
        m_configValue = (char*)calloc(size-bodySize, 1);
    }
    memcpy(m_configValue, data+offset, size-bodySize);
    offset += size-bodySize;
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlCCSSetConfigMessage::subType() const
{
    return ZYBICCSCmdSetConfigValue;
}

NAMESPACE_ZY_END
