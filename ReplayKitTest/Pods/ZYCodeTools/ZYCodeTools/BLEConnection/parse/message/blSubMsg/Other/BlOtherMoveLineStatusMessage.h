//
//  BlOtherMoveLineStatusMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef __BlOtherMoveLineStatusMessage_H__
#define __BlOtherMoveLineStatusMessage_H__

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherMoveLineStatusMessage : public BlOtherMessage
{
public:
    BlOtherMoveLineStatusMessage();
    virtual ~BlOtherMoveLineStatusMessage();
    
    bool buildRequest(uint8 status);
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
};

NAMESPACE_ZY_END

#endif /* BlOtherMoveLineStatusMessage_h */
