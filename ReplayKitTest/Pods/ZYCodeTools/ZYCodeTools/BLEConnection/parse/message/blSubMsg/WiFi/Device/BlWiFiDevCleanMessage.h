//
//  BlWiFiDevCleanMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIDEVCLEANMESSAGE_H__
#define __BLWIFIDEVCLEANMESSAGE_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiDevCleanMessage : public BlWiFiMessage
{
public:
    BlWiFiDevCleanMessage();
    virtual ~BlWiFiDevCleanMessage();
    
    bool buildRequest(const char* ssid);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //request
    char m_ssid[MAX_NAME_SIZE];
    //respond
    uint8 m_flag;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIDEVCLEANMESSAGE_H__ */
