//
//  ZYBlOtherFileAsynData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherFileAsynData.h"
#import "BlOtherFileAsynMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherFileAsynMessage);

@interface ZYBlOtherFileAsynData()
{
    BlOtherFileAsynMessage* _message;
}
@end

@implementation ZYBlOtherFileAsynData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherFileAsynMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherFileAsynMessage);
    if (self.dataType == 0) {
        message->buildRequest();
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
    CAST_MESSAGE(BlOtherFileAsynMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherFileAsynMessage*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlOtherFileAsynMessage);
    return message->m_data.body.status;
}

@end
