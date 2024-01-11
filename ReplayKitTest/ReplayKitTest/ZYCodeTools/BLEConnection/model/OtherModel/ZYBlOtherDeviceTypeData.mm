//
//  ZYBlOtherDeviceTypeData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/21.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlOtherDeviceTypeData.h"
#import "BlOtherCMDDeviceTypeMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlOtherCMDDeviceTypeMessage);

@interface ZYBlOtherDeviceTypeData()
{
    BlOtherCMDDeviceTypeMessage* _message;
}
@end

@implementation ZYBlOtherDeviceTypeData
@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMDDeviceTypeMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMDDeviceTypeMessage);
    if (self.dataType == 0) {
        message->buildRequest(_direct, _type);
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
    CAST_MESSAGE(BlOtherCMDDeviceTypeMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherCMDDeviceTypeMessage*)data;
}

- (NSUInteger)direct{
    CAST_MESSAGE(BlOtherCMDDeviceTypeMessage);
    return message->m_data.body.direct;
}

-(NSUInteger)type{
    CAST_MESSAGE(BlOtherCMDDeviceTypeMessage);
    return message->m_data.body.type;

}

@end
