//
//  ZYConnection.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/6/1.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBleDeviceDataModel.h"
#import "ZYBleDeviceRequest.h"
#define kbeforeReciveNotiDateInterVale  10//上次发送数据的时间间隔
#define kReciveDataNotiName  @"kReciveDataNotiName"//用于接收到数据通知
@protocol ZYConnection <NSObject>

@optional

/// 接收到数据的通知
-(void)postReciveDataNotiName;

-(void)changeCoderIfNeed:(NSString*)coderName clsType:(Class) cls;


/**
 发送请求
 
 @param request 请求
 */
-(void)sendRequest:(ZYBleDeviceRequest*)request;

/**
 发送请求
 
 @param requests 请求列表
 */
-(void)sendRequests:(NSArray<ZYBleDeviceRequest*>*)requests;
@end

