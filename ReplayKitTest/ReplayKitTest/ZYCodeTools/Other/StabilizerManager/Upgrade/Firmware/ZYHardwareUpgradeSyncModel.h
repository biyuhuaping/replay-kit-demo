//
//  ZYHardwareUpgradeSyncModel.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/24.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYHardwareUpgradeSyncModel : NSObject

/**
 arch版本号
 */
@property(nonatomic, assign)NSInteger archVersion ;


/**
 总数
 */
@property(nonatomic, assign)NSInteger count ;


/**
 硬件版本
 */
@property(nonatomic, assign)NSInteger hwVersion ;


/**
 长度
 */
@property(nonatomic, assign)NSInteger size ;


+(instancetype)UpgradeSyncModelWithDictionary:(NSDictionary *)dic;

@end
