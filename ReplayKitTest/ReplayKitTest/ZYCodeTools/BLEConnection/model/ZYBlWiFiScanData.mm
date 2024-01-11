//
//  ZYBlWiFiScanData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiScanData.h"
#import "BlWiFiScanMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiScanMessage);

@interface ZYBlWiFiScanData()
{
    BlWiFiScanMessage* _message;
}
@end

@implementation ZYBlWiFiScanData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiScanMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiScanMessage);
    if (self.dataType == 0) {
        message->buildRequest((int)_scanState);
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
    CAST_MESSAGE(BlWiFiScanMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiScanMessage*)data;
}

-(NSUInteger) scanState
{
    CAST_MESSAGE(BlWiFiScanMessage);
    return message->m_data.body.status;
}

@end
