//
//  ZYBlAsynStarData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlAsynStarData.h"
#import "BlAsynStarMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlAsynStarMessage);

@interface ZYBlAsynStarData()
{
    BlAsynStarMessage* _message;
}

@end

@implementation ZYBlAsynStarData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlAsynStarMessage();
    }
    return self;
}

-(void*) createRawData
{
    zy::BlAsynStarMessage* message = castToBlAsynStarMessage(self.message);
    if (self.dataType == 0) {
        message->buildRequest(_code, _param);
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
    zy::BlAsynStarMessage* message = castToBlAsynStarMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlAsynStarMessage*)data;
}

-(NSUInteger) cmdId
{
    zy::BlAsynStarMessage* message = castToBlAsynStarMessage(self.message);
    return message->m_data.body.cmdId;
}

-(NSUInteger) code
{
    zy::BlAsynStarMessage* message = castToBlAsynStarMessage(self.message);
    return message->m_data.body.starData.data.code;
}

-(NSUInteger) param
{
    zy::BlAsynStarMessage* message = castToBlAsynStarMessage(self.message);
    return message->m_data.body.starData.data.param;
}
@end
