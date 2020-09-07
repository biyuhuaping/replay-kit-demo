//
//  ZYBlWiFiConnectionData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiConnectionData.h"
#import "BlWiFiConnectionMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiConnectionMessage);

@interface ZYBlWiFiConnectionData()
{
    BlWiFiConnectionMessage* _message;
}
@end

@implementation ZYBlWiFiConnectionData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiConnectionMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiConnectionMessage);
    if (self.dataType == 0) {
        message->buildRequest([_ssid UTF8String], [_pwd UTF8String]);
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
    CAST_MESSAGE(BlWiFiConnectionMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiConnectionMessage*)data;
}

-(NSString*) ssid
{
    CAST_MESSAGE(BlWiFiConnectionMessage);
    return [NSString stringWithUTF8String:message->m_ssid];
}

-(NSString*) pwd
{
    CAST_MESSAGE(BlWiFiConnectionMessage);
    return [NSString stringWithUTF8String:message->m_pwd];
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlWiFiConnectionMessage);
    return message->m_flag;
}

@end
