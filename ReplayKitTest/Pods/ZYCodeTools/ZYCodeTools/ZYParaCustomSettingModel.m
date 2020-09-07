//
//  ZYParaCustomSettingModel.m
//  ZYCamera
//
//  Created by lgj on 2017/3/15.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import "ZYParaCustomSettingModel.h"
#import "ZYStablizerDefineENUM.h"

@implementation ZYParaCustomSettingModel

/**
 通过字典初始化
 
 @param dictionary 字典
 @return 模型对象
 */
+(ZYParaCustomSettingModel *)initWithDictionary:(NSDictionary *)dictionary{
    ZYParaCustomSettingModel *model = nil;
    if (dictionary) {
        model = [[ZYParaCustomSettingModel alloc] init];
        [model setValuesForKeysWithDictionary:dictionary];
        if (![dictionary objectForKey:@"contextualModel"]) {
            model.contextualModel = @(ZYParaCustomSettingContextualModelCustom);
        }
    }
    return model;
}

+(ZYParaCustomSettingModel *)initWithZYEquipmentContextualModel:(ZYParaCustomSettingContextualModel)model{
    switch (model) {
        case ZYParaCustomSettingContextualModelDefault:
        {
            NSDictionary *dicDefault = @{@"controlDirectPitch":@(NO),@"controlDirectRoll":@(NO),@"controlDirectYaw":@(NO),                                      @"deadzonePitch":@(2),@"deadzoneRoll":@(5),@"deadzoneYaw":@(5),
                                      @"trimmingPitch":@(0),@"trimmingRoll":@(0),
                                      @"smoothnessPitch":@(100),@"smoothnessRoll":@(100),@"smoothnessYaw":@(100),
                                      @"controlSpeedPitch":@(25),@"controlSpeedRoll":@(25),@"controlSpeedYaw":@(45),
                                         @"followSpeedPitch":@(80),@"followSpeedRoll":@(80),@"followSpeedYaw":@(60),@"contextualModel":@(ZYParaCustomSettingContextualModelDefault)};
            return [self initWithDictionary:dicDefault];
        }
        case ZYParaCustomSettingContextualModelWalk:
        {
            NSDictionary *dicWalk = @{@"controlDirectPitch":@(NO),@"controlDirectRoll":@(NO),@"controlDirectYaw":@(NO),                                      @"deadzonePitch":@(2),@"deadzoneRoll":@(5),@"deadzoneYaw":@(5),
                                       @"trimmingPitch":@(0),@"trimmingRoll":@(0),
                                      @"smoothnessPitch":@(100),@"smoothnessRoll":@(100),@"smoothnessYaw":@(100),
                                    @"controlSpeedPitch":@(25),@"controlSpeedRoll":@(25),@"controlSpeedYaw":@(45),
                                    @"followSpeedPitch":@(80),@"followSpeedRoll":@(80),@"followSpeedYaw":@(60),@"contextualModel":@(ZYParaCustomSettingContextualModelWalk)};
            return [self initWithDictionary:dicWalk];
        }
        case ZYParaCustomSettingContextualModelMovement:
        {
            NSDictionary *dicMovement = @{@"controlDirectPitch":@(NO),@"controlDirectRoll":@(NO),@"controlDirectYaw":@(NO),                                      @"deadzonePitch":@(2),@"deadzoneRoll":@(5),@"deadzoneYaw":@(5),
                                      @"trimmingPitch":@(0),@"trimmingRoll":@(0),
                                      @"smoothnessPitch":@(200),@"smoothnessRoll":@(200),@"smoothnessYaw":@(200),
                                      @"controlSpeedPitch":@(100),@"controlSpeedRoll":@(100),@"controlSpeedYaw":@(100),
                                      @"followSpeedPitch":@(120),@"followSpeedRoll":@(120),@"followSpeedYaw":@(120),@"contextualModel":@(ZYParaCustomSettingContextualModelMovement)};
            return [self initWithDictionary:dicMovement];
        }
        case ZYParaCustomSettingContextualModelCustom:
        {
            NSDictionary *dicCustom = @{@"controlDirectPitch":@(NO),@"controlDirectRoll":@(NO),@"controlDirectYaw":@(NO),                                      @"deadzonePitch":@(2),@"deadzoneRoll":@(5),@"deadzoneYaw":@(5),
                                      @"trimmingPitch":@(0),@"trimmingRoll":@(0),
                                      @"smoothnessPitch":@(100),@"smoothnessRoll":@(100),@"smoothnessYaw":@(100),
                                      @"controlSpeedPitch":@(25),@"controlSpeedRoll":@(25),@"controlSpeedYaw":@(45),
                                      @"followSpeedPitch":@(80),@"followSpeedRoll":@(80),@"followSpeedYaw":@(60),@"contextualModel":@(ZYParaCustomSettingContextualModelCustom)};
            return [self initWithDictionary:dicCustom];
        }
        default:
            break;
    }
    return nil;
}

