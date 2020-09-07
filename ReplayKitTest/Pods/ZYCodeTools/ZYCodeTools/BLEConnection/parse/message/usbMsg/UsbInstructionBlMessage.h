//
//  UsbInstructionBlMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBINSTRUCTIONBLMESSAGE_H__
#define __USBINSTRUCTIONBLMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "BlMessage.h"
#include "UsbInstructionMessage.h"

NAMESPACE_ZY_BEGIN

class UsbInstructionBlMessage : public UsbInstructionMessage
{
public:
    UsbInstructionBlMessage();
    virtual ~UsbInstructionBlMessage();
    
    bool buildRequest(const BlMessage* message);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
    
    BlMessage* getBlMessage() const;
private:
    BlMessage* m_blMessage;
};

NAMESPACE_ZY_END

#endif /* __USBINSTRUCTIONBLMESSAGE_H__ */
