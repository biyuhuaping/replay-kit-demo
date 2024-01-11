//
//  ZYBlOtherOTAWaitData.h
//  ZYCamera
//
//  Created by wu on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZYBlOtherOTAWaitData : ZYBlData

/**
 needWait为0或者没响应命令表示不需要等待，为1表示需要等待。默认为不等待
 */
@property (nonatomic, readonly) NSUInteger needWait;

+ (instancetype)bleOtherOTAWaitData;

@end

NS_ASSUME_NONNULL_END
