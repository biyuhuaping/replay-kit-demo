//
//  BlOtherCheckMD5Message.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCheckMD5Message.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlOtherCheckMD5Message::BlOtherCheckMD5Message()
: zy::BlOtherMessage()
{
}

BlOtherCheckMD5Message::~BlOtherCheckMD5Message()
{
    
}

bool BlOtherCheckMD5Message::buildRequest(const char* szMD5)
{
    m_data.body.cmdType = ZYBIOtherCmdCheckMD5;
    
    BYTE* buff = m_data.buff;
    //不存字符串结束符 MD5码是固定32位
    int dataSize = 0;
    if (szMD5 != NULL && strlen(szMD5) == 32) {
        FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), szMD5, int(strlen(szMD5)));
        setBody((BYTE*)data, dataLen, false);
        dataSize = dataLen;
    } else {
        char md5[32] = {"/0"};
        memset(md5, 0, 32);
        FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), md5, 32);
        setBody((BYTE*)data, dataLen, false);
        dataSize = dataLen;
    }
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataSize;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    return true;
}

bool BlOtherCheckMD5Message::buildResponse(BYTE* data, int size)
{    
    int bodySize = sizeof(BlOtherCheckMD5Message::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_status, data+offset, sizeof(m_status));
    offset += sizeof(m_status);
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCheckMD5Message::subType() const
{
    return ZYBIOtherCmdCheckMD5;
}

NAMESPACE_ZY_END
