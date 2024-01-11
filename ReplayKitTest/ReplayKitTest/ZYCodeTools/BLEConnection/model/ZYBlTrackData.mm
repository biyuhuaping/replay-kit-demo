//
//  ZYBlTrackData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlTrackData.h"
#import "BlTrackMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlTrackMessage);

@interface ZYBlTrackData()
{
    BlTrackMessage* _message;
}
@end

@implementation ZYBlTrackData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlTrackMessage();
    }
    return self;
}

-(void*) createRawData
{
    zy::BlTrackMessage* message = castToBlTrackMessage(self.message);
    if (self.dataType == 0) {
        message->buildRequest(_xOffset, _yOffset);
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
    zy::BlTrackMessage* message = castToBlTrackMessage(self.message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlTrackMessage*)data;
}

-(NSInteger) xOffset
{
    zy::BlTrackMessage* message = castToBlTrackMessage(self.message);
    return message->m_data.body.xOffset;
}

-(NSInteger) yOffset
{
    zy::BlTrackMessage* message = castToBlTrackMessage(self.message);
    return message->m_data.body.yOffset;
}

@end
