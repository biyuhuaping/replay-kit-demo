//
//  ControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __CONTROLCODER_H__
#define __CONTROLCODER_H__

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include "common_def.h"
#include "common_macro.h"


NAMESPACE_ZY_BEGIN

class ControlCoder {
public:
    ControlCoder();
    virtual ~ControlCoder();
    
    int writeData(BYTE* data, int length);
    int readData(BYTE* data, int length);
    
    int writeValue(int value, int len, bool big_endian = false);
    int writeValue(unsigned int value, int len, bool big_endian = false);
    
    int readValue(int* value, int len, bool big_endian = false);
    int readValue(unsigned int* value, int len, bool big_endian = false);
    
    void reSize(int capacity);
    void clear();
    
    int copyData(BYTE* data, int len);
    void resetData(BYTE* data, int len);
    
    BYTE* getBuffer();
    int getCurrentSize();
    int getCapacitySize();
    void setCurrent(int current);
    
    virtual int encode(BYTE** data, int* len, bool isCopy = true);
    virtual bool isValid(BYTE* data, int len);
    
    void enableBigEndian(bool big_endian);
protected:
    void release();
    
    BYTE m_buff[2048];
    int m_current;
    int m_capacity;
    int m_bigEndian;
};

NAMESPACE_ZY_END

#endif /* __CONTROLCODER_H__ */
