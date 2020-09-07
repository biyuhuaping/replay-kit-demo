//
//  BlWiFiHotspotCHN_SCANMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/14.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlWiFiHotspotCHN_SCANMessage_h
#define BlWiFiHotspotCHN_SCANMessage_h

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN
class BlWiFiHotspotCHN_SCANMessage : public BlWiFiMessage
{
public:
    BlWiFiHotspotCHN_SCANMessage();
    virtual ~BlWiFiHotspotCHN_SCANMessage();
    
    bool buildRequest(uint8 opt, char *str);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
    } MSG_BODY;
    
    typedef struct {
        char scan_info[128];
    } scan_info;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //respond
    uint8 opt;
    scan_info infos[128];
};
NAMESPACE_ZY_END
#endif /* BlWiFiHotspotCHN_SCANMessage_h */
