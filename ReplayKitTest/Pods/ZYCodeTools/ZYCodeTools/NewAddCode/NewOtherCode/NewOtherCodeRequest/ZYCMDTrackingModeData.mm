//
//  ZYCMDTrackingModeData.m
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ZYCMDTrackingModeData.h"

#import "BlOtherCMD_TRACKING_MODEMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;

SAFE_CAST(BlOtherCMD_TRACKING_MODEMessage);



@interface ZYCMDTrackingModeData()
{
    BlOtherCMD_TRACKING_MODEMessage* _message;
}
@end

@implementation ZYCMDTrackingModeData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMD_TRACKING_MODEMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMD_TRACKING_MODEMessage);
    if (self.dataType == 0) {
        
        message->buildRequest(_direct,_mode);
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
    CAST_MESSAGE(BlOtherCMD_TRACKING_MODEMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherCMD_TRACKING_MODEMessage*)data;
}

-(uint8)direct{
    CAST_MESSAGE(BlOtherCMD_TRACKING_MODEMessage);
    return message->m_data.body.op;
}

-(uint8)mode{
    CAST_MESSAGE(BlOtherCMD_TRACKING_MODEMessage);
    return message->m_data.body.value;
}


@end

