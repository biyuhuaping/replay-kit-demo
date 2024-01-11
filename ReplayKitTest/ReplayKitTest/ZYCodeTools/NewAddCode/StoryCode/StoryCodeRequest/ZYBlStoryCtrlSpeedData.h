//
//  ZYBlStoryCtrlSpeedData.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlStoryCtrlSpeedData : ZYBlData
/**
 [ 0, 4096]
 */
@property (nonatomic) int pitchSpeed;
/**
 [ 0, 4096]
 */
@property (nonatomic) int rollSpeed;
/**
 [ 0, 4096]
 */
@property (nonatomic) int yawSpeed;
/**
 [0,65535]
 */
@property (nonatomic) int duration;
@end

NS_ASSUME_NONNULL_END
