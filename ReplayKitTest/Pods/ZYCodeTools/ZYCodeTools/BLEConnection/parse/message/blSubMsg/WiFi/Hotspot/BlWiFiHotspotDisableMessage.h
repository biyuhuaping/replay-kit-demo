//
//  BlWiFiHotspotDisableMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIHOTSPOTDISABLEMESSAGE_H__
#define __BLWIFIHOTSPOTDISABLEMESSAGE_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiHotspotDisableMessage : public BlWiFiMessage
{
public:
    BlWiFiHotspotDisableMessage();
    virtual ~BlWiFiHotspotDisableMessage();
    
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
    //respond
    uint8 m_wifiStatus;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIHOTSPOTDISABLEMESSAGE_H__ */
