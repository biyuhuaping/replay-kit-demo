//
//  UsbInstructionBlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbInstructionBlMessage.h"
#include <memory.h>
#include <string>
#include "crc.h"
#include "BlControlCoder.h"
#include "ccsTool.h"

static zy::BlControlCoder blCoder;

NAMESPACE_ZY_BEGIN

UsbInstructionBlMessage::UsbInstructionBlMessage()
: m_blMessage(NULL)
{
}

UsbInstructionBlMessage::~UsbInstructionBlMessage()
{
    SAFE_RELEASE_PRT(m_blMessage);
}

bool UsbInstructionBlMessage::buildRequest(const BlMessage* message)
{
    BYTE* blData;
    int bllen = 0;
    blCoder.clear();
    blCoder.encode(message, &blData, &bllen);
    
    uint8 cmdType = UsbMessageCodeZybl;
    FILL_VALUE_WITH_2_FIELD_VB(cmdType, 1, blData, bllen);
    setBuff((BYTE*)data, dataLen, false);
    free(blData);
    m_head.code.encryption = 0;
    m_head.code.type = UsbMessageTypeInstruction;
    m_head.code.lenBytes = 0x01;
    
    m_head.content.cmdid = genUID();
    m_head.content.crc = crc(data, dataLen);;
    m_head.content.len = dataLen;
    
    return true;
}

bool UsbInstructionBlMessage::buildResponse(BYTE* data, int size)
{
    setBuff((BYTE*)data, size, false);
    memcpy(&m_codeType, data, 1);
    
    blCoder.resetData(data, size);
    m_blMessage = blCoder.decode(data+1, size-1);
    //assert(m_blMessage!=NULL);
    return m_blMessage != NULL;
}

int UsbInstructionBlMessage::messageType() const
{
    return ZYUMTInstructionBl;
}

BlMessage* UsbInstructionBlMessage::getBlMessage() const
{
    return m_blMessage;
}

NAMESPACE_ZY_END
