//
//  ZYUpgradeDirectTools.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/11/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYUpgradeDirectTools : NSObject

/// 升级数据库存放的位置
+(NSString *)ZYUpgradeDirectBasePath;
/// 升级的文件夹父节点
+(NSString *)ZYUpgradeDirPath;


/// 移除除了softVersion之外的所有版本
/// @param refID refid
/// @param softVersion 软件版本
+(void)removeAllFileInRefID:(NSUInteger)refID withOutSoftVersion:(NSString *)softVersion;
/// 升级的文件夹父节点下面的RefID下面的软件版本文件夹
+(NSString *)ZYUpgradeDirPathWithRefID:(NSUInteger)refID softVersion:(NSString *)softVersion;
//升级的按照包的列表，只要把这些文件里面的大小计算就行，删除也只要删除对应的文件
+(NSMutableArray *) upgradeSoftwareFiles;

@end

NS_ASSUME_NONNULL_END
