//
//  BlOtherOTAWaitMessage.hpp
//  ZYCamera
//
//  Created by wpj on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLOTHEROTAWAITMESSAGE_H__
#define __BLOTHEROTAWAITMESSAGE_H__

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherOTAWaitMessage : public BlOtherMessage
{
    
public:
    BlOtherOTAWaitMessage();
    virtual ~BlOtherOTAWaitMessage();
    
    bool buildRequest();
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
    union{
        MSG_BODY body;
        BYTE buff[1];
    } m_data;    
};

NAMESPACE_ZY_END

#endif /* __BLOTHEROTAWAITMESSAGE_H__ */
