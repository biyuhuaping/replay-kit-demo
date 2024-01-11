//
//  ZYBlOtherPathData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherPathData.h"
#import "BlOtherCMDPathDataMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMDPathDataMessage);

@interface ZYBlOtherPathData()
{
    BlOtherCMDPathDataMessage* _message;
}
@end

@implementation ZYBlOtherPathData
@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMDPathDataMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMDPathDataMessage);
    if (self.dataType == 0) {
        message->buildRequest(_flag, _state);
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
    CAST_MESSAGE(BlOtherCMDPathDataMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherCMDPathDataMessage*)data;
}

- (uint8)flag{
    CAST_MESSAGE(BlOtherCMDPathDataMessage);
    return message->m_data.body.flag;
}

- (uint8)state{
    CAST_MESSAGE(BlOtherCMDPathDataMessage);
    return message->m_data.body.state;
}
@end
