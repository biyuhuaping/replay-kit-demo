//
//  UsbInstructionStarMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBINSTRUCTIONSTARMESSAGE_H__
#define __USBINSTRUCTIONSTARMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "StarMessage.h"
#include "UsbInstructionMessage.h"

NAMESPACE_ZY_BEGIN

class UsbInstructionStarMessage : public UsbInstructionMessage
{
public:
    UsbInstructionStarMessage();
    virtual ~UsbInstructionStarMessage();
    
    bool buildRequest(const StarMessage* message);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
    
    StarMessage* getStarMessage() const;
private:
    StarMessage* m_starMessage;
};

NAMESPACE_ZY_END

#endif /* __USBINSTRUCTIONSTARMESSAGE_H__ */
