//
//  ZYBlHandleData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiDeviceData.h"
#import "BlWiFiDeviceMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiDeviceMessage);

@interface ZYBlWiFiDeviceData()
{
    BlWiFiDeviceMessage* _message;
}
@end

@implementation ZYBlWiFiDeviceData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiDeviceMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiDeviceMessage);
    if (self.dataType == 0) {
        message->buildRequest(_num);
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    [self setRawData:data freeWhenDone:YES];
}

-(void) setRawData:(void*)data freeWhenDone:(BOOL)free
{
    self.free = free;
    CAST_MESSAGE(BlWiFiDeviceMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiDeviceMessage*)data;
}

-(NSUInteger) num
{
    CAST_MESSAGE(BlWiFiDeviceMessage);
    return message->m_data.body.num;
}

-(NSString*) ssid
{
    CAST_MESSAGE(BlWiFiDeviceMessage);
    return [NSString stringWithUTF8String:message->m_ssid];
}


@end
