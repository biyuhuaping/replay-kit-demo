//
//  ZYBlOtherHeart.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/6.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherHeart.h"
#include "BlOtherHeartMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherHeartMessage);

@interface ZYBlOtherHeart()
{
    BlOtherHeartMessage* _message;
}
@end

@implementation ZYBlOtherHeart

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherHeartMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherHeartMessage);
    if (self.dataType == 0) {
        message->buildRequest(_heartType);
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
    CAST_MESSAGE(BlOtherHeartMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherHeartMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlOtherHeartMessage);
    return message->m_data.body.status;
}

-(int)battery{
    CAST_MESSAGE(BlOtherHeartMessage);
    return message->battery;
}

-(int)errorType{
    CAST_MESSAGE(BlOtherHeartMessage);
    return message->errorType;
}
@end
