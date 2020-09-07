//
//  ZYBleDeviceClient.h
//  ZYCamera
//
//  Created by Frost Zhang on 2017/1/6.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBleProtocol.h"
#import "ZYBleDeviceDataModel.h"
#import "ZYBleDeviceInfo.h"
#import "ZYBleConnection.h"
#import "ZYBleMutableRequest.h"


@interface ZYBleDeviceClient : NSObject
/**
 记录最后一次与设备进行同步的值
 */
@property (nonatomic, weak) ZYBleDeviceDataModel* dataCache;

/**
  通过蓝牙控制云台进行指令交互的对象
 
 @return 单例
 */
+(instancetype) defaultClient;

@property (nonatomic, strong,readonly) ZYBleConnection* stablizerConnection;



/**
 开启蓝牙通知
 */
-(void)mindBluetoothNotify;

/**
 发送请求
 
 @param request 请求列表
 */
-(void) sendDeviceRequest:(ZYBleDeviceRequest*)request;

/**
 发送请求
 
 @param requests 请求列表
 */
-(void) sendRequests:(NSArray<ZYBleDeviceRequest*>*)requests completionHandler:(void(^)(BOOL success))completionHandler;
/**
 发送请求
 
 @param request 请求对象
 */
-(void) sendBLERequest:(ZYBleDeviceRequest*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, NSUInteger param))handler;

/**
 发送请求

 @param request 请求对象
 */
-(void) sendMutableRequest:(ZYBleMutableRequest*)request completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;

/**
 是否有等待的指令

 @return YES:空闲状态，无指令等待
 */
-(BOOL) isIdle;

/**
 空闲时间

 @return 秒
 */
-(NSTimeInterval) idleTime;


/**
 暂停接受数据
 */
-(void)pauseReceiving;

/**
 开始接受数据
 */
-(void)begainReceiving;
@end
