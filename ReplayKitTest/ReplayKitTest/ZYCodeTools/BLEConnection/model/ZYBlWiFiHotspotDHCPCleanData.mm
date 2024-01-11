//
//  ZYBlWiFiHotspotDHCPCleanData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotDHCPCleanData.h"
#import "BlWiFiHotspotDHCPCleanMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotDHCPCleanMessage);

@interface ZYBlWiFiHotspotDHCPCleanData()
{
    BlWiFiHotspotDHCPCleanMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotDHCPCleanData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotDHCPCleanMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotDHCPCleanMessage);
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
    CAST_MESSAGE(BlWiFiHotspotDHCPCleanMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotDHCPCleanMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiHotspotDHCPCleanMessage);
    return message->m_wifiStatus;
}

@end
