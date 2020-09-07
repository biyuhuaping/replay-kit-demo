//
//  ZYStabilizerHardwareMotion.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/4/7.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStabilizerHardwareMotion.h"

@implementation ZYStabilizerHardwareMotion

+(instancetype)stabilizerHardwareMotionAxisWithControlCode:(NSUInteger)controlCode angleCode:(NSUInteger)angleCode angle:(float)angle{
    ZYStabilizerHardwareMotion *motion = [ZYStabilizerHardwareMotion new];
    motion.controlCode = controlCode;
    motion.angleCode = angleCode;
    motion.angle = angle;
    return motion;
}

@end
