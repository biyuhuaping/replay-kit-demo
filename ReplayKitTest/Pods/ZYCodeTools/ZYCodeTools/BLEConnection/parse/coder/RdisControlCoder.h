//
//  RdisControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __RDISCONTROLCODER_H__
#define __RDISCONTROLCODER_H__

#include <stdio.h>

#include "ControlCoder.h"
#include "RdisMessage.h"

NAMESPACE_ZY_BEGIN

class RdisControlCoder : public ControlCoder {
public:
    RdisControlCoder();
    virtual ~RdisControlCoder();
    
    virtual int encode(BYTE** data, int* len, bool isCopy = true);
    
    //分配内存，由外部管理
    int encode(const RdisMessage* message, BYTE** data, int* len);
    //分配内存，由外部管理
    RdisMessage* decode(BYTE* data, int len);
    
    virtual bool isValid(BYTE* data, int len);
    
    static bool canParse(BYTE* data, int len);
    static void getMessageText(const RdisMessage* message, char* szText, int size);
protected:
    int pushValue(const RdisMessage* message);
    int popValue(RdisMessage* message);
    
    bool tryParseHead(BYTE* data, int len);
    int calcBlMessageLength(const RdisMessage* message);
};

NAMESPACE_ZY_END

#endif /* __RDISCONTROLCODER_H__ */
