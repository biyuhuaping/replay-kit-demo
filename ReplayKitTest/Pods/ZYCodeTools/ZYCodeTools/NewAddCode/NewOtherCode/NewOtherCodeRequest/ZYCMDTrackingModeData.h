//
//  ZYCMDTrackingModeData.h
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYCMDTrackingModeData : ZYBlData


@property (nonatomic) uint8 direct;// 0获取 1设置

@property (nonatomic) uint8 mode; //0 代表关闭 1代表开启

@end

NS_ASSUME_NONNULL_END
