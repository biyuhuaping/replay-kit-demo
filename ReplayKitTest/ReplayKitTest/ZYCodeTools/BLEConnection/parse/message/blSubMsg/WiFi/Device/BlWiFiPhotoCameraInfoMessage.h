//
//  BlWiFiPhotoCameraInfoMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlWiFiPhotoCameraInfoMessage_h
#define BlWiFiPhotoCameraInfoMessage_h
#include "BlWiFiPhotoMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiPhotoCameraInfoMessage : public BlWiFiPhotoMessage
{
public:
    BlWiFiPhotoCameraInfoMessage();
    virtual ~BlWiFiPhotoCameraInfoMessage();
    
    virtual int subPhotoType() const;
    
    bool buildRequest(uint8 flag,uint8 value);
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 photoCmdType;
        uint8 value;

    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END


#endif /* BlWiFiPhotoCameraInfoMessage_h */
