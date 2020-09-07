//
//  ZYBlWiFiPhotoParamData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiPhotoParamData.h"
#import "BlWiFiPhotoParamMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiPhotoParamMessage);

@interface ZYBlWiFiPhotoParamData()
{
    BlWiFiPhotoParamMessage* _message;
}
@end

@implementation ZYBlWiFiPhotoParamData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiPhotoParamMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiPhotoParamMessage);
    if (self.dataType == 0) {
        message->buildRequest((int)_paramId);
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
    CAST_MESSAGE(BlWiFiPhotoParamMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiPhotoParamMessage*)data;
}

-(NSUInteger) paramId
{
    CAST_MESSAGE(BlWiFiPhotoParamMessage);
    return message->m_data.body.photoParamId;
}

-(NSUInteger) paramValue
{
    CAST_MESSAGE(BlWiFiPhotoParamMessage);
    return message->m_photoParamValue;
}

@end
