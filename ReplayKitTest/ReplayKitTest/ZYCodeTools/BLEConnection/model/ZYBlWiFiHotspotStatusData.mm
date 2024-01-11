//
//  ZYBlWiFiHotspotStatusData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotStatusData.h"
#import "BlWiFiHotspotStatusMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotStatusMessage);

@interface ZYBlWiFiHotspotStatusData()
{
    BlWiFiHotspotStatusMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotStatusData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotStatusMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotStatusMessage);
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
    CAST_MESSAGE(BlWiFiHotspotStatusMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotStatusMessage*)data;
}

-(NSUInteger) wifiStatus
{
    
    CAST_MESSAGE(BlWiFiHotspotStatusMessage);
    return message->m_wifiStatus;
}

@end
