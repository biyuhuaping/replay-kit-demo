//
//  BlOtherCMD_KEYFUNC_DEFINE_SETMessage.c
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#include "BlOtherCMD_KEYFUNC_DEFINE_SETMessage.h"
#include <assert.h>

NAMESPACE_ZY_BEGIN

BlOtherCMD_KEYFUNC_DEFINE_SETMessage::BlOtherCMD_KEYFUNC_DEFINE_SETMessage()
: zy::BlOtherMessage()
{
}

BlOtherCMD_KEYFUNC_DEFINE_SETMessage::~BlOtherCMD_KEYFUNC_DEFINE_SETMessage()
{
    
}

bool BlOtherCMD_KEYFUNC_DEFINE_SETMessage::buildRequest(uint16 keyInfo,uint8 keyFun)
{
    m_data.body.cmdType = ZYBIOtherKEYFUNC_DEFINE_SET;
    m_data.body.keyInfo = keyInfo;
    m_data.body.keyFun = keyFun;

    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventOther;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BlOtherCMD_KEYFUNC_DEFINE_SETMessage::buildResponse(BYTE* data, int size)
{
     assert(size == sizeof(BlOtherCMD_KEYFUNC_DEFINE_SETMessage::MSG_BODY));
     memcpy(m_data.buff, data, size);
     setBody((BYTE*)data, size, true);
     return true;
}

int BlOtherCMD_KEYFUNC_DEFINE_SETMessage::subType() const
{
    return ZYBIOtherKEYFUNC_DEFINE_SET;
}

NAMESPACE_ZY_END
