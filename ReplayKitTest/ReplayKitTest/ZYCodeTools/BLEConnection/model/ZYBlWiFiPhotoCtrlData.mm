//
//  ZYBlWiFiPhotoInfoData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiPhotoCtrlData.h"
#import "BlWiFiPhotoCtrlMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiPhotoCtrlMessage);

@interface ZYBlWiFiPhotoCtrlData()
{
    BlWiFiPhotoCtrlMessage* _message;
}
@end

@implementation ZYBlWiFiPhotoCtrlData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiPhotoCtrlMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiPhotoCtrlMessage);
    if (self.dataType == 0) {
        message->buildRequest((int)_num, (int)_value);
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
    CAST_MESSAGE(BlWiFiPhotoCtrlMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiPhotoCtrlMessage*)data;
}

-(NSUInteger) num
{
    CAST_MESSAGE(BlWiFiPhotoCtrlMessage);
    return message->m_data.body.photoParamId;
}

-(NSUInteger) value
{
    CAST_MESSAGE(BlWiFiPhotoCtrlMessage);
    return message->m_data.body.photoCrtlValue;
}

@end
