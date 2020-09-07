//
//  ZYBlHandleData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiEnableData.h"
#import "BlWiFiEnableMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiEnableMessage);

@interface ZYBlWiFiEnableData()
{
    BlWiFiEnableMessage* _message;
}
@end

@implementation ZYBlWiFiEnableData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiEnableMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiEnableMessage);
    if (self.dataType == 0) {
        message->buildRequest((int)_wifiState);
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
    CAST_MESSAGE(BlWiFiEnableMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiEnableMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiEnableMessage);
    return message->m_data.body.status;
}


@end
