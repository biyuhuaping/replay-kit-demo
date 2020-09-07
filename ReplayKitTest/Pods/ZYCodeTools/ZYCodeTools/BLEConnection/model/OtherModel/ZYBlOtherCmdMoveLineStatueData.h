//
//  ZYBIOtherCmdMoveLineStatueData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

typedef NS_ENUM(NSUInteger, ZYBlOtherCmdMoveLineStatueType) {
    ZYBlOtherCmdMoveLineStatueTypeReadStatue = 0,// 读取当前的状态
    ZYBlOtherCmdMoveLineStatueTypeStop,//结束
    ZYBlOtherCmdMoveLineStatueTypePause,//暂停
    ZYBlOtherCmdMoveLineStatueTypeBegain,//开始
    ZYBlOtherCmdMoveLineStatueTypeMoving,//移动中
};
NS_ASSUME_NONNULL_BEGIN
//离线延时摄影
@interface ZYBlOtherCmdMoveLineStatueData : ZYBlData
/**
  1：结束 2：暂停 3：开始 4.移动中
 */
@property (nonatomic, readwrite) NSUInteger moveLineStatus;

/**
 是否在离线延时摄影中

 @return 是否在离线延时摄影中
 */
-(BOOL)isoffLineMoving;

@end

NS_ASSUME_NONNULL_END
