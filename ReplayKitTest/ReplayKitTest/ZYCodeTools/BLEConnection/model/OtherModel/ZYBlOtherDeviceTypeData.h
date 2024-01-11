//
//  ZYBlOtherDeviceTypeData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/21.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

// WPJ

// 设备类型
typedef NS_ENUM(NSUInteger, ZYBlOtherDeviceType) {
    ZYBlOtherDeviceTypeCamera = 0x0,            // 卡片机
    ZYBlOtherDeviceTypeMobile = 0x1,            // 手机
};

// 获取、设置
typedef NS_ENUM(NSUInteger, ZYBlOtherDeviceOperation) {
    ZYBlOtherDeviceOperationGet = 0x80,            // 获取
    ZYBlOtherDeviceOperationSet = 0x0,            // 设置
};


NS_ASSUME_NONNULL_BEGIN

@interface ZYBlOtherDeviceTypeData : ZYBlData
/**
0x80    获取设备类型 0x00    设置设备类型
 */
@property (nonatomic, readwrite) NSUInteger direct;

/**
0    卡片机 1    手机
 */
@property (nonatomic, readwrite) NSUInteger type;

@end

NS_ASSUME_NONNULL_END
