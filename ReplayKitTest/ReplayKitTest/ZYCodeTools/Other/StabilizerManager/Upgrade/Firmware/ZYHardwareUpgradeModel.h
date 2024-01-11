//
//  ZYHardwareUpgradeModel.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/13.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYHardwareUpgradeModel : NSObject


/**
 设备名称
 */
@property(nonatomic, copy)NSString *name;


/**
 日期
 */
@property(nonatomic, copy)NSString *date;


/**
 设备类型数组
 */
@property(nonatomic, strong)NSArray *device;


/**
 版本号
 */
@property(nonatomic, copy)NSString *version;

@end
