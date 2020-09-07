//
//  BlWiFiHotspotGET_CHNLISTMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/14.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlWiFiHotspotGET_CHNLISTMessage_h
#define BlWiFiHotspotGET_CHNLISTMessage_h

#include "BlWiFiMessage.h"

 NAMESPACE_ZY_BEGIN
class BlWiFiHotspotGET_CHNLISTMessage : public BlWiFiMessage
{
public:
    BlWiFiHotspotGET_CHNLISTMessage();
    virtual ~BlWiFiHotspotGET_CHNLISTMessage();
    
    bool buildRequest();
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
    
    uint8 chn_status;
    char chn_list[1024];
};
NAMESPACE_ZY_END
#endif /* BlWiFiHotspotGET_CHNLISTMessage_h */
