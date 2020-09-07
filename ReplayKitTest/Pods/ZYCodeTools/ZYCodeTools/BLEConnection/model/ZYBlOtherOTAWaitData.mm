//
//  ZYBlOtherOTAWaitData.m
//  ZYCamera
//
//  Created by wu on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherOTAWaitData.h"
#include "BlOtherOTAWaitMessage.h"
#import "ZYBlData_internal.h"

using namespace zy;
SAFE_CAST(BlOtherOTAWaitMessage);

@interface ZYBlOtherOTAWaitData ()
{
    BlOtherOTAWaitMessage *_message;
}
@end

@implementation ZYBlOtherOTAWaitData

@synthesize message = _message;

+ (instancetype)bleOtherOTAWaitData{
    ZYBlOtherOTAWaitData *retData = [[ZYBlOtherOTAWaitData alloc] init];
    [retData createRawData];
    return retData;
}

- (instancetype)init{
    self = [super init];
    if (self){
        _message = new BlOtherOTAWaitMessage();
    }
    return self;
}

- (void *)createRawData{
    CAST_MESSAGE(BlOtherOTAWaitMessage);
    if (self.dataType == 0){
        message -> buildRequest();
    }
    return self.message;
}

- (NSUInteger)needWait{
    CAST_MESSAGE(BlOtherOTAWaitMessage);
    return message -> m_data.body.status;
}

-(void) setRawData:(void*)data
{
    [self setRawData:data freeWhenDone:YES];
}

-(void) setRawData:(void*)data freeWhenDone:(BOOL)free
{
    self.free = free;
    CAST_MESSAGE(BlOtherOTAWaitMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherOTAWaitMessage*)data;
}

@end
