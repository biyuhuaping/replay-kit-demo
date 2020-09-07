//
//  ZYStabilizerTools.m
//  ZYCamera
//
//  Created by lgj on 2017/6/20.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYStabilizerTools.h"

@implementation ZYStabilizerTools

+(NSString *)softwareVersionForDisplay:(id)softwareVersion{
    if (softwareVersion == nil) {
        return nil;
    }
    if ([softwareVersion isKindOfClass:[NSString class]]) {
        NSString *string = softwareVersion;
        int softwareVersionValue = [string intValue];
        return [NSString stringWithFormat:@"%d.%02d",softwareVersionValue / 100 ,softwareVersionValue % 100];
    }
    else{
        return nil;
    }
 
}

+(BOOL)needToUpdateSoftwareVersionForMoveDelayRecord:(id)softwareVersion{
    if (softwareVersion == nil) {
        return NO;
    }
    if ([softwareVersion isKindOfClass:[NSString class]]) {
        NSString *value = softwareVersion;

        if ([value   compare: @"160"]  == NSOrderedDescending || [value   compare: @"160"]  == NSOrderedSame) {
            return NO;
        }else{
            return YES;
        }
    }
    else{
        return NO;
    }
}
@end
