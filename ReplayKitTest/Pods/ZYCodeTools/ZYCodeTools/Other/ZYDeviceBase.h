//
//  ZYDeviceBase.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/21.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 云台开机状态,需要检查设备是否需要激活检查activeStateS
 */
extern NSString* const Device_PTZReadyToUse;

/**
 云台待机状态  0 未开机 1 reboot模式
 */
extern NSString* const Device_PTZOffLine;

/**
 云台断开连接
 */
extern NSString* const Deivce_Disconnected;
/**
 workingState状态改变
 */
extern NSString* const kWorkingStateChange;



#import "ZYBleDeviceInfo.h"
#import "ZYBleDeviceClient.h"
#import "ZYProductConfigTools.h"
#import "ZYSendRequest.h"
#import "ZYConnectedDeviceInfoDataBase.h"

@interface ZYDeviceBase : NSObject<ZYSendRequest>
/// 已经连接上的设备信息
@property (nonatomic, strong) ZYConnectedDeviceInfo *connectedDeviceInfo;
//开始连接的时间
@property(nonatomic, copy)NSDate *dateConnect;
//断开连接的时间
@property(nonatomic, copy)NSDate *dateDisconnect;


@property(nonatomic, strong)ZYBleDeviceInfo *deviceInfo;

/**
 云台开机状态
 */
@property (nonatomic, assign) NSInteger workingState;

-(void)connectSetup;

-(void)clearDataSource;

-(NSString *)deviceName;


+(instancetype)deviceBaseWithdDeviceInfo:(ZYBleDeviceInfo *)info;
@end
