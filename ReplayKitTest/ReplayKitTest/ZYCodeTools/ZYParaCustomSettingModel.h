//
//  ZYParaCustomSettingModel.h
//  ZYCamera
//
//  Created by lgj on 2017/3/15.
//  Copyright © 2017年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 情景模式

 - ZYEquipmentContextualModelWalk: 行走
 - ZYEquipmentContextualModelMovement: 运动
 - ZYEquipmentContextualModelDefault: 默认
 - ZYEquipmentContextualModelCustom: 自定义
 */
typedef NS_ENUM(NSInteger, ZYParaCustomSettingContextualModel) {
    ZYParaCustomSettingContextualModelWalk,
    ZYParaCustomSettingContextualModelMovement,
    ZYParaCustomSettingContextualModelDefault,
    ZYParaCustomSettingContextualModelCustom,
};
@interface ZYParaCustomSettingModel : NSObject
@property (nonatomic, strong) NSNumber  *followSpeedPitch;//跟随速度
@property (nonatomic, strong) NSNumber  *followSpeedRoll;
@property (nonatomic, strong) NSNumber  *followSpeedYaw;

@property (nonatomic, strong) NSNumber  *controlSpeedPitch;//控制速度
@property (nonatomic, strong) NSNumber  *controlSpeedRoll;
@property (nonatomic, strong) NSNumber  *controlSpeedYaw;

@property (nonatomic, strong) NSNumber  *smoothnessPitch;//平滑度
@property (nonatomic, strong) NSNumber  *smoothnessRoll;
@property (nonatomic, strong) NSNumber  *smoothnessYaw;

@property (nonatomic, strong) NSNumber  *trimmingPitch;//微调
@property (nonatomic, strong) NSNumber  *trimmingRoll;

@property (nonatomic, strong) NSNumber  *deadzonePitch;//死区
@property (nonatomic, strong) NSNumber  *deadzoneRoll;
@property (nonatomic, strong) NSNumber  *deadzoneYaw;

@property (nonatomic, strong) NSNumber  *controlDirectPitch;//遥控方向，只有yesOrNO
@property (nonatomic, strong) NSNumber  *controlDirectRoll;
@property (nonatomic, strong) NSNumber  *controlDirectYaw;

@property (nonatomic, copy)   NSString  *saveCustomName;

@property (nonatomic, strong) NSNumber  *contextualModel;//ZYEquipmentContextualModel类型

/**
 通过字典初始化

 @param dictionary 字典
 @return 模型对象
 */
+(ZYParaCustomSettingModel *)initWithDictionary:(NSDictionary *)dictionary;

/**
 根据情景模式类型创建模型类

 @param model ZYEquipmentContextualModel
 @return ZYParaCustomSettingModel
 */
+(ZYParaCustomSettingModel *)initWithZYEquipmentContextualModel:(ZYParaCustomSettingContextualModel)model;

/**
 saveName

 @param saveName saveName
 @return  模型
 */
+(ZYParaCustomSettingModel *)initWithZYEquipmentContextualModelCustomWithSaveName:(NSString *)saveName;
/**
 模型设置给稳定器

 @return 是否设置成功
 */
-(BOOL)setStablizer;


/**
 保存数据
 */
-(BOOL)saveToDisk;

/**
 更新数据
 */
-(BOOL)updateToDisk;

/**
 删除数据
 */
-(BOOL)deleteToDisk;

/**
 删除数据
 */
+(BOOL)deleteToDiskWithCustomModeName:(NSString *)customName;

/**
 保存的自定义设置的数组

 @return arrayName
 */
+(NSMutableArray *)saveCustomArrayName;

/**
 检查saveName是否存在

 @param saveName saveName
 @return 是否存在
 */
+(BOOL)checkSaveNameAvailable:(NSString *)saveName;

@end
