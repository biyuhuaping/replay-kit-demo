//
//  BlOtherHeartMessage.h
//  ZYCamera
//
//  Created by .
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BlOtherHeartMessage_H__
#define __BlOtherHeartMessage_H__

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherHeartMessage : public BlOtherMessage
{
public:
    BlOtherHeartMessage();
    virtual ~BlOtherHeartMessage();
    
    bool buildRequest(uint8 heartType);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 status;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    
    uint8 battery;
    uint8 errorType;

    
};

NAMESPACE_ZY_END

#endif /* __BlOtherHeartMessage_H__ */
