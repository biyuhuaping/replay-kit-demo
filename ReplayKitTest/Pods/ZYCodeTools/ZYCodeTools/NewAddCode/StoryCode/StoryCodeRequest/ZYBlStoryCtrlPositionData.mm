//
//  ZYBlStoryCtrlPositionData.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlStoryCtrlPositionData.h"
#import "BlStoryCtrlPositionMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;

SAFE_CAST(BlStoryCtrlPositionMessage);



@interface ZYBlStoryCtrlPositionData()
{
    BlStoryCtrlPositionMessage* _message;
}
@end

@implementation ZYBlStoryCtrlPositionData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlStoryCtrlPositionMessage();
        _precisionPitch = 100.0;
        _precisionRoll = 100.0;
        _precisionYaw = 100.0;
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlStoryCtrlPositionMessage);
    if (self.dataType == 0) {
        
        message->buildRequest(int(_pitchDegree * _precisionPitch), int(_rollDegree * _precisionRoll),int(_yawDegree * _precisionYaw),_duration);
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
    CAST_MESSAGE(BlStoryCtrlPositionMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlStoryCtrlPositionMessage*)data;
}

-(float)pitchDegree{
    CAST_MESSAGE(BlStoryCtrlPositionMessage);
    int degree = message->m_data.body.pitchDegree;
    return degree / _precisionPitch;
}

-(float)rollDegree{
    CAST_MESSAGE(BlStoryCtrlPositionMessage);
    int degree = message->m_data.body.rollDegree;
    return degree / _precisionRoll;
}

-(float)yawDegree{
    CAST_MESSAGE(BlStoryCtrlPositionMessage);
    int degree = message->m_data.body.yawDegree;
    return degree / _precisionYaw;
}

-(int)duration{
    CAST_MESSAGE(BlStoryCtrlPositionMessage);
    return message->m_data.body.duration;
}
@end
