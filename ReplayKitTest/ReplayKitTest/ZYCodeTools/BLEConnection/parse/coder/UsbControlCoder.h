//
//  BlControlCoder.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBCONTROLCODER_H__
#define __USBCONTROLCODER_H__

#include <stdio.h>

#include "ControlCoder.h"
#include "UsbMessage.h"

NAMESPACE_ZY_BEGIN

class UsbControlCoder : public ControlCoder {
public:
    UsbControlCoder();
    virtual ~UsbControlCoder();
    
    virtual int encode(BYTE** data, int* len, bool isCopy = true);
    
    //分配内存，由外部管理
    int encode(const UsbMessage* message, BYTE** data, int* len);
    //分配内存，由外部管理
    UsbMessage* decode(BYTE* data, int len);
        
    virtual bool isValid(BYTE* data, int len);
    
    static bool canParse(BYTE* data, int len);
    
    static void getMessageText(const UsbMessage* message, char* szText, int size);
protected:
    int pushValue(BYTE* data, int dataLen);
    //分配内存，由外部管理
    int popValue(UsbMessage::headCode& head, BYTE** body, int* bodyLen, unsigned short* crc);
    UsbMessage* buildUsbMessage(const UsbMessage::headCode& headCode, BYTE* data, int len);
    
    bool tryParseHead(BYTE* data, int len, UsbMessage::headCode* headCode);
    int calcBlMessageLength(const UsbMessage::headCode* head);
};

NAMESPACE_ZY_END

#endif /* __USBCONTROLCODER_H__ */
