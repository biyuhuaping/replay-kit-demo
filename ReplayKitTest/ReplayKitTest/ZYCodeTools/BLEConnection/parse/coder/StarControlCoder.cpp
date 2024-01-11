//
//  StarControlCoder.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "StarControlCoder.h"
#include "crc.h"

const int MAX_STAR_MESSAGE_LEN = 7;

NAMESPACE_ZY_BEGIN

StarControlCoder::StarControlCoder()
: ControlCoder()
{
    this->reSize(MAX_STAR_MESSAGE_LEN);
    this->setContentType(SCCContentTypeFull);
    this->enableBigEndian(true);
}

StarControlCoder::~StarControlCoder()
{
    
}

int StarControlCoder::pushValue(int code, int param)
{
    BYTE channel = 0;
    if (m_eContentType == SCCContentTypeShort) {
        channel = 0x01;
    } else {
        channel = 0x06;
    }
    
    this->writeValue(channel, 1);
    this->writeValue(code, 2, m_bigEndian);
    this->writeValue(param, 2, m_bigEndian);
    unsigned int crc = zy::crc(this->getBuffer(), this->getCurrentSize());
    this->writeValue(crc, 2, m_bigEndian);
    
    return MAX_STAR_MESSAGE_LEN;
}

int StarControlCoder::popValue(int* code, int* param)
{
    this->readValue(code, 2, m_bigEndian);
    this->readValue(param, 2, m_bigEndian);
    return 0;
}

void StarControlCoder::getValidDataRange(int* start, int* lenght)
{
    int dataStart = 0;
    int dataLen = 0;
    switch (m_eContentType) {
        case SCCContentTypeData:
            dataStart = 1;
            dataLen = 4;
            break;
            
        case SCCContentTypeShort:
            dataStart = 0;
            dataLen = 5;
            break;
            
        case SCCContentTypeFull:
            dataStart = 0;
            dataLen = 7;
            break;
            
        default:
            break;
    }
    *start = dataStart;
    *lenght = dataLen;
}

int StarControlCoder::encode(BYTE** data, int* len, bool isCopy)
{
    int dataStart = 0;
    int dataLen = 0;
    this->getValidDataRange(&dataStart, &dataLen);
    if (!isCopy) {
        *len = dataLen;
        *data = (BYTE*)malloc(dataLen);
    }
    memcpy(*data, m_buff+dataStart, dataLen);
    return dataLen;
}

int StarControlCoder::encode(const StarMessage* message, BYTE** data, int* len)
{
    this->pushValue(message->getCode(), message->getParam());
    this->encode(data, len, false);
    return *len;
}

StarMessage* StarControlCoder::decode(BYTE* data, int len)
{
    if (this->isValid(data, len)) {
        int dataStart = 0;
        int dataLen = 0;
        this->getValidDataRange(&dataStart, &dataLen);
        if (m_eContentType == SCCContentTypeShort
            || m_eContentType == SCCContentTypeFull) {
            dataStart++;
        } else if (m_eContentType == SCCContentTypeData) {
            dataStart--;
        }
        this->resetData(data, dataLen);
        this->setCurrent(dataStart);
        
        int code = 0;
        int param = 0;
        this->popValue(&code, &param);
        
        if (m_eContentType == SCCContentTypeFull) {
            int crc = 0;
            this->readValue(&crc, 2, m_bigEndian);
            //TODO 缺少crc
        }
        
        return new StarMessage(code, param);
    }
    return NULL;
}

void StarControlCoder::setContentType(SCCContentType eType)
{
    m_eContentType = eType;
}

SCCContentType StarControlCoder::getContentType(void) const
{
    return m_eContentType;
}

bool StarControlCoder::isValid(BYTE* data, int len)
{
    bool result = false;
    switch (m_eContentType) {
        case SCCContentTypeData:
            result = (len >= 4);
            break;
            
        case SCCContentTypeShort:
            result = (len >= 5);
            break;
            
        case SCCContentTypeFull:
            result = (len >= 7);
            break;
            
        default:
            break;
    }
    return result;
}

bool StarControlCoder::canParse(BYTE* data, int len)
{
    return len >= 4;
}

NAMESPACE_ZY_END
