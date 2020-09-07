//
//  StarControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __STARCONTROLCODER_H__
#define __STARCONTROLCODER_H__

#include <stdio.h>
#include "ControlCoder.h"
#include "StarMessage.h"

NAMESPACE_ZY_BEGIN

class StarControlCoder : public ControlCoder {
public:
    StarControlCoder();
    virtual ~StarControlCoder();
    
    virtual int encode(BYTE** data, int* len, bool isCopy = true);
    
    //分配内存，由外部管理
    int encode(const StarMessage* message, BYTE** data, int* len);
    //分配内存，由外部管理
    StarMessage* decode(BYTE* data, int len);
    
    void setContentType(SCCContentType eType);
    SCCContentType getContentType(void) const;
    
    virtual bool isValid(BYTE* data, int len);
    
    static bool canParse(BYTE* data, int len);
protected:
    int pushValue(int code, int param);
    int popValue(int* code, int* param);
    void getValidDataRange(int* start, int* lenght);
    SCCContentType m_eContentType;
};

NAMESPACE_ZY_END

#endif /* __STARCONTROLCODER_H__ */
