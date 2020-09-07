//
//  ZYBlWiFiHotspotGetSSIDData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotGetSSIDData.h"
#import "BlWiFiHotspotGetSSIDMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotGetSSIDMessage);

@interface ZYBlWiFiHotspotGetSSIDData()
{
    BlWiFiHotspotGetSSIDMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotGetSSIDData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotGetSSIDMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotGetSSIDMessage);
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
    CAST_MESSAGE(BlWiFiHotspotGetSSIDMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotGetSSIDMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiHotspotGetSSIDMessage);
    return message->m_wifiStatus;
}

-(NSString*) SSID
{
    CAST_MESSAGE(BlWiFiHotspotGetSSIDMessage);
    return [NSString stringWithUTF8String:message->m_ssid];
}


@end
