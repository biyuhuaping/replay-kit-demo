//
//  ZYAxisCalibrationLoop.h
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/2.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYSendRequest.h"

#define kLooTimeTnterval 0.1f

@interface ZYAxisCalibrationLoop : NSObject
@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;

@property(nonatomic, assign)NSInteger x;

@property(nonatomic, assign)NSInteger y;

@property(nonatomic, assign)NSInteger z;

@property(nonatomic, assign)NSInteger gyroStandardDifference;

@property(nonatomic, assign)NSInteger axisMapindex;


//@property (nonatomic, copy) SMDelayedBlockHandle delayedBlockHandle;

-(void)loopQueryAnglesIsStandardWithCompleted:(void(^)(void))completed;


-(void)closeLoop;
@end
