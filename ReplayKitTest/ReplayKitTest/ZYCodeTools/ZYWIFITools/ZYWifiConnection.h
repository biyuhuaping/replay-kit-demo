//
//  ZYWifiConnection.h
//  ZYCamera
//
//  Created by lgj on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleDeviceRequest.h"
#import "ZYConnection.h"
@interface ZYWifiConnection : NSObject<ZYConnection>
/**
 记录最后一次与设备进行同步的值
 */
@property (nonatomic, weak) ZYBleDeviceDataModel* dataCache;

@property (nonatomic, readwrite, strong) ZYControlCoder* sendCoder;
/*!
 最大的异步指令的个数，默认为20；
 
 */
@property (nonatomic, readwrite) NSInteger maxAsynRequestCount;

///**
// 发送请求
// 
// @param request 请求
// */
//-(void)sendRequest:(ZYBleDeviceRequest*)request;


/**
 清理数据
 */
-(void)clearData;


/**
 暂停接受数据
 */
-(void)pauseReceiving;

/**
 开始接受数据
 */
-(void)begainReceiving;

@end
