//
//  ZYUpgradeServerTool.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/10/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//
#import "ZYModuleUpgrade_New_Model.h"
#define kLocalUpgradeModel @"kLocalUpgradeModel"
#define kHardwareIsNeedUpgrade @"kHardwareNeedUpgrade"

#import <Foundation/Foundation.h>
#import "ZYHDupgrade.h"
#import "ZYModuleUpgrade_External_Model.h"
#import "ZYSendRequest.h"
#import "ZYConnectedDataBase.h"
#import "ZYQueryRespondDataBase.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ProgressDidChangeBlock)(float progressValue);

typedef NSString *_Nonnull(^sourceDownLoadUrl)(NSUInteger refID,NSString *softVersion);

typedef NSString * _Nonnull  (^PingNetworkUrl)(void);

@interface ZYUpgradeServerTool : NSObject

@property (nonatomic,copy) sourceDownLoadUrl downLoadUrl;//必须设置
@property (nonatomic,copy) PingNetworkUrl pingNetworkUrl;//必须设置

@property (nullable, copy) NSDictionary<NSString *, NSString *> *allHTTPHeaderFields;//设置网络请求的头信息


+( instancetype ) shareInstant;

///connectedData离线检测
/// @param connectedData 连接了的设备
+(BOOL)checkLocalByConnectedData:(ZYConnectedData *)connectedData;
/// 检查是否需要升级
/// @param refID refid
/// @param softVersion 软件版本
/// @param modulMessage 扩展模块
/// @param handler 是否需要升级
-(void)serverCheckNeedUpgradeWithrefID:(NSUInteger)refID softVersion:(NSString *)softVersion moduleMessage:(ZYModuleUpgrade_New_Model *)modulMessage handler:(void (^)(BOOL isNeedUpdate))handler;

/**
 ping地址

 @param handler 回调
 */
-(void)pingnetworkwithhandle:(void (^)(BOOL success))handler;


#pragma mark DownLoad
-(void)downloadAndCompressByModel:(ZYHDupgrade *)model success:(void (^)(void))success progress:(void (^)(float progress))progresses failure:(void (^)(NSError *error))failure;


-(void)cancelDownload;

/// 更新ZYUpgradableInfoModel的URL 新的模块化升级softversion必须得为nil
/// @param modules 模块信息
/// @param refID 设备ID
/// @param softVersion 软件版本
+(BOOL)upgratedataURLByModules:(NSArray <ZYUpgradableInfoModel *>*)modules ByRefId:(NSUInteger)refID softVersion:(NSString *)softVersion;

/// 检查安装包是否存在
/// @param modules 模块信息
/// @param refID 设备ID
/// @param softVersion 软件版本，新的模块化升级softversion必须得为nil
+(BOOL)checkLocalByModules:(NSArray <ZYUpgradableInfoModel *>*)modules ByRefId:(NSUInteger)refID softVersion:(NSString *)softVersion;

/// 下载安装包
/// @param refID refID
/// @param softVersion s软件版本
/// @param success 下载成功
/// @param progresses 下载进度
/// @param failure 下载失败
-(void)downloadAndCompressByRefId:(NSUInteger)refID softVersion:(NSString *)softVersion success:(void (^)(void))success progress:(void (^)(float))progresses failure:(void (^)(NSError *error))failure;


#pragma  mark - check


-(void)updateLocalDataSource;

/**
 通过设备类型检查是否需要升级，发通知kHardwareIsNeedUpgrade反馈是否需要

 @param deviceModel 设备类型
 */
+(void)checkLocalDatasorceIsNeedToUpgradeByRefId:(NSUInteger)refId;

//升级的按照包的列表，只要把这些文件里面的大小计算就行，删除也只要删除对应的文件
+(NSMutableArray *) upgradeSoftwareFiles;
@end

NS_ASSUME_NONNULL_END
