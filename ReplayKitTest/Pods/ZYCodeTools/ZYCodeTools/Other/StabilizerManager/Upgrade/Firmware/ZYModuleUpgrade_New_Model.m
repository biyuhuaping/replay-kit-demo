//
//  ZYModuleUpgrade_New_Model.m
//  ZYCamera
//
//  Created by 吴伟祥 on 2019/8/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYModuleUpgrade_New_Model.h"


@interface ZYModuleUpgrade_New_Model()
/// modules 的原始数据
@property(nonatomic, strong,readwrite)NSDictionary *origionDic;
@end

@implementation ZYModuleUpgrade_New_Model

+(ZYModuleUpgrade_New_Model *)initWithDic:(NSDictionary *)dic andCurrentModelNumber:(NSUInteger)modelNumber{
    //    NSDictionary *dic = [str mj_JSONObject];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        if ([dic count] > 0) {
            
            ZYModuleUpgrade_New_Model *mod  = [ZYModuleUpgrade_New_Model new];
            NSNumber *channel = [dic objectForKey:@"channel"];
            if ([channel respondsToSelector:@selector(integerValue)]) {
                mod.channel = [ZYUpgradableInfoModel updateChannel:[channel integerValue]];
            }
            NSNumber *version = [dic objectForKey:@"version"];
            if ([version respondsToSelector:@selector(integerValue)]) {
                mod.version = [NSString stringWithFormat:@"%@",version];
            }
            NSArray *modules = [dic objectForKey:@"modules"];
            if ([modules isKindOfClass:[NSArray class]]) {
                NSString *internalKey = kInternal;
                NSString *externalKey = kExternal;
                for (NSDictionary *inter in modules) {
                    NSArray *internal = [inter objectForKey:internalKey];
                    NSArray *external = [inter objectForKey:externalKey];
                    
                    if ([internal isKindOfClass:[NSArray class]]) {
                        mod.internal = [NSMutableArray new];
                        for (NSArray *arr in internal) {
                            if ([arr count]>= 3) {
                                ZYUpgradableInfoModel *internalMod = [[ZYUpgradableInfoModel alloc] initWithModelNumber:modelNumber];
                                for (int i = 0; i < 3; i++) {
                                    id value = [arr objectAtIndex:i];
                                    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                                        
                                        switch (i) {
                                            case 0:
                                                [internalMod updateDeviceIdAndChannel:[[NSString stringWithFormat:@"%@",value] integerValue]];
                                                break;
                                                
                                            case 1:
                                                internalMod.version = [[NSString stringWithFormat:@"%@",value] integerValue];
                                                break;
                                                
                                            case 2:
                                                internalMod.upgrateExtention = [NSString stringWithFormat:@"%@",value];
                                                break;
                                            default:
                                                break;
                                        }
                                    }
                                }
                                [mod.internal addObject:internalMod];
                            }
                        }
                    }else if ([external isKindOfClass:[NSArray class]]){
                        mod.external = [NSMutableArray new];
                        for (NSArray *arr in external) {
                            if ([arr count]>= 5) {
                                
                                id valueArr = [arr objectAtIndex:3];
                                if ([valueArr isKindOfClass:[NSArray class]]) {
                                    NSArray *packageArray = valueArr;
                                    
                                    int maxJ = (int)MAX(1, packageArray.count);
                                    
                                    for (int j = 0; j < maxJ; j++) {
                                        ZYUpgradableInfoModel *external = [[ZYUpgradableInfoModel alloc] init];
                                        external.modelType = ZYUpgradableInfoModelTypeExternal;
                                        for (int i = 0; i < 5; i++) {
                                            id value = [arr objectAtIndex:i];
                                            if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSArray class]]) {
                                                
                                                switch (i) {
                                                    case 0:
                                                        external.modelNumber = [[NSString stringWithFormat:@"%@",value] integerValue];
                                                        break;
                                                        
                                                    case 1:
                                                        external.version = [[NSString stringWithFormat:@"%@",value] integerValue];
                                                        break;
                                                        
                                                    case 2:
                                                        external.dependency = [[NSString stringWithFormat:@"%@",value] integerValue];
                                                        break;
                                                        
                                                    case 3:
                                                        if ([value isKindOfClass:[NSArray class]]) {
                                                            NSArray *package = value;
                                                            if (package.count > 0) {
                                                                external.upgrateExtention = package[j];
                                                            }
                                                            
                                                        }
                                                        break;
                                                        
                                                    case 4:
                                                    {
                                                        NSString *target = [NSString stringWithFormat:@"%@",value];
                                                        external.modelTypeExternalName = @"";
                                                        if (target.length) {
                                                            NSArray *source = [target componentsSeparatedByString:@","];
                                                            external.modelTypeExternalName = [source objectAtIndex:0];
                                                            NSString *tempe = [source objectAtIndex:1];
                                                            [external updateDeviceIdAndChannel:[tempe integerValue]];
                                                        }
                                                        break;
                                                    }
                                                    default:
                                                        break;
                                                }
                                            }
                                            
                                        }
                                        [mod.external addObject:external];
                                    }
                                    
                                }
                                
                                
                            }
                        }
                        
