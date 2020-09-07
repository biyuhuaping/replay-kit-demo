//
//  BLHDLCMDShowInfoMessage.cpp
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/4.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#include "BLHDLCMDShowInfoMessage.h"
#include <assert.h>
#include "ccsTool.h"

NAMESPACE_ZY_BEGIN

BLHDLCMDShowInfoMessage::BLHDLCMDShowInfoMessage()
: zy::BlHDLMessage()
{
}

BLHDLCMDShowInfoMessage::~BLHDLCMDShowInfoMessage()
{
    
}

bool BLHDLCMDShowInfoMessage::buildRequest()
{
    
//    BYTE* buff = m_data.buff;
//    //不存字符串结束符 MD5码是固定32位
//    int dataSize = 0;
//    if (szMD5 != NULL && strlen(szMD5) == 32) {
//        FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), szMD5, int(strlen(szMD5)));
//        setBody((BYTE*)data, dataLen, false);
//        dataSize = dataLen;
//    } else {
//        char md5[32] = {"/0"};
//        memset(md5, 0, 32);
//        FILL_VALUE_WITH_2_FIELD_BB(buff, sizeof(MSG_BODY), md5, 32);
//        setBody((BYTE*)data, dataLen, false);
//        dataSize = dataLen;
//    }
//
//    m_head.headCode = BL_HEAD_CODE_SEND;
//    m_head.lenght = 1+1+dataSize;
//    //APP发送指令包头地址统一为0x01
//    m_head.address = 0x01;
//    m_head.command = ZYBleInteractEvent;
//    m_head.status = ZYBleInteractEventOther;
    
    
    
    m_data.body.cmdType = ZYBlHDL_CMD_SHOW_INFO;
//    m_data.body.status = ZYBIOtherCmdValueFileSyn;
    
    m_head.headCode = BL_HEAD_CODE_SEND;
    m_head.lenght = 1+1+sizeof(MSG_BODY);
    //APP发送指令包头地址统一为0x01
    m_head.address = 0x01;
    m_head.command = ZYBleInteractEvent;
    m_head.status = ZYBleInteractEventHDL;
    
    setBody((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    return true;
}

bool BLHDLCMDShowInfoMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(BLHDLCMDShowInfoMessage::MSG_BODY);
    assert(size >= bodySize);
    memcpy(m_data.buff, data, bodySize);
    
    int offset = bodySize;
    memcpy(&m_status, data+offset, sizeof(m_status));
    offset += sizeof(m_status);
    
    assert(size == offset);
    setBody((BYTE*)data, size, true);
    return true;
}

int BLHDLCMDShowInfoMessage::subType() const
{
    return ZYBIOtherCmdCheckMD5;
}

NAMESPACE_ZY_END
