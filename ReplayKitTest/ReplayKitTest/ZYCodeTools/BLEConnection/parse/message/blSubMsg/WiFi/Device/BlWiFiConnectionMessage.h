//
//  BlWiFiConnectionMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFICONNECTIONMESSAGE_H__
#define __BLWIFICONNECTIONMESSAGE_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiConnectionMessage : public BlWiFiMessage
{
public:
    BlWiFiConnectionMessage();
    virtual ~BlWiFiConnectionMessage();
    
    bool buildRequest(const char* ssid, const char* pwd);
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
    char m_pwd[MAX_NAME_SIZE];
    //respond
    uint8 m_flag;
};

NAMESPACE_ZY_END

#endif /* __BLWIFICONNECTIONMESSAGE_H__ */
