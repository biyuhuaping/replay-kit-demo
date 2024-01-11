//
//  ZYBlCCSAnsData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlCCSAnsData.h"
#import "BlCCSAnsMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlCCSAnsMessage);

@interface ZYBlCCSAnsData()
{
    BlCCSAnsMessage* _message;
}
@end

@implementation ZYBlCCSAnsData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlCCSAnsMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlCCSAnsMessage);
    if (self.dataType == 0) {
        //message->buildRequest(_infoId);
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
    CAST_MESSAGE(BlCCSAnsMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlCCSAnsMessage*)data;
}

@end
