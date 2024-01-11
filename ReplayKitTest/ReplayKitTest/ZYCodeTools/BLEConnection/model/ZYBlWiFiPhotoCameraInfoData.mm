//
//  ZYBlWiFiPhotoCameraInfoData.m
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiPhotoCameraInfoData.h"
#import "BlWiFiPhotoCameraInfoMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiPhotoCameraInfoMessage);

@interface ZYBlWiFiPhotoCameraInfoData()
{
    BlWiFiPhotoCameraInfoMessage* _message;
}
@end

@implementation ZYBlWiFiPhotoCameraInfoData

@synthesize message = _message;



// 用于设置相机厂商
+ (instancetype)dataForSetManufacturer:(ZYBl_CameraManufactureType)type{
    ZYBlWiFiPhotoCameraInfoData *retData = [[ZYBlWiFiPhotoCameraInfoData alloc] init];
    retData.flag = 0x80;
    retData.value = type;
    [retData createRawData];
    return retData;
}

// 用于获取相机厂商
+ (instancetype)dataForGetManufacturer{
    ZYBlWiFiPhotoCameraInfoData *retData = [[ZYBlWiFiPhotoCameraInfoData alloc] init];
    retData.flag = 0x0;
    retData.value = 0x00;
    [retData createRawData];
    return retData;
}


-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiPhotoCameraInfoMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiPhotoCameraInfoMessage);
    if (self.dataType == 0) {
        message->buildRequest(self.flag,self.value);
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
    CAST_MESSAGE(BlWiFiPhotoCameraInfoMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiPhotoCameraInfoMessage*)data;
}

- (uint8)flag
{
    CAST_MESSAGE(BlWiFiPhotoCameraInfoMessage);
    return (message->m_data.body.value) & 0xF0;
}

- (uint8)value
{
    CAST_MESSAGE(BlWiFiPhotoCameraInfoMessage);
    return (message->m_data.body.value) & 0x0F;
}

@end
