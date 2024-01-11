//
//  BlWiFiHotspotSETPSWMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/17.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef __BlWiFiHotspotSETPSWMessage_H__
#define __BlWiFiHotspotSETPSWMessage_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiHotspotSETPSWMessage : public BlWiFiMessage
{
public:
    BlWiFiHotspotSETPSWMessage();
    virtual ~BlWiFiHotspotSETPSWMessage();
    
    bool buildRequest(const char* wifiPsw);
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
    //respond
    uint8 m_wifiStatus;
};

NAMESPACE_ZY_END

#endif /* __BlWiFiHotspotSETPSWMessage_H__ */
