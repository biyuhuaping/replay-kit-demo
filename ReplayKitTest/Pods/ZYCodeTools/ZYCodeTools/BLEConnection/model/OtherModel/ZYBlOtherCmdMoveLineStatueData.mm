//
//  ZYBIOtherCmdMoveLineStatueData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherCmdMoveLineStatueData.h"
#import "BlOtherMoveLineStatusMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherMoveLineStatusMessage);

@interface ZYBlOtherCmdMoveLineStatueData()
{
    BlOtherMoveLineStatusMessage* _message;
}
@end

@implementation ZYBlOtherCmdMoveLineStatueData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherMoveLineStatusMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherMoveLineStatusMessage);
    if (self.dataType == 0) {
        message->buildRequest(_moveLineStatus);
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
    CAST_MESSAGE(BlOtherMoveLineStatusMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherMoveLineStatusMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlOtherMoveLineStatusMessage);
    return message->m_data.body.status;
}

-(NSUInteger)moveLineStatus{
    CAST_MESSAGE(BlOtherMoveLineStatusMessage);
    return message->m_data.body.status;
}

-(BOOL)isoffLineMoving{
    if (self.moveLineStatus >= ZYBlOtherCmdMoveLineStatueTypeBegain) {
        return YES;
    }
    else{
        return NO;
    }
}
@end
