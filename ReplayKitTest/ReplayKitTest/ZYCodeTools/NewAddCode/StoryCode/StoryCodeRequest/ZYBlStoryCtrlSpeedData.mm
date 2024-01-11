

//
//  ZYBlStoryCtrlSpeedData.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlStoryCtrlSpeedData.h"
#import "BlStoryCtrlSpeedMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;

SAFE_CAST(BlStoryCtrlSpeedMessage);



@interface ZYBlStoryCtrlSpeedData()
{
    BlStoryCtrlSpeedMessage* _message;
}
@end

@implementation ZYBlStoryCtrlSpeedData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlStoryCtrlSpeedMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlStoryCtrlSpeedMessage);
    if (self.dataType == 0) {
        message->buildRequest(_pitchSpeed, _rollSpeed,_yawSpeed,_duration);
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
    CAST_MESSAGE(BlStoryCtrlSpeedMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlStoryCtrlSpeedMessage*)data;
}

-(int)pitchSpeed{
    CAST_MESSAGE(BlStoryCtrlSpeedMessage);
    return message->m_data.body.pitchSpeed;
}

-(int)rollSpeed{
    CAST_MESSAGE(BlStoryCtrlSpeedMessage);
    return message->m_data.body.rollSpeed;
}

-(int)yawSpeed{
    CAST_MESSAGE(BlStoryCtrlSpeedMessage);
    return message->m_data.body.yawSpeed;
}

-(int)duration{
    CAST_MESSAGE(BlStoryCtrlSpeedMessage);
    return message->m_data.body.duration;
}
@end
