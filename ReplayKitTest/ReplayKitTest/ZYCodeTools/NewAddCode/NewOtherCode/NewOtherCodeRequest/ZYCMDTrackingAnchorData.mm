//
//  ZYCMDTrackingAnchorData.m
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ZYCMDTrackingAnchorData.h"

#import "BlOtherCMD_TRACKING_ANCHORMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;

SAFE_CAST(BlOtherCMD_TRACKING_ANCHORMessage);



@interface ZYCMDTrackingAnchorData()
{
    BlOtherCMD_TRACKING_ANCHORMessage* _message;
}
@end

@implementation ZYCMDTrackingAnchorData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlOtherCMD_TRACKING_ANCHORMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlOtherCMD_TRACKING_ANCHORMessage);
    if (self.dataType == 0) {
        
        message->buildRequest(_direct,_x,_y);
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
    CAST_MESSAGE(BlOtherCMD_TRACKING_ANCHORMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (BlOtherCMD_TRACKING_ANCHORMessage*)data;
}

-(uint8)direct{
    CAST_MESSAGE(BlOtherCMD_TRACKING_ANCHORMessage);
    return message->m_data.body.op;
}
-(uint16)x{
    CAST_MESSAGE(BlOtherCMD_TRACKING_ANCHORMessage);
    return message->m_data.body.x;
}

-(uint16)y{
    CAST_MESSAGE(BlOtherCMD_TRACKING_ANCHORMessage);
    return message->m_data.body.y;
}
@end

