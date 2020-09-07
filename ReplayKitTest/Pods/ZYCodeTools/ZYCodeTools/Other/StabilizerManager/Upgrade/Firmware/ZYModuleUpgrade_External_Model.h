//
//  ZYModuleUpgrade_External_Model.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYUpgradableInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYModuleUpgrade_External_Model : NSObject


/**
 |code         |产品序列号          |空      |stars 2.1中定义一致, 整数|
 */
@property(nonatomic, copy)NSString *code;


/**
 |mVersion     |模块版本号          |0.00     |  |
 */
@property(nonatomic, copy)NSString *mVersion;


/**
 |dependency   |依赖性              |0      |0表示可选, 1表示必须|
 */
@property(nonatomic, assign)BOOL  dependency;


/**
 |package      |是否整包             |[]      |数组元素为0即为整包,否则按顺序填入分包的文件后缀|

 */
@property(nonatomic, strong)NSArray *package;


/**
 |target       |目标设备名           |空      |空则使用当前连接设备链路,有值则使用指定设备的链路|

 */
@property(nonatomic, copy)NSString *target;

//@property(nonatomic, strong)NSData *data;

@property(nonatomic, strong)NSMutableArray<NSData *> *failsData;

@property(nonatomic, copy)NSString *name;

//@property(nonatomic, copy)NSString *channel;
@property(nonatomic, assign)ZYUpgradableChannel channel ;

@end

NS_ASSUME_NONNULL_END
