//
//  BlWiFiHotspotCHNMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/14.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlWiFiHotspotCHNMessage_h
#define BlWiFiHotspotCHNMessage_h

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN
class BlWiFiHotspotCHNMessage : public BlWiFiMessage
{
public:
    BlWiFiHotspotCHNMessage();
    virtual ~BlWiFiHotspotCHNMessage();
    
    bool buildRequest(uint8 opt, uint8 status, char *chn_info);
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
    
    uint8 opt;
    uint8 status;
    char chn_info[4];
};
NAMESPACE_ZY_END
#endif /* BlWiFiHotspotCHNMessage_h */
