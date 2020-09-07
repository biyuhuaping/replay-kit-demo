//
//  UsbInstructionHeartBeatMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBINSTRUCTIONHEARTBEATMESSAGE_H__
#define __USBINSTRUCTIONHEARTBEATMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "UsbInstructionMessage.h"

NAMESPACE_ZY_BEGIN

class UsbInstructionHeartBeatMessage : public UsbInstructionMessage
{
public:
    UsbInstructionHeartBeatMessage();
    virtual ~UsbInstructionHeartBeatMessage();
    
    bool buildRequest(uint8 flag, uint32 sec, uint32 usec);
    bool buildRequest(uint8 flag, uint32 sec, uint32 usec,uint16 msgId);

    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
    
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 flag;
        uint32 sec;
        uint32 usec;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __USBINSTRUCTIONHEARTBEATMESSAGE_H__ */
