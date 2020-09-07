//
//  ZYBlWiFiErrorData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiErrorData.h"
#import "BlWiFiErrorMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiErrorMessage);

@interface ZYBlWiFiErrorData()
{
    BlWiFiErrorMessage* _message;
}
@end

@implementation ZYBlWiFiErrorData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiErrorMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiErrorMessage);
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
    CAST_MESSAGE(BlWiFiErrorMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiErrorMessage*)data;
}

-(NSUInteger) cmdId
{
    CAST_MESSAGE(BlWiFiErrorMessage);
    return message->m_data.body.errCode;
}


@end
