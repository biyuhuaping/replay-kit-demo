//
//  ZYSendRequest.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/9/5.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#import "ZYStablizerDefineENUM.h"
@class ZYProductSupportFunctionModel;
@class ZYBleDeviceRequest;
@protocol ZYSendRequest<NSObject>

/**
 配置request的

 @param request 配置发送时候的编码方式和传输方式
 */
-(void)configEncodeAndTransmissionForRequest:(ZYBleDeviceRequest *)request;

@optional

/**
 设备的型号

 @return 设备的型号
 */
-(NSString *)modelStr;

/**
 设备的配置表

 @return 设备的配置表
 */
-(ZYProductSupportFunctionModel *)delegatefunctionModel;

@end
