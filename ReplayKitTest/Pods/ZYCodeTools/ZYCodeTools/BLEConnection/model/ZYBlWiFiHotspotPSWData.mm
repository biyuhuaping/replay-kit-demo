//
//  ZYBlWiFiHotspotPSWData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotPSWData.h"
#import "BlWiFiHotspotPSWMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotPSWMessage);

@interface ZYBlWiFiHotspotPSWData()
{
    BlWiFiHotspotPSWMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotPSWData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotPSWMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotPSWMessage);
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
    CAST_MESSAGE(BlWiFiHotspotPSWMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotPSWMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiHotspotPSWMessage);
    return message->m_wifiStatus;
}

-(NSString*) PSW
{
    CAST_MESSAGE(BlWiFiHotspotPSWMessage);
    return [NSString stringWithUTF8String:message->m_pwd];
}

@end
