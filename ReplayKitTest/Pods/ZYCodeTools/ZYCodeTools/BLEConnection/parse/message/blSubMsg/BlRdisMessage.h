//
//  BlWiFiMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLRDISMESSAGE_H__
#define __BLRDISMESSAGE_H__

#include "BlMessage.h"
#include "RdisMessage.h"

NAMESPACE_ZY_BEGIN

class BlRdisMessage : public BlMessage
{
public:
    BlRdisMessage();
    virtual ~BlRdisMessage();
    
    bool buildRequest(const RdisMessage* message);
    virtual bool buildResponse(BYTE* data, int size);
    
    const RdisMessage* getRdisMessage() const;
private:
    RdisMessage* m_rdisMessage;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTOMESSAGE_H__ */
