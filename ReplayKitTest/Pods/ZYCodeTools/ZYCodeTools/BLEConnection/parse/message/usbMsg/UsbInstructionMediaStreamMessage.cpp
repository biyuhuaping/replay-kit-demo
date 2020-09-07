//
//  UsbInstructionBlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbInstructionMediaStreamMessage.h"
#include <memory.h>
#include <string>
#include "crc.h"

NAMESPACE_ZY_BEGIN

UsbInstructionMediaStreamMessage::UsbInstructionMediaStreamMessage()
{
}

UsbInstructionMediaStreamMessage::~UsbInstructionMediaStreamMessage()
{
}

bool UsbInstructionMediaStreamMessage::buildRequest(uint8 flag)
{
    m_data.body.cmdType = UsbMessageCodeMediaStream;
    m_data.body.cmdStatus = UMCMediaStreamStatusSuccess;
    m_data.body.cmdFlag = flag;
    
    setBuff((BYTE*)m_data.buff, sizeof(MSG_BODY), true);
    
    m_head.code.encryption = 0;
    m_head.code.type = UsbMessageTypeInstruction;
    m_head.code.lenBytes = 0x01;
    
    m_head.content.cmdid = genUID();
    m_head.content.crc = crc(m_buff, m_buffSize);
    m_head.content.len = m_buffSize;
    
    return true;
}

bool UsbInstructionMediaStreamMessage::buildResponse(BYTE* data, int size)
{
    int bodySize = sizeof(UsbInstructionMediaStreamMessage::MSG_BODY);
    assert(size == bodySize);
    memcpy(m_data.buff, data, bodySize);
    int offset = bodySize;
    
    assert(size == offset);
    setBuff((BYTE*)data, size, false);
    
    return true;
}

int UsbInstructionMediaStreamMessage::messageType() const
{
    return ZYUMTInstructionMS;
}

NAMESPACE_ZY_END
