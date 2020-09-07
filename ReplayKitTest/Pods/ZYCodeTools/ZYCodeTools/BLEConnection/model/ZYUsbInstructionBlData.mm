//
//  ZYUsbInstructionBlData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbInstructionBlData.h"
#import "UsbInstructionBlMessage.h"
#import "ZYUsbData_internal.h"
#import "ZYBlData_internal.h"
#import "ZYBlControlCoder.h"

using namespace zy;
SAFE_CAST_USB(UsbInstructionBlMessage);

@interface ZYUsbInstructionBlData()
{
    UsbInstructionBlMessage* _message;
}
@end

@implementation ZYUsbInstructionBlData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new UsbInstructionBlMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE_USB(UsbInstructionBlMessage);
    if (self.dataType == 0) {
        const BlMessage* blMessage = (const BlMessage*)[_blData createRawData];
        message->buildRequest(blMessage);
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    UsbInstructionBlMessage* message = castToUsbInstructionBlMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::UsbInstructionBlMessage*)data;
    _blData = self.blData;
}

-(ZYBlData*) blData
{
    if (_blData) {
        return _blData;
    } else {
        UsbInstructionBlMessage* message = castToUsbInstructionBlMessage(self.message);
        const BlMessage* blMessage = message->getBlMessage();
        ZYBlData* blData = [ZYBlControlCoder buildBlData:(void*)blMessage];
        [blData setRawData:const_cast<BlMessage*>(blMessage) freeWhenDone:NO];
        blData.dataType = 1;
        return blData;
    }
}

-(NSUInteger) uid
{
    UsbInstructionBlMessage* message = castToUsbInstructionBlMessage(self.message);
    return message->getHead().content.cmdid;
}


@end
