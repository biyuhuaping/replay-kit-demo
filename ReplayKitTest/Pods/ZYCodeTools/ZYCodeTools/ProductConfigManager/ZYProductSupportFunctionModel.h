//
//  ZYProductSupportFunctionModel.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/8/30.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 升级类型

 - UpdateTypeNoSupport: 不支持升级
 - UpdateTypeSupport: 支持
 - UpdateTypeCombine: 支持且支持多模块组合升级 (通过star软件版本获取版本号 可升级模块数获取模块信息 与服务器上的对比以判断是否升级)
 - UpdateTypeCombineModle    3:支持且支持多产品组合升级 (通过zybl json modules获取版本号及产品信息 与服务器上的对比以判断是否升级)
 */
typedef NS_ENUM(NSInteger, UpdateType) {
    UpdateTypeNoSupport = 0,
    UpdateTypeSupport = 1,
    UpdateTypeCombine = 2,
    UpdateTypeCombineModules = 3,
};

/**
 是否支持执行App发送的离线轨迹拍摄

 - MovelineTypeNoSupport: 不支持
 - MovelineTypeSupport: 支持轨迹
 - MovelineTypeSupportBle: 支持蓝牙
 - MovelineTypeSupportWifi: 支持WIFI
 */
typedef NS_ENUM(NSInteger, MovelineType) {
    MovelineTypeNoSupport = 0,
    MovelineTypeSupport = 1,
    MovelineTypeSupportBle = MovelineTypeSupport | 0x0010,
    MovelineTypeSupportWifi = MovelineTypeSupport | 0x0100,
};

/**
  支持App连接的方式

 - LinkTypeBleNormal: App以蓝牙主机的方式连上设备后,无其他特殊操作
 - LinkTypeBleAndWifi: App以蓝牙主机的方式连上设备后,断开蓝牙以WIFI从机的方式连上设备，比如weeibllLab
 - LinkTypeBleWifiSlave: App以蓝牙主机的方式连上设备后,控制设备以WIFI从机的方式连上其他WIFI主机设备，比如 CraneM2
 - LinkTypeWifiSlave: App以WIFI从机的方式连上设备后,无其他特殊操作，比如图传盒子
 - LinkTypeBleOrBleAndWifi:无WIFI配件时使用连接方式0, 有WIFI配件时使用连接方式1(Weebill S)
 */
typedef NS_ENUM(NSInteger, LinkType) {
    LinkTypeBleNormal = 0,
    LinkTypeBleAndWifi = 1,
    LinkTypeBleWifiSlave = 2,
    LinkTypeWifiSlave = 3,
    LinkTypeBleOrBleAndWifi = 4,
};
/**
 支持App连接的方式

- ActivateTypeNoSupport: 不支持激活
- ActivateTypeRandom: 需要AES加密激活字段，但随机字符串不验证
- ActivateTypeRandomVerify: 需要AES加密激活字段，同时验证随机字符串
*/

typedef NS_ENUM(NSInteger, ActivateType) {
    ActivateTypeNoSupport = 0,
    ActivateTypeRandom = 1,
    ActivateTypeRandomVerify = 2,
};

/**
 支持心跳

- Ble_hidTypeNoSupport: 不支持心跳
- Ble_hidTypeHeartWithHID: 支持心跳同时是HID设备
- Ble_hidTypeHeartWithNoHID: 支持心跳不是HID设备
 
*/
typedef NS_ENUM(NSInteger, Ble_hidType) {
    Ble_hidTypeNoSupport = 0,
    Ble_hidTypeHeartWithHID = 1,
    Ble_hidTypeHeartWithNoHID = 2,
};


NS_ASSUME_NONNULL_BEGIN

@interface ZYProductSupportFunctionModel : NSObject
//设备类型
@property (nonatomic)          NSUInteger         productIdNumber;//paraID


/**
 //电池节数 默认值为1
 */
@property (nonatomic)           NSUInteger      battery;

/**
 通过蓝牙传输的数据包最大长度(单位:字节)默认值为20
 默认为系统获取的最大值
 */
@property (nonatomic)           NSUInteger       bleMtu;

/**
 是否支持ccs指令
 默认为0:不支持
 1:支持
 */
@property (nonatomic)           BOOL       ccs;


/**
 是否支持App固件升级
 默认为0:不支持
 1:支持
 2:支持且支持多产品组合升级
 */
@property (nonatomic)           UpdateType       update;

/**
 是否支持体感指令
 默认为0:不支持
 1:支持
 */
@property (nonatomic)           BOOL       motionControl;

/**
 是否支持执行App发送拍照指令
 默认为0:不支持
      1:支持
 */
@property (nonatomic)           BOOL       photo;

/**
 是否支持执行App发送录像指令
 默认为0:不支持
 1:支持
 */
@property (nonatomic)           BOOL       video;

/**
 是否支持执行App发送录像指令
 默认为0:不支持
 1:支持
 */
@property (nonatomic)           BOOL       digitalZoom;


/**
 是否支持执行App发送的离线轨迹拍摄
 默认值0 不支持
 0x0001:支持轨迹
 0x0010:支持蓝牙
 0x0100:支持WIFI
 */
