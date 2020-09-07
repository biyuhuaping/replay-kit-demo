//
//  ZYBlData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYUsbData.h"
#import "UsbMessage.h"
#import "ZYUsbData_internal.h"
using namespace zy;
SAFE_CAST_USB(UsbMessage);

@interface ZYUsbData()
{
    UsbMessage* _message;
}
@end

@implementation ZYUsbData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new UsbMessage();
    }
    return self;
}

-(void) dealloc
{    
    UsbMessage* message = castToUsbMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
}

-(void*) createRawData
{
    return self.message;
}

-(void) setRawData:(void*)data
{
    UsbMessage* message = castToUsbMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::UsbMessage*)data;
}

@end
