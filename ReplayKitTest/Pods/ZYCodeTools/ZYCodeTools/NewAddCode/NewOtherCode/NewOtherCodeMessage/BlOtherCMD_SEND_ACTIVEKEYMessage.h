//
//  BlOtherCMD_SEND_ACTIVEKEYMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMD_SEND_ACTIVEKEYMessage_h
#define BlOtherCMD_SEND_ACTIVEKEYMessage_h

#include "BlOtherMessage.h"
NAMESPACE_ZY_BEGIN

class BlOtherCMD_SEND_ACTIVEKEYMessage : public BlOtherMessage
{
public:
    BlOtherCMD_SEND_ACTIVEKEYMessage();
    virtual ~BlOtherCMD_SEND_ACTIVEKEYMessage();
    
    bool buildRequest(BYTE* data, int size);
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
       uint8 active_status;
};

NAMESPACE_ZY_END

#endif /* BlOtherCMD_SEND_ACTIVEKEYMessage_h */
