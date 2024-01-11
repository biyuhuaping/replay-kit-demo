//
//  BLHDLCMDShowInfoMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/4.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLHDLCMDShowInfoMessage_H__
#define __BLHDLCMDShowInfoMessage_H__

#include "BlHDLMessage.h"

NAMESPACE_ZY_BEGIN

class BLHDLCMDShowInfoMessage : public BlHDLMessage
{
public:
    BLHDLCMDShowInfoMessage();
    virtual ~BLHDLCMDShowInfoMessage();
    
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
    uint8 m_status;
    
};

NAMESPACE_ZY_END

#endif /* __BLHDLCMDShowInfoMessage_H__ */
