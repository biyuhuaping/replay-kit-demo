//
//  ZYUsbInstructionMediaStreamData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbInstructionMediaStreamData.h"
#import "UsbInstructionMediaStreamMessage.h"
#import "ZYUsbData_internal.h"

using namespace zy;
SAFE_CAST_USB(UsbInstructionMediaStreamMessage);

@interface ZYUsbInstructionMediaStreamData()
{
    UsbInstructionMediaStreamMessage* _message;
}
@end

@implementation ZYUsbInstructionMediaStreamData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new UsbInstructionMediaStreamMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE_USB(UsbInstructionMediaStreamMessage);
    if (self.dataType == 0) {
        message->buildRequest(_flag);
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    CAST_MESSAGE_USB(UsbInstructionMediaStreamMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::UsbInstructionMediaStreamMessage*)data;
}

-(NSUInteger) uid
{
    CAST_MESSAGE_USB(UsbInstructionMediaStreamMessage);
    return message->getHead().content.cmdid;
}

-(NSUInteger) cmdStatus
{
    CAST_MESSAGE_USB(UsbInstructionMediaStreamMessage);
    return message->m_data.body.cmdStatus;
}

-(NSUInteger) flag
{
    CAST_MESSAGE_USB(UsbInstructionMediaStreamMessage);
    return message->m_data.body.cmdFlag;
}

@end
