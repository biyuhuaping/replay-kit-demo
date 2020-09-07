//
//  UsbInstructionStarMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbInstructionStarMessage.h"
#include <memory.h>
#include <string>
#include "crc.h"
#include "StarControlCoder.h"

static zy::StarControlCoder starCoder;

NAMESPACE_ZY_BEGIN

UsbInstructionStarMessage::UsbInstructionStarMessage()
: m_starMessage(NULL)
{
}

UsbInstructionStarMessage::~UsbInstructionStarMessage()
{
    SAFE_RELEASE_PRT(m_starMessage);
}

bool UsbInstructionStarMessage::buildRequest(const StarMessage* message)
{
    BYTE* data;
    int len = 0;
    starCoder.clear();
    starCoder.encode(message, &data, &len);
    
    int allLen = len;
    BYTE* allData = (BYTE*)calloc(1, allLen);
    memcpy(allData, data, allLen);
    setBuff(allData, allLen, false);
    
    if (data != NULL) {
        free(data);
        data = NULL;
    }
    
    m_head.code.encryption = 0;
    m_head.code.type = UsbMessageTypeInstruction;
    m_head.code.lenBytes = 0x01;
    
    m_head.content.cmdid = genUID();
    m_head.content.crc = crc(data, len);;
    m_head.content.len = len;
    
    return true;
}

bool UsbInstructionStarMessage::buildResponse(BYTE* data, int size)
{
    setBuff((BYTE*)data, size, false);
    
    starCoder.resetData(data, size);
    m_starMessage = starCoder.decode(data, size);
    assert(m_starMessage!=NULL);
    return true;
}

int UsbInstructionStarMessage::messageType() const
{
    return ZYUMTInstructionStar;
}

StarMessage* UsbInstructionStarMessage::getStarMessage() const
{
    return m_starMessage;
}

NAMESPACE_ZY_END
