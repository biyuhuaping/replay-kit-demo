//
//  ZYBleWiFiManager.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/6/6.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYBlWiFiDeviceData.h"
#import "ZYBleWifiData.h"
#import "ZYBleDeviceClient.h"
#import "SPCCommandDefine.h"
#import "ZYSendRequest.h"



@interface ZYBleWiFiManager : NSObject

@property (nonatomic, weak)   id<ZYSendRequest> sendDelegate;
/*!
 将要连接的wifi
 
 */
@property (nonatomic, strong) NSString            *curSSID;
/*!
 gopro设备的数据模型
 */
@property (nonatomic, readonly) ZYBleWifiData  *wifiData;


/**
 只扫描包含在字符串数组里面的内容 gopro 识别为@"GP"
 */
@property (nonatomic, strong) NSMutableArray   *scanWifiNames;
/*！
 扫描Wi-Fi设备

 @param bleStatusHandler 扫描时候的回掉
 @param deviceHandler 扫描到设备之后的回掉
 */
-(void)scanWiFiDevice:(void (^)(ZYWiFiScanState state))scanStatusHandler deviceHandler:(void (^)(NSArray * deviceArray))devicesHandler;

/**
 获取Wi-Fi是否连接

 @param workState 稳定器的状态
 */
-(void)checkWifiDeviceStateWithWorkState:(int)workState;

// 检测是否在已连接状态
- (void)queryWifiIsIsConnected:(void(^)(BOOL isConnected))handler;
- (void)queryWifiIsIsConnectedWithTimeout:(void(^)(BOOL isConnected, BOOL isTimeout))handler;
/*!
 停止Wi-Fi扫描
 
 */
-(void)stopScan;

-(void)queryAllParamData;

-(NSInteger)querySpecificConfigParaWith:(WiFiMain_mode)main_mode;
/*!
 连接设备

 @param ssid Wi-Fi名字
 @param pwd Wi-Fi秘密
 @param connentStateHandler 连接状态
 */
-(void)connectionWifiWithSSID:(NSString *)ssid password:(NSString *)pwd connectState:(void (^)(ZYWiFiConnentState state))connentStateHandler;
/*!
  断开连接
 
 */
-(void)disConnectWifiWithConnectState:(void (^)(ZYWiFiConnentState state))connentStateHandler;

/**
 清除设备

 @param ssid 设备ssid
 */
-(void)cleanSSID:(NSString *)ssid;
/**
 设置主模式

 @param main_mode WiFiMain_mode
 @param handler 设置的回掉
 */
-(void)setMainModeWithType:(WiFiMain_mode)main_mode completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;


/**
 设置主模式
 
 @param main_mode WiFiMain_mode
 @param subType 子模式
 @param handler 设置的回掉
 */
-(void)setMainModeWithType:(WiFiMain_mode)main_mode subType:(NSUInteger)subType completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;

/**
 录制视频

 @param shutter 视频录制
 @param handler 回掉
 */
-(void)shutter:(bool)shutter completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;

/**
 清除数据
 */
-(void)clearData;


/**
 激活某一条设置

 @param catagory 分类名
 @param name 激活参数的名字
 @param handler 回调
 */
//- (void)activationCatagory:(NSString *)catagory name:(NSString *)name completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;
- (void)activationCatagoryCode:(NSInteger)queryCode content:(NSString *)name completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;
/**
 激活某一条设置

 @param number 参数序号
 @param value 参数值
 @param handler 回调
 */
- (void)activationSerialNumber:(NSUInteger)number value:(NSUInteger)value completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;


/**
 获取当前分类的设置值

 @param queryCode 分类的查询值
 @return 分类的设置值
 */
- (NSString *)obtainCurrentNameWithQueryCode:(NSInteger)queryCode;


/**
 获取分类的支持列表

 @param queryCode 分类的查询值
 @return 分类的查询码
 */
- (NSArray *)obtainTitlesUsingQueryCode:(NSInteger)queryCode;

- (void)changeMode:(WiFiMode)wifiMode completionHandler:(void(^)(ZYBleDeviceRequestState state, id param))handler;



@end
