//
//  ZYDeviceRemoteControl.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/12/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceBase.h"
#import "ZYHardwareUpgradeManager.h"

@interface ZYDeviceRemoteControl : ZYDeviceBase
@property(nonatomic, strong)ZYHardwareUpgradeManager *hardwareUpgradeManager;
/**
 序列号 | 型号
 */
//@property(nonatomic, copy)NSString *modelNumberString;


/**
 软件版本
 */
@property(nonatomic, copy)NSString *softwareVersion;

@end
