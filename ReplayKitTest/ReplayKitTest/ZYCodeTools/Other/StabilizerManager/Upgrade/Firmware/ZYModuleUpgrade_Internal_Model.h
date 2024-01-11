//
//  ZYModuleUpgrade_Internal_Model.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYUpgradableInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYModuleUpgrade_Internal_Model : NSObject

/**
 指令数据
 */
@property(nonatomic, copy)NSString *data;

@property(nonatomic, copy)NSString *version;

@property(nonatomic, assign)ZYUpgradableChannel channel ;

@property(nonatomic, assign)int  deviceId;

@property(nonatomic, copy)NSString *postfix;


/**
 文件数据
 */
@property(nonatomic, strong)NSData *fileData;

@end

NS_ASSUME_NONNULL_END
