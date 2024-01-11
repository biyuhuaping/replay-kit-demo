//
//  ZYModuleUpgrade.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2018/9/20.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYSendRequest.h"

#import "ZYUpgradableInfoModel.h"

#define kAPPGOTimeOut 10001
#define kAPPGOAlreadySendCode 10002
#define kSendDataErrorCode 10003

#define kAPPGOUpgradeFinish 100
#define kAPPGOSkipSuccess 101
#define kAPPGOSkipFail 102
#define kAPPGOUpgradeFail 103


@interface ZYModuleUpgrade : NSObject
//app go的含义
@property (nonatomic)   BOOL appgoMeaning;

/**
 代理
 */
@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;

/**
 设备升级链路
 */
@property(nonatomic, readwrite) ZYUpgradableChannel channel;

/**
 通过二进制创建Firmware升级类

 @param data 升级Firmware二进制
 @return class
 */
+(instancetype)upgradeWithMod:(ZYUpgradableInfoModel *)mod;

/// 是否需要j检查waiting
@property(nonatomic, assign)BOOL isNeedCheckWaiting ;

/**
 开始升级

 @param successed 成功回调
 @param failure 失败回调
 */
-(void)beginUpgradeProgress:(void (^)(float progress))progress Successed:(void (^)(void))successed failure:(void (^)(NSError *error))failure waitingForUpgradeCompletd:(void(^)(float progress))waitingForUpgradeCompletd;

/**
 检查OTA是否需要等待
 */
- (void)checkIsOTANeedWait:(void (^)(BOOL success, BOOL needWait))handler;

/**
 APP GO

 @param successed 成功
 @param failure 失败
 */
-(void)appGoJumpWithHandler:(void(^)())successed failure:(void(^)(NSError *error))failure;


/// 提交代码
-(void)clearData;
@end