@property (nonatomic)           MovelineType       moveline;

/**
 是否传输获取数据配置指令
 默认为0:不支持
 1:支持
 */
@property (nonatomic)           BOOL       jsonData;

/**
 支持App连接的方式
 默认为0: App以蓝牙主机的方式连上设备后,无其他特殊操作
 1: App以蓝牙主机的方式连上设备后,断开蓝牙以WIFI从机的方式连上设备
 2: App以蓝牙主机的方式连上设备后,控制设备以WIFI从机的方式连上其他WIFI主机设备
 3: App以WIFI从机的方式连上设备后,无其他特殊操作
 */
@property (nonatomic)           LinkType       links;


/*
 <!--
 此设备是否支持切换搭载设备类型
 默认为0:不支持
 1:支持
 举例:Crane M2
 -->
 */
@property (nonatomic)           BOOL       carry;

/**
 <!--
 此设备是否支持蓝牙HID设备连接心跳指令
 默认为0:不支持
 1:支持
 举例:SMOOTH Q2支持蓝牙hid
 -->
 */
@property (nonatomic)           Ble_hidType       ble_hid;

/**
 是否支持新跟踪指令
 */
@property (nonatomic)           BOOL       tracking;

/**
 是否是OEM设备
 */
@property (nonatomic)           BOOL       oem;

/**
 此设备是否支持自适应调参
 默认为0:不支持
       1:支持
 举例:cr110 weebill s支持自适应调参
 */
@property (nonatomic)           BOOL       autotune;
/**
此设备是否支持wifi手动信道设置
默认为0:不支持
     1:支持
举例:cov-01支持手动信道设置
*/

@property (nonatomic)           BOOL       wifichannel;
/*
 此设备是否支持wifi station模式和ap模式切换
 默认为0:不支持
       1:支持
 举例:cov-01 支持station模式和ap模式切换
 */
@property (nonatomic)           BOOL       wifimodel;

/*
心跳检测使用指令
默认为0:检查系统状态
      1:心跳和系统出错状态
举例:smooth Q2 心跳和系统出错状态
*/
@property (nonatomic)           BOOL       bhTest;

/*
校准的检查方式
默认为0:六面校准
      1:一键校准
举例:smooth Q3 一键校准
*/
@property (nonatomic)           BOOL       calibration;


/*
支持的云台模式
默认为[0,1,2]航向跟随，锁定模式，全锁定模式
 举例:Weebill S 支持 航向跟随模式，锁定模式，全跟随模式，POV模式，疯狗模式，三维梦境

*/
@property (nonatomic)           NSArray       *gimbalMode;

/*
云台重置位置方式
默认为0:PF指令
      1:回中指令
举例:weebill S 支持回中方式
*/

@property (nonatomic)           BOOL       resetPosition;

/*
支持的云台模式
默认为[0,1,2,3] 不支持 佳能，sony 松下
*/
@property (nonatomic,strong)           NSArray       *cameraList;

/// 支持相机品牌设置
-(BOOL)supportCameraListSetting;

/*
是否需要校验激活
默认为0:不需要
    1:需要AES加密激活字段，但随机字符串不验证
    2:需要AES加密激活字段，同时验证随机字符串
      举例:Smooth q3 支持需要AES加密激活字段，但随机字符串不验证的激活方式

举例:smooth Q3  需要
*/
@property (nonatomic)           ActivateType       activate;

/*
<!--
    AES加密秘钥，当<activate>不为0时有效
    默认为{0xd0, 0x94, 0x3f, 0x8c, 0x29, 0x76, 0x15, 0xd8, 0x20, 0x40, 0xe3, 0x27, 0x45, 0xd8, 0x48, 0xad, 0xea, 0x8b, 0x2a, 0x73, 0x16, 0xe9, 0xb0, 0x49, 0x45, 0xb3, 0x39, 0x28, 0x0a, 0xc3, 0x28, 0x3c}
    举例:Smooth q3 支持需要AES加密激活字段，但随机字符串不验证的激活方式
 -->
*/
@property (nonatomic)           NSString      *activateAESkey;

// 十六进制转换为普通字符串的。
+(NSData *)convertHexStrToData:(NSString *)str;
//编码数据
-(NSData *)encodeEncrypt:(NSData *)encrpyData;
//解码数据
-(NSData *)decodeEncrypt:(NSData *)decrpyData;

/*
<!--
    智云设备识别码
    默认为:0905
 -->
*/
@property (nonatomic)           NSString*       identifier;

/*
<!--
    是否支持STORY模式
    默认为0:不支持
         1:支持
    举例:Smooth q3 支持STORY模式
 -->
*/
@property (nonatomic)           BOOL       storymode;

