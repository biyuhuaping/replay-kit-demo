//
//  ZYBlWiFiHotspotResetData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotResetData.h"
#import "BlWiFiHotspotResetMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotResetMessage);

@interface ZYBlWiFiHotspotResetData()
{
    BlWiFiHotspotResetMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotResetData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotResetMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotResetMessage);
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
    CAST_MESSAGE(BlWiFiHotspotResetMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotResetMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiHotspotResetMessage);
    return message->m_wifiStatus;
}

@end
