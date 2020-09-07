//
//  BlOtherCMD_CHECK_ACTIVEINFOMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMD_CHECK_ACTIVEINFOMessage_h
#define BlOtherCMD_CHECK_ACTIVEINFOMessage_h
#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCMD_CHECK_ACTIVEINFOMessage : public BlOtherMessage
{
public:
    BlOtherCMD_CHECK_ACTIVEINFOMessage();
    virtual ~BlOtherCMD_CHECK_ACTIVEINFOMessage();
    
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
    
    //response:
    BYTE buffData[16];
};

NAMESPACE_ZY_END

#endif /* BlOtherCMD_CHECK_ACTIVEINFOMessage_h */
