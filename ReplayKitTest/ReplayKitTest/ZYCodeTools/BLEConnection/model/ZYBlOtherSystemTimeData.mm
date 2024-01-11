//
//  ZYBlOtherSystemTimeData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherSystemTimeData.h"
#import "BlOtherSystemTimeMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherSystemTimeMessage);

@interface ZYBlOtherSystemTimeData()
{
    BlOtherSystemTimeMessage* _message;
}
@end

@implementation ZYBlOtherSystemTimeData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherSystemTimeMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherSystemTimeMessage);
    if (self.dataType == 0) {
        message->buildRequest(_sec, _usec);
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
    CAST_MESSAGE(BlOtherSystemTimeMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherSystemTimeMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlOtherSystemTimeMessage);
    return message->m_data.body.status;
}

@end
