//
//  ZYOtheSynData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/6/1.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBlOtherSyncData.h"
#import "ZYBlRdisData.h"

extern NSString * _Nullable const ZYOtherSynDataRecived;//支持ZYOtheSynData对应的参数
extern NSString *_Nullable const ZYOtherSynDataRecivedTpyeKey;//支持ZYOtheSynData对应的参数的key
extern NSString *_Nullable const ZYOtherSynDataOneUpgradeOfTheWaitingNotifi;//升级进度的noti
extern NSString *_Nullable const ZYOtherSynDataOneStepCalibrationProgressNoti;//一键校准的进度通知

extern NSString *_Nullable const ZYOtherSynDataAutoTrackPositionNoti;//自动跟踪的位置

extern NSString *_Nullable const ZYOtherSynDataOneStoryProgressNoti;//story某个步骤完成的进度
extern NSString *_Nullable const ZYOtherSynDataMotorAutoProgressNoti;//电机自动调参进度


extern NSString *_Nullable const ZYOtherSynDataProgress;// =@"progress"
extern NSString *_Nullable const ZYOtherSynDataAutoTrackPositionX ;//X
extern NSString *_Nullable const ZYOtherSynDataAutoTrackPositionY ;//Y

NS_ASSUME_NONNULL_BEGIN

@interface ZYOtheSynData : NSObject

@property (nonatomic, copy) NSString *connectAccessory;//连接上了配件 0为未连接，1为连接上
@property (nonatomic, copy) NSString *imageBoxWorkMode;//0为从机，1为主机
@property (nonatomic, copy) NSString *offlineMoveProgress;//拍照的进度
@property (nonatomic, copy) NSString *upgradeProgress;//升级进度
@property (nonatomic, copy) NSString *oneStepCalibrationProgress;//一键校准的进度

@property (nonatomic, copy) NSString *storyProgress;//用0-100表示移动进度,103表示移动失败
@property (nonatomic, copy) NSString *autoTrackPosition;//x,y值 坐标定义参考跟踪配置, 任意坐标值为负数代表跟踪对象丢失
@property (nonatomic, copy) NSString *motorAutoProgress;//用0-100表示调参进度,103表示调参失败,30秒内完成


/**
 更新数据对象

 @param data data
 */
-(void)doUpdateValueWith:(ZYBlOtherSyncData *)data;

//图传盒子是从控设备
-(BOOL)imageBoxIsSubDevice;
@end

NS_ASSUME_NONNULL_END