#warning 测试代码 暂时关闭External
                    }
                }
            }
            
            mod.modules = [[NSMutableArray alloc] init];
            if (mod.external.count) {
                [mod.modules addObjectsFromArray:mod.external];
            }
            if (mod.internal.count){
                [mod.modules addObjectsFromArray:mod.internal];
            }
           
            mod.origionDic = [dic copy];
            return mod;
        }
        
        //        NSLog(@"mod:%@",mod);
    }
    return nil;
}

+(ZYModuleUpgrade_New_Model *)p_initWithDic:(NSDictionary *)dic{
    //    NSDictionary *dic = [str mj_JSONObject];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        ZYModuleUpgrade_New_Model *mod  = [ZYModuleUpgrade_New_Model new];
        NSNumber *channel = [dic objectForKey:@"channel"];
        if ([channel respondsToSelector:@selector(integerValue)]) {
            mod.channel = [channel integerValue];
        }
        NSNumber *version = [dic objectForKey:@"version"];
        if ([version respondsToSelector:@selector(integerValue)]) {
            mod.version = [NSString stringWithFormat:@"%@",version];
        }
        NSArray *modules = [dic objectForKey:@"modules"];
        if ([modules isKindOfClass:[NSArray class]]) {
            NSString *internalKey = kInternal;
            NSString *externalKey = kExternal;
            mod.modules = [NSMutableArray new];
            for (NSDictionary *inter in modules) {
                NSArray *internal = [inter objectForKey:internalKey];
                NSArray *external = [inter objectForKey:externalKey];
                
                if ([internal isKindOfClass:[NSArray class]]) {
                    mod.internal = [NSMutableArray new];
                    NSMutableArray *internalMarr = [NSMutableArray new];
                    
                    for (NSArray *arr in internal) {
                        if ([arr count]>= 3) {
                            ZYModuleUpgrade_Internal_Model *internalMod = [ZYModuleUpgrade_Internal_Model new];
                            for (int i = 0; i < 3; i++) {
                                id value = [arr objectAtIndex:i];
                                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                                    
                                    switch (i) {
                                        case 0:
                                            
                                            internalMod.data = [NSString stringWithFormat:@"%@",value];
                                            break;
                                            
                                        case 1:
                                            internalMod.version = [NSString stringWithFormat:@"%@",value];
                                            break;
                                            
                                        case 2:
                                            internalMod.postfix = [NSString stringWithFormat:@"%@",value];
                                            break;
                                        default:
                                            break;
                                    }
                                }
                            }
                            [internalMarr addObject:internalMod];
                            [mod.internal addObject:internalMod];
                        }
                    }
                    if ([internalMarr count]) {
                        NSMutableDictionary *internalDic = [NSMutableDictionary new];
                        [internalDic setObject:internalMarr forKey:internalKey];
                        [mod.modules addObject:internalDic];
                    }
                }else if ([external isKindOfClass:[NSArray class]]){
                    mod.external = [NSMutableArray new];
                    NSMutableArray *externalMArr = [NSMutableArray new];
                    
                    for (NSArray *arr in external) {
                        if ([arr count]>= 5) {
                            ZYModuleUpgrade_External_Model *external = [ZYModuleUpgrade_External_Model new];
                            for (int i = 0; i < 5; i++) {
                                id value = [arr objectAtIndex:i];
                                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSArray class]]) {
                                    
                                    switch (i) {
                                        case 0:
                                            external.code = [NSString stringWithFormat:@"%@",value];
                                            break;
                                            
                                        case 1:
                                            external.mVersion = [NSString stringWithFormat:@"%@",value];
                                            break;
                                            
                                        case 2:
                                            if ([value respondsToSelector:@selector(integerValue)]) {
                                                external.dependency = [value integerValue];
                                                
                                            }
                                            break;
                                            
                                        case 3:
                                            if ([value isKindOfClass:[NSArray class]]) {
                                                external.package = value;
                                                
                                            }else if ([value isKindOfClass:[NSString class]]){
                                                NSArray *package = [value componentsSeparatedByString:@","];
                                                external.package = package;
                                            }
                                            break;
                                            
                                        case 4:
                                            external.target = [NSString stringWithFormat:@"%@",value];
                                            break;
                                        default:
                                            break;
                                    }
                                }
                                
                            }
                            [mod.external addObject:external];
                            [externalMArr addObject:external];
                        }
                    }
                    if ([externalMArr count]) {
                        NSDictionary *extdic = @{externalKey:externalMArr};
                        [mod.modules addObject:extdic];
                    }
#warning 测试代码 暂时关闭External
                }
            }
        }
        mod.origionDic = [dic copy];
        return mod;
        //        NSLog(@"mod:%@",mod);
    }
    return nil;
}
@end
