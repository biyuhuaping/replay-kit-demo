//
//  ZYBlHandleData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlHandleData.h"
#import "BlHandleMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlHandleMessage);

@interface ZYBlHandleData()
{
    BlHandleMessage* _message;
}
@end

@implementation ZYBlHandleData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlHandleMessage();
    }
    return self;
}

-(void*) createRawData
{
    zy::BlHandleMessage* message = castToBlHandleMessage(self.message);
    if (self.dataType == 0) {
        message->buildRequest(_cmdCode, _cmdArg);
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
    zy::BlHandleMessage* message = castToBlHandleMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlHandleMessage*)data;
}

-(NSUInteger) cmdId
{
    zy::BlHandleMessage* message = castToBlHandleMessage(self.message);
    return message->m_data.body.cmdId;
}

-(NSUInteger) cmdCode
{
    zy::BlHandleMessage* message = castToBlHandleMessage(self.message);
    return message->m_data.body.cmd;
}

-(NSUInteger) cmdArg
{
    zy::BlHandleMessage* message = castToBlHandleMessage(self.message);
    return message->m_data.body.arg;
}

@end
