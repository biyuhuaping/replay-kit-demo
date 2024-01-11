//
//  BlWiFiMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLHANDLEMESSAGE_H__
#define __BLHANDLEMESSAGE_H__

#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlHandleMessage : public BlMessage
{
public:
    BlHandleMessage();
    virtual ~BlHandleMessage();
    
    bool buildRequest(uint8 cmd, uint16 arg);
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdId;
        uint8 cmd;
        uint16 arg;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTOMESSAGE_H__ */