/*
<!--
    稳定器设备可动范围
    默认为:俯仰[-90,90]横滚[-45,45]航向[-180,180]
 -->
*/
@property (nonatomic,strong)           NSArray       *movelimit;
/*
<!--
可重定义键值列表
    默认为[]，列表为空
    当有自定义按键是按照如下格式[[键组,键值1,[事件1,事件2,事件3]],[键组,键值2,[事件1,事件2,事件3]]]
    举例:[[0,3,[3,6,7]],[0,11,[3,6]]]代表键组0内模式按键的单击双击三击可重定义，以及键组0内fn按键单击双击可重定义
 -->
*/
@property (nonatomic,strong)           NSArray       *keyredefine;

//电机力度的调整范围
@property (nonatomic,strong)           NSArray       *motorStrength;

//电机力度的调整范围
/*
 <!--
          此设备支持的电机力度自由设置
          *支持该功能的机型 App将显示相关页面
          轴依次为 俯仰 横滚 航向
          默认为[[0,0],[0,0],[0,0]]
          举例:云鹤2s 自定义电机力度
 -->
 */
@property (nonatomic,strong)           NSArray       *motorStrengthCustom;
/*
<!--
         此设备支持的电机力度自由设置
         *支持该功能的机型 App将显示相关页面
         0 不支持
         1 支持
         默认为0 不支持
         举例:云鹤2s 支持电机力度校准通知
-->
 */
@property (nonatomic)                  BOOL       motorStrengthAdjustNotify;





/*
 <!--
        此设备是否支持横竖拍切换
        *支持该功能的机型 App将显示相关页面
             0:不支持
             1:支持
        默认为[0]
        举例:Smooth X 设置方式
 -->
*/
@property (nonatomic)                  BOOL       hvswitch;
/*
 <!--
         此设备支持的摇杆速度设置方式
         *支持该功能的机型 App将显示相关页面
              -1:设置数值
               0:低
               1:中
               2:高
         默认为[-1]
         举例:Smooth X 设置方式
 -->

 */
@property (nonatomic)                  NSArray        *joystickspeed;
/*
 <!--
         此设备支持的情景模式
         *支持该功能的机型 App将显示相关页面
              -1:不支持云台上直接设置
               0:行走
               1:运动
         默认为[-1]
         举例:Smooth X 支持的方式
 -->

 */
@property (nonatomic)                  NSArray        *usrscene;

/*
 <!--
         此设备需要强制升级到特定版本以上
         *默认不需要
          
         举例:Smooth X 需要强制升级到特定版本
 -->

 */
@property (nonatomic)                  int       forceversion;
/*
<!--
   稳定器参数预设(稳定器上无对应值保存，仅存储在App上，只保存参数)
   参数项目依次为 跟随速率值 控制速率值 平滑度值 死区值
   轴依次为 俯仰 横滚 航向
   预设值依次为 行走 运动
   默认为:[
       [
           [80,25,100,2.0],
           [80,25,100,5.0],
           [80,45,100,5.0]
       ],
       [
           [120,100,200,2.0],
           [120,100,200,5.0],
           [120,100,200,5.0]
       ]
   ]
-->
*/
@property (nonatomic,strong)                  NSArray*       preset;

//行走
@property (nonatomic,strong,readonly)                  NSArray*       presetWalk;
//运动
@property (nonatomic,strong,readonly)                  NSArray*       presetMove;
/*
 
<!--
    STORY模式下的更多配置
    默认为
    {
        //坐标值精度,当前轴不运动的特殊值
        "precision":{
            "pitch":[0.01, 30000],
            "roll":[0.01, 30000],
            "yaw":[0.01, 30000],
        }
        //定点中是否支持结果通知
        "notify":false,
        //定点中是否支持时间设置
        "duration":false
    } //Smooth X 支持以上配置
    举例:直播云台 STORY模式下 yaw轴精度为0.1
 -->
 */
@property (nonatomic,strong)                   NSDictionary*       storyAtrribute;
@property (nonatomic,strong,readonly)          NSDictionary*       precision;
@property (nonatomic,readonly)          float       precisionPitch;
@property (nonatomic,readonly)          float       precisionRoll;
@property (nonatomic,readonly)          float       precisionYaw;

//支持position进度的通知
@property (nonatomic,readonly)          BOOL      notifySupportPosition;
//支持position的时间设置的
@property (nonatomic,readonly)          BOOL      durationSupportPosition;

/*
 <!--
   稳定器参数范围,参数项目依次为 跟随速率范围 控制速率范围 平滑度范围 死区范围
   轴依次为 俯仰 横滚 航向
   默认为:[
   [[0,120],[0,100],[0,200],[0,30]],
   [[0,120],[0,100],[0,200],[0,30]],
   [[0,120],[0,100],[0,200],[0,30]]
   ]
-->
 */
@property (nonatomic,strong)                  NSArray*       presetlimit;


/// 重定义键值列表
-(BOOL)supportKeyRedfineSetting;
/**
 通过字典初始化

 @param dic 字典
 @return 对象
 */
+ (ZYProductSupportFunctionModel *)functionModelWithDic:(NSDictionary *)dic;

/// 是否需要检查版本强制升级
-(BOOL)needAppForceUpgrade;
/// 判断某个版本 是否需要强制升级
-(BOOL)forceUpgradeWith:(NSString *)softVersion;


@end

NS_ASSUME_NONNULL_END
