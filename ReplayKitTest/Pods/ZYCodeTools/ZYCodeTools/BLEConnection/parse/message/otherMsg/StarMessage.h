//
//  StarMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __STARMESSAGE_H__
#define __STARMESSAGE_H__

#include <stdio.h>
#include "BaseMessage.h"

NAMESPACE_ZY_BEGIN

const int STAR_DATA_LEN = 5;
#pragma pack(push)
#pragma pack(1)
typedef struct {
    uint8 adrs;
    uint16 code;
    uint16 param;
} star_struct;

typedef struct {
    uint16 runningNo;       //bit15-0  流水号
    uint16 customCode:8;    //bit23-16 定制码
    uint16 model:4;         //bit27-24 型号
    uint16 type:8;          //bit35-28 类别
    uint16 batchNo:12;      //bit47-36 批次号
    uint16 date:12;         //bit59-48 年月
} productSerialNo_struct;

typedef union {
    uint16 data[4];
    productSerialNo_struct serial;
} productSerialNo;

#pragma pack(pop)

class StarMessage : public BaseMessage
{
public:
    StarMessage(unsigned int code = 0, unsigned int param = 0);
    virtual ~StarMessage();
    
    void setCode(unsigned int code);
    unsigned int getCode() const;
    
    void setParam(unsigned int param);
    unsigned int getParam() const;
    
protected:
    unsigned int m_code;
    unsigned int m_param;
    
private:
    StarMessage(){};
};

NAMESPACE_ZY_END

#endif /* __STARMESSAGE_H__ */
