//
//  BlOtherCMD_SEND_ACTIVEKEYMessage.c
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCMD_SEND_ACTIVEKEYMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BlOtherCMD_SEND_ACTIVEKEYMessage::BlOtherCMD_SEND_ACTIVEKEYMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMD_SEND_ACTIVEKEYMessage::~BlOtherCMD_SEND_ACTIVEKEYMessage()
{
    
}

bool BlOtherCMD_SEND_ACTIVEKEYMessage::buildRequest(BYTE* keydata, int size)
{
    m_data.body.cmdType = ZYBIOtherSET_ACTIVEINFO;
    BYTE* buff = m_data.buff;
    //不存字符串结束符 MD5码是固定32位
    int dataSize = 0;
//    if (keyData != NULL && strlen(keyData) > 0) {
//        FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), keyData, int(strlen(keyData)));
//        setBody((BYTE*)data, dataLen, true);
//        dataSize = dataLen;
//    } else {
//        char md5[16] = {"/0"};
//        memset(md5, 0, 16);
//
//    }
    FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), keydata, size);
    setBody((BYTE*)data, dataLen, true);
    dataSize = size;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+dataSize + 1;
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    return true;
}

bool BlOtherCMD_SEND_ACTIVEKEYMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherCMD_SEND_ACTIVEKEYMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&active_status, data+offset, sizeof(active_status));
    offset += sizeof(active_status);
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMD_SEND_ACTIVEKEYMessage::subType() const
{
    return ZYBIOtherSET_ACTIVEINFO;
}

NAMESPACE_ZY_END
