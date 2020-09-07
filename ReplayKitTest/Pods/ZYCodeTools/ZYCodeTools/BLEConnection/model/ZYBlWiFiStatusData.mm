//
//  ZYBlHandleData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiStatusData.h"
#import "BlWifiStatusMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiStatusMessage);

@interface ZYBlWiFiStatusData()
{
    BlWiFiStatusMessage* _message;
}
@end

@implementation ZYBlWiFiStatusData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiStatusMessage();;
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiStatusMessage);
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
    CAST_MESSAGE(BlWiFiStatusMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiStatusMessage*)data;
}

-(NSUInteger) wifiStatus
{
    CAST_MESSAGE(BlWiFiStatusMessage);
    return message->m_data.body.status;
}


@end
