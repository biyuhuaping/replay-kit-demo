//
//  ZYBlCheckActiveInfoData.m
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlCheckActiveInfoData.h"
#import "BlOtherCMD_CHECK_ACTIVEINFOMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMD_CHECK_ACTIVEINFOMessage);

@interface ZYBlCheckActiveInfoData()
{
    BlOtherCMD_CHECK_ACTIVEINFOMessage* _message;
}
@end

@implementation ZYBlCheckActiveInfoData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMD_CHECK_ACTIVEINFOMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMD_CHECK_ACTIVEINFOMessage);
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
    CAST_MESSAGE(BlOtherCMD_CHECK_ACTIVEINFOMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlOtherCMD_CHECK_ACTIVEINFOMessage*)data;
}

//-(NSUInteger) activeStatue
//{
//    CAST_MESSAGE(BlOtherCMD_CHECK_ACTIVEINFOMessage);
//    return message->active_status;
//}
-(NSData *)activedata{
    CAST_MESSAGE(BlOtherCMD_CHECK_ACTIVEINFOMessage);
    return [[NSData dataWithBytes:message->buffData length:16] copy];
}

-(NSUInteger)activeStatue{
    if (self.activedataDecode.length >= 16) {
        char *active = (char *)[self.activedataDecode bytes];
        return active[0];
    }
    return 0;
    
}
@end
