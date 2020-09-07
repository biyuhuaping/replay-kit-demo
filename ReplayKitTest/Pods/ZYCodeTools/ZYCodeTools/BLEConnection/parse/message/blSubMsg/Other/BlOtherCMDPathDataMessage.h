//
//  BlOtherCMDPathDataMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMDPathDataMessage_h
#define BlOtherCMDPathDataMessage_h
#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCMDPathDataMessage : public BlOtherMessage
{
public:
    BlOtherCMDPathDataMessage();
    virtual ~BlOtherCMDPathDataMessage();
    
    bool buildRequest(uint8 flag, uint8 state);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 flag;//
        uint8 state;//
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END


#endif /* BlOtherCMDPathDataMessage_h */
