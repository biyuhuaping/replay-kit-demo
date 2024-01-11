//
//  ZYBlOtherSyncData.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlData.h"
/*
 
 MSG_ID为0时表示主动通知，不为0时表示请求。
 idx(1字节)
 c_str(以'\0'结尾的字符串)
 如有多个值可以按顺序依次排列
 发送端可通过填入对应idx可主动请求对应值
 接受端收到后返回对应值
 接受端在值修改时需主动通知发送端
 idx定义如下
 |参数          |内容      |默认值  |参数值定义  |
 |:-----------:|:-------:|:-----:|:--------- |
 |0            |查询所有值  |""     ||
 |1            |smq2控制配件<br>是否连接 |无      |0：无连接 1：有连接|
 |2            |轨迹的当前进度   |无      |(0, INT_MAX]|
 |3            |云台模式   |0      |(0, INT_MAX]
 |4            |图传盒子(COV)工作模式 |无      |0：从机 1：主机|
 
 | 云台模式   |   值   |
 |:----------|:-------|
 | 航向跟随模式 |   0    |
 | 锁定模式模式 |   1    |
 | 全跟随模式   |   2    |
 | POV模式      |   3    |
 | 疯狗模式     |   4    |
 | 三维梦境     |   5    |
 */
typedef NS_ENUM(NSUInteger, ZYOtherSynDataCode) {
    ZYOtherSynDataCodeAll = 0,
    ZYOtherSynDataCodeConnectAccessory,//配件是否加载上了
    ZYOtherSynDataCodePath,//离线延时摄影的拍照进度，或者视频的进度
    ZYOtherSynDataCodeGambleMode,//云台模式
    ZYOtherSynDataCodeImageBoxWorkMode,//图传盒子的工作模式，0：从机 1:主机
    ZYOtherSynDataCodeUpgradeProgress,//升级进度 0 - 100
    ZYOtherSynDataOneStepCalibration,//一键校准的进度 0 - 100
    ZYOtherSynDataStoryProgress,//用0-100表示移动进度,103表示移动失败
    ZYOtherSynDataAutoTrackPosition,//x,y值 坐标定义参考跟踪配置, 任意坐标值为负数代表跟踪对象丢失
    ZYOtherSynDataMotorAutoProgress,//电机自动调参进度,用0-100表示调参进度,103表示调参失败,30秒内完成

};

NS_ASSUME_NONNULL_BEGIN
@interface CCSConfigSynItem : NSObject
/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger idx;
/**
 可用参数列表
 */
@property (nonatomic, readwrite) NSArray<NSString*>* itemLists;

@end


@interface ZYBlOtherSyncData : ZYBlData

/**
 参数项编号
 */
@property (nonatomic, readwrite) NSUInteger idx;


/**
 参数项编号,0为主动通知，其他的需要回应
 */
@property (nonatomic, readwrite) NSUInteger messageId;
/**
 可用参数列表
 */
@property (nonatomic, readonly, strong) NSArray<CCSConfigSynItem*>* configs;


@end

NS_ASSUME_NONNULL_END
