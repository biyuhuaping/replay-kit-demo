//
//  UsbInstructionHeartBeatMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbInstructionHeartBeatMessage.h"
#include <memory.h>
#include <string>
#include "crc.h"

NAMESPACE_ZY_BEGIN

UsbInstructionHeartBeatMessage::UsbInstructionHeartBeatMessage()
{
}

UsbInstructionHeartBeatMessage::~UsbInstructionHeartBeatMessage()
{
}

bool UsbInstructionHeartBeatMessage::buildRequest(uint8 flag, uint32 sec, uint32 usec)
{
//    m_data.body.cmdType = UsbMessageCodeHeartBeat;
//    m_data.body.flag = flag;
//    m_data.body.sec = sec;
//    m_data.body.usec = usec;
//    
//    setBuff((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
//    
//    m_head.code.encryption = 0;
//    m_head.code.type = UsbMessageTypeInstruction;
//    m_head.code.lenBytes = 0x01;
//    
//    m_head.content.cmdid = genUID();
//    m_head.content.crc = crc(m_buff, m_buffSize);
//    m_head.content.len = m_buffSize;
    
    return this->buildRequest(flag, sec, usec, genUID());
//    return true;
}
bool UsbInstructionHeartBeatMessage::buildRequest(uint8 flag, uint32 sec, uint32 usec,uint16 msgid)
{

    m_data.body.cmdType = UsbMessageCodeHeartBeat;
    m_data.body.flag = flag;
    m_data.body.sec = sec;
    m_data.body.usec = usec;
    
    setBuff((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    
    m_head.code.encryption = 0;
    m_head.code.type = UsbMessageTypeInstruction;
    m_head.code.lenBytes = 0x01;
    
    m_head.content.cmdid = msgid;
    m_head.content.crc = crc(m_buff, m_buffSize);
    m_head.content.len = m_buffSize;
    
    return true;
}

bool UsbInstructionHeartBeatMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(UsbInstructionHeartBeatMessage::MSG_BODY);
    assert(size == bodySize);
    memcpy(m_data.buff, data, bodySize);
    int offset = bodySize;
    
    assert(size == offset);
    setBuff((BYTE*)data, size, false);
    
    return true;
}

int UsbInstructionHeartBeatMessage::messageType() const
{
    return ZYUMTInstructionHB;
}

NAMESPACE_ZY_END
