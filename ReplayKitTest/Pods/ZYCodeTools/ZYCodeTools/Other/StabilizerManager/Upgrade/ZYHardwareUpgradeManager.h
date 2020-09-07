//
//  ZYHardwareUpgradeManager.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/9.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYModuleUpgrade_New_Model.h"

#import "ZYSendRequest.h"
/**
 固件更新，更新状态更新通知
 */
extern NSString* const HardwareUpgrade_StatusDidChange;

/**
 固件更新成功通知，带参数 @{@"isNeed":@(isNeed)}
 */
extern NSString* const HardwareUpgrade_IsNeedToUpgrade;


#define kHardwareIsNeedUpgrade @"kHardwareNeedUpgrade"

#import <Foundation/Foundation.h>
#import "ZYHDupgrade.h"
#import "ZYModuleUpgrade_External_Model.h"

typedef NS_ENUM(NSInteger,ZYUpgradeStatus) {
    ZYUpgradeStatusHaveNewVersion = 0,
    ZYUpgradeStatusLateseVersion ,
    ZYUpgradeStatusUnfindFitSerise,
    ZYUpgradeStatusDownloading,
    ZYUpgradeStatusDownloadCompleted,
    ZYUpgradeStatusDownloadFailure,
    ZYUpgradeStatusSendingData,
    ZYUpgradeStatusUpgardeing,
    ZYUpgradeStatusUpgardeSuccessed,
    ZYUpgradeStatusUpagrdeFailure,
    
};

typedef void(^ProgressDidChangeBlock)(float progressValue);

extern NSString* const UpagrdeStatus_HaveNewVersion;

@interface ZYHardwareUpgradeManager : NSObject///////// Interface

@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;

/**
 当前的升级状态
 */
@property(nonatomic, assign)ZYUpgradeStatus upgardeStatus ;

/**
 下载或在升级就会调用的block
 */
@property(nonatomic, copy)ProgressDidChangeBlock progressDidChangeBlock ;

//是否正在升级中
@property(nonatomic, assign)BOOL isUpgradeing ;

/**
 ZYBle协议，的Json解析出来的模型
 <h5 id="modules">modules //模块信息查询</h5>
 */
@property(nonatomic, strong)ZYModuleUpgrade_New_Model *jsonNewModel;

@property(nonatomic, strong)NSArray<ZYUpgradableInfoModel*>* moduleUpgradeInfos;

@property(nonatomic, strong)NSMutableArray *upgradeArray;

/**
 通过软件版本号和设备类型创建升级管理类

 @param softwareVersion 软件版本号
 @param modelNumberString 设备类型
 @return 升级管理类
 */
+(instancetype)hardwareUpgradeManagerWithSoftwareVersion:(NSString *)softwareVersion  modelNumberString:(NSString *)modelNumberString;

/**
 清除缓存
 */
-(void)clearData;

/// beginUpgrade之前要先配置数据
/// @param deviceCode devicecode
/// @param softVersion 软件版本
-(void)configUpgradeData:(NSUInteger)deviceCode softVersion:(NSString *)softVersion;
/**
 开始升级
 */
-(void)beginUpgrade:(void (^)(BOOL success))callback progress:(void(^)(float progress,NSInteger count, NSInteger currentIndex,ZYUpgradeStatus prgressType))progress;

/**
 当前连接的设备能否升级

 @return 是否能够升级
 */
+(BOOL)isCanUpgradeDevice;



@end
