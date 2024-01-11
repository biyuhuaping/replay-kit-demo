//
//  ZYBlOtherCheckMD5Data.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/7/13.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherCheckMD5Data.h"
#import "BlOtherCheckMD5Message.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCheckMD5Message);

@interface ZYBlOtherCheckMD5Data()
{
    BlOtherCheckMD5Message* _message;
}
@end

@implementation ZYBlOtherCheckMD5Data

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCheckMD5Message();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCheckMD5Message);
    if (self.dataType == 0) {
        message->buildRequest([_md5 UTF8String]);
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
    CAST_MESSAGE(BlOtherCheckMD5Message);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherCheckMD5Message*)data;
}

-(NSUInteger) flag
{
    CAST_MESSAGE(BlOtherCheckMD5Message);
    return message->m_status;
}


@end
