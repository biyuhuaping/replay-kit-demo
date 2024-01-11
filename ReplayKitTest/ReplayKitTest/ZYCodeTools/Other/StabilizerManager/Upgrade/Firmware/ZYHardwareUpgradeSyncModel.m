//
//  ZYHardwareUpgradeSyncModel.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2017/3/24.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYHardwareUpgradeSyncModel.h"

@implementation ZYHardwareUpgradeSyncModel

+(instancetype)UpgradeSyncModelWithDictionary:(NSDictionary *)dic{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        ZYHardwareUpgradeSyncModel *synModel = [[ZYHardwareUpgradeSyncModel alloc] init];
        synModel.archVersion = [[dic objectForKey:@"archVersion"] integerValue];
        
        synModel.count = [[dic objectForKey:@"count"] integerValue];
        synModel.hwVersion = [[dic objectForKey:@"hwVersion"] integerValue];
        synModel.size = [[dic objectForKey:@"size"] integerValue];

        return synModel;
    }
    return nil;
}

@end