+(ZYParaCustomSettingModel *)initWithZYEquipmentContextualModelCustomWithSaveName:(NSString *)saveName{
    NSMutableArray *array = [self saveSettingArray];
    NSDictionary *dic = nil;
    for (NSDictionary *modelDic in array) {
        NSString *name =  [modelDic objectForKey:@"saveCustomName"];
        if([saveName isEqualToString:name]){
            dic = modelDic;
            break;
        }
    }
    
    if (dic) {
        ZYParaCustomSettingModel *model = [ZYParaCustomSettingModel initWithDictionary:dic];
        return model;
    }
    else{
        return [ZYParaCustomSettingModel initWithZYEquipmentContextualModel:ZYParaCustomSettingContextualModelCustom];;
    }
}

-(NSString *)description{
    return [NSString stringWithFormat:@"controlDirectPitch = %@,controlDirectRoll = %@,controlDirectYaw = %@,deadzonePitch = %@,deadzoneRoll = %@,deadzoneYaw = %@,trimmingPitch = %@,trimmingRoll = %@,smoothnessPitch = %@,smoothnessRoll = %@,smoothnessYaw = %@,controlSpeedPitch = %@,controlSpeedRoll = %@,controlSpeedYaw = %@,followSpeedPitch = %@,followSpeedRoll = %@,followSpeedYaw = %@,saveCustomName = %@",self.controlDirectPitch,self.controlDirectRoll,self.controlDirectYaw,self.deadzonePitch,self.deadzoneRoll,self.deadzoneYaw,self.trimmingPitch,self.trimmingRoll,self.smoothnessPitch,self.smoothnessRoll,self.smoothnessYaw,self.controlSpeedPitch,self.controlSpeedRoll,self.controlSpeedYaw,self.followSpeedPitch,self.followSpeedRoll,self.followSpeedYaw,self.saveCustomName];
}
/**
 屏蔽错误

 @param value 没有的value
 @param key 没有的key
 */
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"%s",__func__);
    NSLog(@"key = %@,value = %@",key,value);
}

-(void)setNilValueForKey:(NSString *)key{
    NSLog(@"%s",__func__);
    NSLog(@"key = %@",key);

}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"%s",__func__);
    NSLog(@"key = %@",key);
    return [NSNull null];
}
/**
 模型设置给稳定器
 
 @return 是否设置成功
 */
-(BOOL)setStablizer{
    
    
    return YES;
}


/**
 保存数据
 */
-(BOOL)saveToDisk{
    BOOL success = NO;
    NSDictionary *dic = [self dictionaryWithValuesForKeys:@[@"controlDirectRoll",@"controlDirectYaw",@"controlDirectPitch",
                                                            @"deadzonePitch",@"deadzoneYaw",@"deadzoneRoll",
                                                            @"trimmingRoll",@"trimmingPitch",
                                                            @"smoothnessRoll",@"smoothnessYaw",@"smoothnessPitch",
                                                        @"controlSpeedRoll",@"controlSpeedYaw",@"controlSpeedPitch",
                                                        @"followSpeedRoll",@"followSpeedYaw",@"followSpeedPitch",@"saveCustomName"]];
    if (dic != nil) {
        NSMutableArray *array = [[self class] saveSettingArray];

        [array addObject:dic];
        
        success = [array writeToFile:[[self class] plistPath] atomically:YES];
        if (success) {
            NSLog(@"保存plist成功");
        }
        else{
            NSLog(@"保存plist失败");
        }

    }
    
    return success;
}

