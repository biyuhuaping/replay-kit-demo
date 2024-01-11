//
//  ZYBlOtherDeviceInfoData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherDeviceInfoData.h"
#import "BlOtherDeviceInfoMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherDeviceInfoMessage);

@interface ZYBlOtherDeviceInfoData()
{
    BlOtherDeviceInfoMessage* _message;
}
@end

@implementation ZYBlOtherDeviceInfoData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherDeviceInfoMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherDeviceInfoMessage);
    if (self.dataType == 0) {
        message->buildRequest([_localInfo UTF8String]);
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
    CAST_MESSAGE(BlOtherDeviceInfoMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherDeviceInfoMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlOtherDeviceInfoMessage);
    return message->m_data.body.status;
}

-(NSString*) remoteInfo
{
    CAST_MESSAGE(BlOtherDeviceInfoMessage);
    return [NSString stringWithUTF8String:message->m_info];
}

@end
