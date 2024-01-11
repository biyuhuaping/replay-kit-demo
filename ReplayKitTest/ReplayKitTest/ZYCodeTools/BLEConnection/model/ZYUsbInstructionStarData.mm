//
//  ZYUsbInstructionStarData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbInstructionStarData.h"
#import "UsbInstructionStarMessage.h"
#import "ZYUsbData_internal.h"

using namespace zy;
SAFE_CAST_USB(UsbInstructionStarMessage);

@interface ZYUsbInstructionStarData()
{
    UsbInstructionStarMessage* _message;
}
@end

@implementation ZYUsbInstructionStarData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new UsbInstructionStarMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE_USB(UsbInstructionStarMessage);
    if (self.dataType == 0) {
        message->buildRequest(NULL);
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    CAST_MESSAGE_USB(UsbInstructionStarMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::UsbInstructionStarMessage*)data;
}

@end
