//
//  BlControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLCONTROLCODER_H__
#define __BLCONTROLCODER_H__

#include <stdio.h>

#include "ControlCoder.h"
#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlControlCoder : public ControlCoder {
public:
    BlControlCoder();
    virtual ~BlControlCoder();
    
    virtual int encode(BYTE** data, int* len, bool isCopy = true);
    
    //分配内存，由外部管理
    int encode(const BlMessage* message, BYTE** data, int* len);
    //分配内存，由外部管理
    BlMessage* decode(BYTE* data, int len);
        
    virtual bool isValid(BYTE* data, int len);
    
    static bool canParse(BYTE* data, int len);
    
    static void getMessageText(const BlMessage* message, char* szText, int size);
protected:
    int pushValue(const BlMessage::head& head, BYTE* body, int bodyLen);
    //分配内存，由外部管理
    int popValue(BlMessage::head& head, BYTE** body, int* bodyLen, unsigned short* crc);
    
    bool tryParseHead(BYTE* data, int len, BlMessage::head* head);
    int calcBlMessageLength(const BlMessage::head* head);
};

NAMESPACE_ZY_END

#endif /* __BLCONTROLCODER_H__ */
