//
//  ZYBlCCSSetConfigData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlCCSSetConfigData.h"
#import "BlCCSSetConfigMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlCCSSetConfigMessage);

@interface ZYBlCCSSetConfigData()
{
    BlCCSSetConfigMessage* _message;
}
@end

@implementation ZYBlCCSSetConfigData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlCCSSetConfigMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlCCSSetConfigMessage);
    if (self.dataType == 0) {
        message->buildRequest(_idx, [_value UTF8String]);
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
    CAST_MESSAGE(BlCCSSetConfigMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlCCSSetConfigMessage*)data;
}

-(NSUInteger) idx
{
    CAST_MESSAGE(BlCCSSetConfigMessage);
    return message->m_data.body.status;
}

-(NSUInteger) cmdStatus
{
    CAST_MESSAGE(BlCCSSetConfigMessage);
    return message->m_data.body.status;
}

-(NSString*) value
{
    CAST_MESSAGE(BlCCSSetConfigMessage);
    return [NSString stringWithUTF8String:message->m_configValue];
}

@end
