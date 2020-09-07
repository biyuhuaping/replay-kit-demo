//
//  ZYBlWiFiPhotoNoticeData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiPhotoNoticeData.h"
#import "BlWiFiPhotoNoticeMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiPhotoNoticeMessage);

@interface ZYBlWiFiPhotoNoticeData()
{
    BlWiFiPhotoNoticeMessage* _message;
}
@end

@implementation ZYBlWiFiPhotoNoticeData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiPhotoNoticeMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiPhotoNoticeMessage);
    if (self.dataType == 0) {
        message->buildRequest(0);
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
    CAST_MESSAGE(BlWiFiPhotoNoticeMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiPhotoNoticeMessage*)data;
}

-(NSUInteger) paramId
{
    CAST_MESSAGE(BlWiFiPhotoNoticeMessage);
    return message->m_data.body.photoParamId;
}

-(NSUInteger) paramValue
{
    CAST_MESSAGE(BlWiFiPhotoNoticeMessage);
    return message->m_data.body.photoCrtlValue;
}

-(NSDictionary*) toDictionary
{
    return @{
             @"paramId":@(self.paramId),
             @"paramValue":@(self.paramValue),
             };
}

@end
