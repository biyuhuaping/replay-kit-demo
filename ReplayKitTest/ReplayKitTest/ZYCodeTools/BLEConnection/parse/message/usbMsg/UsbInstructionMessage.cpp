//
//  BlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "UsbInstructionMessage.h"
#include <memory.h>
#include <string>

NAMESPACE_ZY_BEGIN

UsbInstructionMessage::UsbInstructionMessage()
: UsbMessage()
, m_crc(0)
{
    memset(&m_head, 0, sizeof(head));
}

UsbInstructionMessage::~UsbInstructionMessage()
{
}

void UsbInstructionMessage::setHead(const head& head)
{
    m_head = head;
}

UsbInstructionMessage::head& UsbInstructionMessage::getHead() const
{
    return const_cast<UsbInstructionMessage::head&>(m_head);
}

BYTE* UsbInstructionMessage::getHeadPtr() const
{
    return (BYTE*)&m_head;
}

int UsbInstructionMessage::getHeadSize() const
{
    return sizeof(UsbInstructionMessage::head);
}

unsigned short UsbInstructionMessage::getCrc() const
{
    return m_crc;
}

bool UsbInstructionMessage::buildResponse(BYTE* data, int size)
{
    //assert(false);
    return false;
}

int UsbInstructionMessage::messageType() const
{
    return ZYUMTInstruction;
}

NAMESPACE_ZY_END
