//
//  ZYModuleUpgrade_New_Model.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYUpgradableInfoModel.h"
#import "ZYModuleUpgrade_Internal_Model.h"
#import "ZYModuleUpgrade_External_Model.h"

#define kInternal @"internal"
#define kExternal @"external"
#define kDependency @"dependency"
#define kSoftwareVersion @"softwareVersion"

#define kDeviceName @"deviceName"
#define kSoftwareVersion @"softwareVersion"

NS_ASSUME_NONNULL_BEGIN

/**
 ZYBle协议，的Json解析出来的模型
 <h5 id="modules">modules //模块信息查询</h5>

 */
@interface ZYModuleUpgrade_New_Model : NSObject
//软件版本
@property(nonatomic, copy)NSString *version;
//升级的主链路
@property(nonatomic, assign)ZYUpgradableChannel channel ;
//所有的ZYUpgradableInfoModel
@property(nonatomic, strong)NSMutableArray *modules;
//所有的internal  ZYUpgradableInfoModel
@property(nonatomic, strong)NSMutableArray *internal;
//所有的external  ZYUpgradableInfoModel
@property(nonatomic, strong)NSMutableArray *external;

/// modules 的原始数据
@property(nonatomic, strong,readonly)NSDictionary *origionDic;

+(ZYModuleUpgrade_New_Model *)initWithDic:(NSDictionary *)dic andCurrentModelNumber:(NSUInteger)modelNumber;

@end

NS_ASSUME_NONNULL_END
