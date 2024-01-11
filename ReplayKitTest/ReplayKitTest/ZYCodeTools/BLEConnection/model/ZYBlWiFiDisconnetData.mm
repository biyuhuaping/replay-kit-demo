//
//  ZYBlWiFiDisconnetData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiDisconnetData.h"
#import "BlWiFiDisconnectMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiDisconnectMessage);

@interface ZYBlWiFiDisconnetData()
{
    BlWiFiDisconnectMessage* _message;
}
@end

@implementation ZYBlWiFiDisconnetData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiDisconnectMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiDisconnectMessage);
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
    CAST_MESSAGE(BlWiFiDisconnectMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiDisconnectMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlWiFiDisconnectMessage);
    return message->m_data.body.flag;
}

@end
