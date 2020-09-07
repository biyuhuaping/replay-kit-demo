//
//  ZYRdisData.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYControlData.h"

@interface ZYRdisData : ZYControlData

/// 图传盒子是否连接上
@property(nonatomic, readonly) BOOL imageBoxConnecting;

/**
 工作模式
 */
@property(nonatomic, readonly) ZYBleDeviceWorkMode workMode;

/**
 外置跟焦器连接 NO:未连接 YES:连接
 */
@property(nonatomic, readonly) BOOL followFocus;

/**
 外置变焦器连接 NO:未连接 YES:连接
 */
@property(nonatomic, readonly) BOOL zoom;

/**
 工作状态 NO:云台电机待机 YES:云台电机工作
 
 */
@property(nonatomic, readonly) BOOL workStatus;

/**
 相机录像标志 NO:未有录像 YES:录像中
 */
@property(nonatomic, readonly) BOOL isRecording;

/**
 相机开启实时预览标志 NO:未预览 YES:开启预览
 */
@property(nonatomic, readonly) BOOL isLiving;

/**
 相机已连接标志 NO:未连接 YES:已连接
 */
@property(nonatomic, readonly) BOOL isConnectiong;

-(void) setRawData:(void*)data freeWhenDone:(BOOL)free;

@end
