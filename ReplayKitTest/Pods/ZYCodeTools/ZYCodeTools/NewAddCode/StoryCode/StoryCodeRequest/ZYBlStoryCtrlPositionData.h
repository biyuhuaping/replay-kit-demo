//
//  ZYBlStoryCtrlPositionData.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlStoryCtrlPositionData : ZYBlData
/**
 [ -90, 90]
 */
@property (nonatomic) float pitchDegree;
/**
 [ -45, 45]
 */
@property (nonatomic) float rollDegree;
/**
 [-180,180]
 */
@property (nonatomic) float yawDegree;
/**
 预留，暂无含义
 */
@property (nonatomic) int duration;
//各个方向的精度
@property (nonatomic,readwrite)          float       precisionPitch;
@property (nonatomic,readwrite)          float       precisionRoll;
@property (nonatomic,readwrite)          float       precisionYaw;

@end

NS_ASSUME_NONNULL_END
