//
//  ZYBlWiFiPhotoAllParamData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiPhotoInfoData.h"
#import "BlWiFiPhotoInfoMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiPhotoInfoMessage);

@interface ZYBlWiFiPhotoInfoData()
{
    BlWiFiPhotoInfoMessage* _message;
}
@end

@implementation ZYBlWiFiPhotoInfoData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiPhotoInfoMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiPhotoInfoMessage);
    if (self.dataType == 0) {
        message->buildRequest(_infoId);
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
    CAST_MESSAGE(BlWiFiPhotoInfoMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiPhotoInfoMessage*)data;
}

-(NSUInteger) infoId
{
    CAST_MESSAGE(BlWiFiPhotoInfoMessage);
    return message->m_data.body.photoParaId;
}

-(NSString*) infoString
{
    CAST_MESSAGE(BlWiFiPhotoInfoMessage);
    return [NSString stringWithUTF8String:message->m_info];
}

@end
