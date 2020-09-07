//
//  ZYBlWiFiHotspotSetPSWData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/17.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiHotspotSetPSWData.h"

#import "BlWiFiHotspotSETPSWMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiHotspotSETPSWMessage);

@interface ZYBlWiFiHotspotSetPSWData()
{
    BlWiFiHotspotSETPSWMessage* _message;
}
@end

@implementation ZYBlWiFiHotspotSetPSWData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiHotspotSETPSWMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiHotspotSETPSWMessage);
    if (self.dataType == 0) {
        message->buildRequest([_password UTF8String]);
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
    CAST_MESSAGE(BlWiFiHotspotSETPSWMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiHotspotSETPSWMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiHotspotSETPSWMessage);
    return message->m_wifiStatus;
}



@end

