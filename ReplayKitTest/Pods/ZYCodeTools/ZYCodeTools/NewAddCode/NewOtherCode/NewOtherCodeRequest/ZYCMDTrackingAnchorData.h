//
//  ZYCMDTrackingAnchorData.h
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYCMDTrackingAnchorData : ZYBlData

@property (nonatomic) uint8 direct;//0获取 1设置 
/*
  x,y 各占2字节
 成像中心的位置为500,500 成像左上角为0，0, 成像右下角为1000，1000
 使用后置摄像头时 若期望跟踪物体始终在成像左上1/4处 则x,y=250, 250
 使用前置摄像头时 若期望跟踪物体始终在成像左上1/4处 则x,y=750, 750
 */
@property (nonatomic) uint16 x; //
@property (nonatomic) uint16 y; //

@end

NS_ASSUME_NONNULL_END
