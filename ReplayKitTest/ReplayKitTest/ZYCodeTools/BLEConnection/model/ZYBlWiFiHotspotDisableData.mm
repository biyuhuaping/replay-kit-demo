//
//  ZYBlWiFiHotspotDisableData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotDisableData.h"
#import "BlWiFiHotspotDisableMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotDisableMessage);

@interface ZYBlWiFiHotspotDisableData()
{
    BlWiFiHotspotDisableMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotDisableData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotDisableMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotDisableMessage);
    if (self.dataType == 0) {
        message->buildRequest();
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
    CAST_MESSAGE(BlWiFiHotspotDisableMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotDisableMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiHotspotDisableMessage);
    return message->m_wifiStatus;
}

@end
