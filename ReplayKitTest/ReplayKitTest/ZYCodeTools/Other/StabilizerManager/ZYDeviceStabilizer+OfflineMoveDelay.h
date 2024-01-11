//
//  ZYDeviceStabilizer+OfflineMoveDelay.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/7/8.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYDeviceStabilizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYDeviceStabilizer (OfflineMoveDelay)

@property (nonatomic, strong)  NSArray *offlineMoveProgressArray;//拍照的进度

#pragma -mark离线延时摄影

/**
 设置离线延时摄影
 
 @param status 设置的值
 @param complete 回掉
 */
-(void)setOffMovelineWithStatus:(ZYBlOtherCmdMoveLineStatueType)status Cmd:(void(^)(BOOL success, ZYBlOtherCmdMoveLineStatueData *info))complete;

/**
 
 @param complete 回掉
 */
-(void)readOffMovelineCompleteHandle:(void(^)(BOOL success, ZYBlOtherCmdMoveLineStatueData *info))complete;

@end

NS_ASSUME_NONNULL_END
