//
//  RdisControlCoder.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "RdisControlCoder.h"

#define MAX_INFO_LEN 128

NAMESPACE_ZY_BEGIN

RdisControlCoder::RdisControlCoder()
: ControlCoder()
{
    enableBigEndian(false);
}

RdisControlCoder::~RdisControlCoder()
{
    
}

int RdisControlCoder::pushValue(const RdisMessage* message)
{
    this->writeData((BYTE*)&message->getRdisInfo(), sizeof(RdisMessage::RDIS_ALL_INFO));
    return m_current;
}

int RdisControlCoder::popValue(RdisMessage* message)
{
    this->readData((BYTE*)&message->getRdisInfo(), sizeof(RdisMessage::RDIS_ALL_INFO));
    return 0;
}

int RdisControlCoder::encode(BYTE** data, int* len, bool isCopy)
{
    //memcpy(*data, m_buff+dataStart, dataLen);
    int dataLen = this->getCurrentSize();
    if (!isCopy) {
        *len = dataLen;
        *data = (BYTE*)malloc(dataLen);
    }
    memcpy(*data, m_buff, dataLen);
    return dataLen;
}

int RdisControlCoder::encode(const RdisMessage* message, BYTE** data, int* len)
{
    this->pushValue(message);
    this->encode(data, len, false);
    return *len;
}

RdisMessage* RdisControlCoder::decode(BYTE* data, int len)
{
    if (len == sizeof(RdisMessage::RDIS_ALL_INFO)) {
        BYTE* body = NULL;
        int bodyLen = 0;
        unsigned short crc = 0;
        
        this->resetData(data, len);
        
        RdisMessage* message = new RdisMessage();
        this->popValue(message);
        
        //TODO 缺少crc
        return message;
    }
    return NULL;
}

bool RdisControlCoder::isValid(BYTE* data, int len)
{
    return this->tryParseHead(data, len);
}

bool RdisControlCoder::tryParseHead(BYTE* data, int len)
{
    return len == sizeof(RdisMessage::RDIS_ALL_INFO);
}

bool RdisControlCoder::canParse(BYTE* data, int len)
{
    if (len < 10)
        return false;
    
    return true;
}

void RdisControlCoder::getMessageText(const RdisMessage* message, char* szText, int size)
{
    const int txtlen = MAX_INFO_LEN;
    char messageTxt[txtlen];
    memset(messageTxt, 0, txtlen);
    snprintf(messageTxt, txtlen-1, "%s", "rdis message");
}


int RdisControlCoder::calcBlMessageLength(const RdisMessage* message)
{
    return sizeof(RdisMessage::RDIS_ALL_INFO);
}

NAMESPACE_ZY_END
