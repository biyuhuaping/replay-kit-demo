//
//  BlWiFiDeviceMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIDEVICEMESSAGE_H__
#define __BLWIFIDEVICEMESSAGE_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiDeviceMessage : public BlWiFiMessage
{
public:
    BlWiFiDeviceMessage();
    virtual ~BlWiFiDeviceMessage();
    
    bool buildRequest(int num);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 num;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //respond
    char m_ssid[MAX_NAME_SIZE];
};

NAMESPACE_ZY_END

#endif /* __BLWIFIDEVICEMESSAGE_H__ */
