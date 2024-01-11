//
//  UsbInstructionMediaStreamMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBINSTRUCTIONMEDIASTREAMMESSAGE_H__
#define __USBINSTRUCTIONMEDIASTREAMMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "UsbInstructionMessage.h"

NAMESPACE_ZY_BEGIN

class UsbInstructionMediaStreamMessage : public UsbInstructionMessage
{
public:
    UsbInstructionMediaStreamMessage();
    virtual ~UsbInstructionMediaStreamMessage();
    
    bool buildRequest(uint8 flag);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 cmdStatus;
        uint8 cmdFlag;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __USBINSTRUCTIONMEDIASTREAMMESSAGE_H__ */
