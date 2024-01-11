//
//  BlWiFiErrorMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIERRORMESSAGE_H__
#define __BLWIFIERRORMESSAGE_H__

#include "BlWiFiMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiErrorMessage : public BlWiFiMessage
{
public:
    BlWiFiErrorMessage();
    virtual ~BlWiFiErrorMessage();
    
    bool buildRequest();
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 errCode;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIERRORMESSAGE_H__ */
