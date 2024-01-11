//
//  ZYBlHandleData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiDevCleanData.h"
#import "BlWiFiDevCleanMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiDevCleanMessage);

@interface ZYBlWiFiDevCleanData()
{
    BlWiFiDevCleanMessage* _message;
}
@end

@implementation ZYBlWiFiDevCleanData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiDevCleanMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiDevCleanMessage);
    if (self.dataType == 0) {
        message->buildRequest([_ssid UTF8String]);
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
    CAST_MESSAGE(BlWiFiDevCleanMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiDevCleanMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlWiFiDevCleanMessage);
    return message->m_flag;
}

@end