-(BOOL)updateToDisk{
    BOOL success = NO;
    
    NSMutableArray *array = [[self class] saveSettingArray];
    NSInteger replaceIndex = -1;
    for (NSDictionary *modelDic in array) {
        NSString *name =  [modelDic objectForKey:@"saveCustomName"];
        if([self.saveCustomName isEqualToString:name]){
            replaceIndex = [array indexOfObject:modelDic];
            break;
        }
    }

    NSDictionary *dic = [self dictionaryWithValuesForKeys:@[@"controlDirectRoll",@"controlDirectYaw",@"controlDirectPitch",
                                                            @"deadzonePitch",@"deadzoneYaw",@"deadzoneRoll",
                                                            @"trimmingRoll",@"trimmingPitch",
                                                            @"smoothnessRoll",@"smoothnessYaw",@"smoothnessPitch",
                                                            @"controlSpeedRoll",@"controlSpeedYaw",@"controlSpeedPitch",
                                                            @"followSpeedRoll",@"followSpeedYaw",@"followSpeedPitch",@"saveCustomName"]];
   
    if (dic != nil) {
        
        if (replaceIndex >= 0) {
            [array replaceObjectAtIndex:replaceIndex  withObject:dic];
        }
        else{
            [array addObject:dic];
        }
        
        success = [array writeToFile:[[self class] plistPath] atomically:YES];
        if (success) {
            NSLog(@"update plist成功");
        }
        else{
            NSLog(@"update plist失败");
        }
        
    }
    
    return success;
}

+(BOOL)deleteToDiskWithCustomModeName:(NSString *)customName{
    BOOL success = NO;
    
    NSMutableArray *array = [[self class] saveSettingArray];
    NSInteger deleteIndex = -1;

    for (NSDictionary *modelDic in array) {
        NSString *name =  [modelDic objectForKey:@"saveCustomName"];
        if([customName isEqualToString:name]){
            deleteIndex = [array indexOfObject:modelDic];
            break;
        }
    }
    
    if (deleteIndex >= 0) {
        [array removeObjectAtIndex:deleteIndex];
        success = [array writeToFile:[[self class] plistPath] atomically:YES];
        if (success) {
            NSLog(@"delete model成功");
        }
        else{
            NSLog(@"delete model失败");
        }
    }
    else{
        NSLog(@"没有找到这样的模型数据");
    }
    
    return success;
}

-(BOOL)deleteToDisk{
    return [[self class] deleteToDiskWithCustomModeName:self.saveCustomName];
}

+(NSString *)ZYParaCustomSettingPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths lastObject];
    NSString *directryPath = [path stringByAppendingPathComponent:@"ZYParaCustomSetting"];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:directryPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directryPath;
}

+(NSString *)plistPath{
    NSString *plistString = [[self ZYParaCustomSettingPath] stringByAppendingPathComponent:@"ZYParaCustomSetting.plist"];
    return plistString;
}

+(NSMutableArray *)saveSettingArray{
    NSMutableArray *settingArray = [NSMutableArray arrayWithContentsOfFile:[self plistPath]];
    if (settingArray == nil) {
        settingArray = [[NSMutableArray alloc] init];
        
    }
    return settingArray;
}

+(NSMutableArray *)saveCustomArrayName{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    NSMutableArray *array = [self saveSettingArray];
    for (NSDictionary *modelDic in array) {
       NSString *name =  [modelDic objectForKey:@"saveCustomName"];
        if (name) {
            [returnArray addObject:name];
        }
        else{
            NSLog(@"no saveCustomName");
        }
    }
    
    return returnArray;
}

+(BOOL)checkSaveNameAvailable:(NSString *)saveName{
    if ([saveName isEqualToString:NSLocalizedString(@"CONTEXTUAL_MODEL_WALK", nil)] || [saveName isEqualToString:NSLocalizedString(@"CONTEXTUAL_MODEL_MOVEMENT", nil)]|| [saveName isEqualToString:NSLocalizedString(@"CONTEXTUAL_MODEL_DEFAULT", nil)]|| [saveName isEqualToString:NSLocalizedString(@"CONTEXTUAL_MODEL_CUSTOM", nil)]) {
        return NO;
    }
    NSMutableArray *array = [self saveSettingArray];
    for (NSDictionary *modelDic in array) {
        NSString *name =  [modelDic objectForKey:@"saveCustomName"];
        if([saveName isEqualToString:name]){
            return NO;
        }
    }
    return YES;
}
@end
