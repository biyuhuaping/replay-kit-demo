//
//  BlOtherCMD_KEYFUNC_DEFINE_READMessage.c
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCMD_KEYFUNC_DEFINE_READMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMD_KEYFUNC_DEFINE_READMessage::BlOtherCMD_KEYFUNC_DEFINE_READMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMD_KEYFUNC_DEFINE_READMessage::~BlOtherCMD_KEYFUNC_DEFINE_READMessage()
{
    
}

bool BlOtherCMD_KEYFUNC_DEFINE_READMessage::buildRequest(uint16 keyInfo)
{
    m_data.body.cmdType = ZYBIOtherKEYFUNC_DEFINE_READ;
    m_data.body.keyInfo = keyInfo;

    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}


bool BlOtherCMD_KEYFUNC_DEFINE_READMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BlOtherCMD_KEYFUNC_DEFINE_READMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
       
    int offset = bodySize;
    int minSize = sizeof(uint8);
    while (offset+minSize <= size) {
        uint8 value;
        memcpy(&value, data+offset, 1);
        offset += 1;
        keyFunlist.push_back(value);
    }
   setBody((BYTE*)data, size, true);
    return true;
}

int BlOtherCMD_KEYFUNC_DEFINE_READMessage::subType() const
{
    return ZYBIOtherKEYFUNC_DEFINE_READ;
}

NAMESPACE_ZY_END
