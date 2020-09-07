//
//  ZYBlOtherHeart.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/9/6.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

typedef NS_ENUM(NSInteger,ZYBlOtherHeartType) {
    ZYBlOtherHeartTypeOrigion = 0,
    ZYBlOtherHeartTypeOther,
    ZYBlOtherHeartTypeDirectOnly,//只有方向的控制
};
@interface ZYBlOtherHeart : ZYBlData

/// 是否是原生app和第三方app  0x00原生app  0x01 第三方app
@property (nonatomic) ZYBlOtherHeartType heartType;

/**
 状态标志 1为异步
 */
@property (nonatomic, readonly) NSUInteger flag;

/// 电量
@property (nonatomic) int battery;

/// 错误的码
@property (nonatomic) int errorType;

@end
