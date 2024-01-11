//
//  ControlCoder.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "ControlCoder.h"
#include <assert.h>

#define  REVERSE_ORDER(val)
#define MAX_BUFF_LEN 2048

static unsigned int reverseOrderWithLenght(unsigned int value, int len)
{
    if (len == 2) {
        return ((value&0x000000FF)<<8)|((value&0x0000FF00)>>8);
    } else if (len == 4) {
        return ((value&0x000000FF)<<24)|((value&0x0000FF00)<<8)|((value&0x00FF0000)>>8)|((value&0xFF000000)>>24);
    }
    return value;
}

NAMESPACE_ZY_BEGIN

ControlCoder::ControlCoder()
: m_current(0)
, m_capacity(0)
, m_bigEndian(false)
{
    reSize(MAX_BUFF_LEN);
}

ControlCoder::~ControlCoder()
{
    this->release();
}

int ControlCoder::writeData(BYTE* data, int length)
{
    if (m_current+length<=m_capacity) {
        memcpy(m_buff+m_current, data, length);
        m_current+=length;
        return length;
    }
    return 0;
}

int ControlCoder::readData(BYTE* data, int length)
{
    if (m_current+length<=m_capacity) {
        memcpy(data, m_buff+m_current, length);
        m_current+=length;
        return length;
    }
    return 0;
}

int ControlCoder::writeValue(int value, int len, bool big_endian)
{
    value = big_endian ? reverseOrderWithLenght(value, len):value;
    return this->writeData((BYTE*)&value, len);
}

int ControlCoder::writeValue(unsigned int value, int len, bool big_endian)
{
    value = big_endian ? reverseOrderWithLenght(value, len):value;
    return this->writeData((BYTE*)&value, len);
}

int ControlCoder::readValue(int* value, int len, bool big_endian)
{
    *value = 0;
    int ret = this->readData((BYTE*)value, len);
    *value = big_endian ? reverseOrderWithLenght(*value, len):*value;
    return ret;
}

int ControlCoder::readValue(unsigned int* value, int len, bool big_endian)
{
    *value = 0;
    int ret = this->readData((BYTE*)value, len);
    *value = big_endian ? reverseOrderWithLenght(*value, len):*value;
    return ret;
}

void ControlCoder::reSize(int capacity)
{
//    BYTE* newBuff = (BYTE*)malloc(m_capacity);
//    if (m_buff) {
//        memcpy(newBuff, m_buff, m_current);
//        this->release();
//    }
//    m_buff = newBuff;
    m_capacity = capacity;
}

void ControlCoder::clear()
{
    memset(m_buff, 0, m_capacity);
    m_current = 0;
    //TODO 如果使用动态缓冲区 需要删除以下代码
    m_capacity = MAX_BUFF_LEN;
}

int ControlCoder::copyData(BYTE* data, int len)
{
    if (m_current < len) {
        memcpy(data, m_buff, m_current);
        return m_current;
    }
    return 0;
}

void ControlCoder::resetData(BYTE* data, int len)
{
    assert(len <= MAX_BUFF_LEN);
    if (m_buff && m_capacity != len) {
        this->release();
        this->reSize(len);
    }
    
    memcpy(m_buff, data, len);
    m_current = 0;
    m_capacity = len;
}

BYTE* ControlCoder::getBuffer()
{
    return m_buff;
}

int ControlCoder::getCurrentSize()
{
    return m_current;
}

int ControlCoder::getCapacitySize()
{
    return m_capacity;
}

void ControlCoder::setCurrent(int current)
{
    m_current = current;
}

int ControlCoder::encode(BYTE** data, int* len, bool isCopy)
{
    if (!isCopy) {
        *len = m_current;
        *data = (BYTE*)malloc(m_current);
    }
    memcpy(*data, m_buff, m_current);
    return m_current;
}

bool ControlCoder::isValid(BYTE* data, int len)
{
    return false;
}

void ControlCoder::enableBigEndian(bool big_endian)
{
    m_bigEndian = big_endian;
}

void ControlCoder::release()
{
//    if (m_buff) {
//        free(m_buff);
//        m_buff = NULL;
//        m_capacity = 0;
//        m_current = 0;
//    }
}

NAMESPACE_ZY_END

