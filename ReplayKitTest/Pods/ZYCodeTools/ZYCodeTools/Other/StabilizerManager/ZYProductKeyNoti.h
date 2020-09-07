//
//  ZYProductKeyNoti.h
//  ZYCamera
//
//  Created by Liao GJ on 2018/8/27.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 录像按钮通知，不带参数
 */
extern NSString * const Device_Gropup0_Record_Notification ;
/**
 拍照按钮通知，不带参数
 */
extern NSString * const Device_Gropup0_Capture_Notification;
/**
 拍照PhotoDoubleClick双击
 */
extern NSString * const Device_Gropup0_PhotoDoubleClick_Notification;
/**
拍照三击
*/
extern NSString * const Device_Gropup0_PhotoTripleClick_Notification;
/**
拍照单击
*/
extern NSString * const Device_Gropup0_PhotoSingleClick_Notification;

/**
拍照三击
*/
extern NSString * const Device_Gropup0_New_PhotoTripleClick_Notification ;
/**
拍照PhotoDoubleClick双击
*/
extern NSString * const Device_Gropup0_New_PhotoDoubleClick_Notification ;
/**
拍照单击
*/
extern NSString * const Device_Gropup0_New_PhotoSingleClick_Notification ;


/**
mode三击
*/
extern NSString * const Device_Gropup0_ModeTripleClick_Notification;
/**
mode双击
*/
extern NSString * const Device_Gropup0_ModeDoubleClick_Notification;
/**
mode单击
*/
extern NSString * const Device_Gropup0_ModeSingleClick_Notification;

/**
Gropup0 左右上下
*/
extern NSString * const Device_Gropup0_LeftClick_Notification;
extern NSString * const Device_Gropup0_RightClick_Notification;
extern NSString * const Device_Gropup0_UpClick_Notification;
extern NSString * const Device_Gropup0_DownClick_Notification;

/**
 拍照按钮通知，不带参数
 */
extern NSString * const Device_TakePhoto_Notification;

/**
 T拨杆拉动通知，不带参数
 */
extern NSString * const Device_TLeverClick_Notification;

/**
 T拨杆长按通知，不带参数
 */
extern NSString * const Device_TLeverLongPressed_Notification;

/**
 T拨杆长按释放通知，不带参数
 */
extern NSString * const Device_TLeverLongRelease_Notification;
/**
 T拨杆按下
 */
extern NSString * const Device_TPress_Notification;
/**
 T拨杆释放
 */
extern NSString * const Device_TRelease_Notification;
/**
 W拨杆拉动通知，不带参数
 */
extern NSString * const Device_WLeverClickt_Notification;


/**
 W拨杆长按通知，不带参数
 */
extern NSString * const Device_WLeverLongPressed_Notification;

/**
 W拨杆长按释放通知，不带参数
 */
extern NSString * const Device_WLeverLongRelease_Notification ;

/**
 W拨杆按下
 */
extern NSString * const Device_WPress_Notification;
/**
 T拨杆释放
 */
extern NSString * const Device_WRelease_Notification;

/**
 电池改变通知 带参数： userinfo: @{@"KEY":@(float)} 取值范围0~100，-1为无效值
 */
extern NSString* const Device_BatteryDidChange_Notification  ;
/**
//电池的状态已经改变了，充电中等userinfo: @{@"valueType":@(int)} 取值范围typedef NS_ENUM(NSInteger,batteryValueType) {
    batteryValueTypeAvailable = 0,
    batteryValueTypeCharging,//充电中
    batteryValueTypeUnsupport,//不支持
};
  */
extern NSString * const Device_BatteryTypeDidChange_Notification;
/*
> 错误状态字段具体定义:
> | bit7 | bit6 | bit5 | bit4 | bit3 | bit2 | bit1 | bit0 |
> | :--- |:--- |:--- |:--- |:--- |:--- |:--- |:--- |:--- |
> | axislock | overheat | -- | -- | -- | -- | -- | -- |
> |轴锁|过热|

*/

extern NSString * const Device_ErrorTypeDidChange_Notification;

/**
 工作状态改变通知 带参数： userinfo: @{@"KEY":@(int)} 取值范围0~2，-1为无效值
 */
extern NSString* const Device_WorkModeDidChange_Notification  ;


#pragma mark - Smooth3
/**
 Smooth3，拍照（单击），不带参数
 */
extern NSString * const Device_Smooth3_TakePhoto_Notification ;

/**
 Smooth3，双击，不带参数
 */
extern NSString * const Device_Smooth3_DoubleClick_Notification ;
/**
 Smooth3，FN键（单击），不带参数
 */
extern NSString * const Device_Smooth3_FunClick_Notification ;

/**
 Smooth3，FJ键（长按1秒），不带参数
 */
extern NSString * const Device_Smooth3_FunLongPressed_Notification ;

/**
 Smooth3，CW，不带参数
 */
extern NSString * const Device_Smooth3_CW_Notification ;

/**
 Smooth3，CWW，不带参数
 */
extern NSString * const Device_Smooth3_CCW_Notification ;

#pragma mark - Smooth 4

/**
 Smooth 4，菜单，不带参数
 */
extern NSString * const Device_Smooth4_Menu_Notification  ;

/**
 Smooth 4，菜单，长按1秒,不带参数
 */
extern NSString * const Device_Smooth4_Menu_PRESSED_1S_Notification ;

/**
 Smooth 4，DISP按键，不带参数
 */
extern NSString * const Device_Smooth4_Disp_Notification ;

/**
 Smooth 4，DISP按键，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Disp_PRESSED_1S_Notification ;


/**
 Smooth 4，拨轮上，不带参数
 */
extern NSString * const Device_Smooth4_Up_Notification ;

/**
 Smooth 4，拨轮上，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Up_PRESSED_1S_Notification ;

/**
 Smooth 4，拨轮下，不带参数
 */
extern NSString * const Device_Smooth4_Down_Notification ;

/**
 Smooth 4，拨轮下，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Down_PRESSED_1S_Notification ;

/**
 Smooth 4，拨轮右，不带参数
 */
extern NSString * const Device_Smooth4_Right_Notification ;

/**
 Smooth 4，拨轮右，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Right_PRESSED_1S_Notification ;

/**
 Smooth 4，拨轮左，不带参数
 */
extern NSString * const Device_Smooth4_Left_Notification ;

/**
 Smooth 4，拨轮左，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Left_PRESSED_1S_Notification ;


/**
 Smooth 4，中键，闪光灯，不带参数
 */
extern NSString * const Device_Smooth4_Flash_Notification ;

/**
 Smooth 4，中键，闪光灯，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Flash_PRESSED_1S_Notification ;

/**
 Smooth 4，拨轮功能切换，不带参数
 */
extern NSString * const Device_Smooth4_Switch_Notification ;

/**
 Smooth 4，拨轮功能切换，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Switch_PRESSED_1S_Notification ;

/**
 Smooth 4
 */
extern NSString * const Device_Smooth4_Step_B_Notification ;

/**
 Smooth 4，录像，不带参数
 */
extern NSString * const Device_Smooth4_Record_Notification;

/**
 Smooth 4，录像，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Record_PRESSED_1S_Notification ;



/**
 Smooth 4，拍照模式，不带参数
 */
extern NSString * const Device_Smooth4_Photos_Mode_Notification ;

/**
 Smooth 4，拍照模式，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Photos_Mode_PRESSED_1S_Notification ;

/**
 Smooth 4，拍照，不带参数
 */
extern NSString * const Device_Smooth4_Photos_Notification ;

/**
 Smooth 4，拍照，长按1秒，不带参数
 */
extern NSString * const Device_Smooth4_Photos_PRESSED_1S_Notification ;

/**
 Smooth 4，前拨轮+(顺时针)，不带参数
 */
extern NSString * const Device_Smooth4_Front_CW_Notification ;

/**
 Smooth 4，后拨轮-(逆时针)，不带参数
 */
extern NSString * const Device_Smooth4_Front_CCW_Notification ;

/**
 Smooth 4，侧拨轮+(顺时针)，不带参数
 */
extern NSString * const Device_Smooth4_Side_CW_Notification ;

/**
 Smooth 4，侧拨轮-(逆时针)，不带参数
 */
extern NSString * const Device_Smooth4_Side_CCW_Notification ;

/**
 Smooth 4，对焦变焦模式
 */
extern NSString * const Device_Smooth_FocusMode_Notification ;

//Device_Smooth4_Left_Notification


// MARK: - 键组 4事件

/**
 通用通知
 用法： 当检测到到键组4中的事件时，在userinfo中添加指令模型字典发送此通知，由上层根据指令字典去自己解析事件
 */
extern NSString *const ZY_KeysActionGroup4th_Common_Notification;

// 通用的指令通知
extern NSString *const ZY_KeysActionAll_Notification;

// 菜单
extern NSString *const ZY_KeysActionGroup4th_Menu_Notification;
// 上
extern NSString *const ZY_KeysActionGroup4th_Up_Notification;
// 下
extern NSString *const ZY_KeysActionGroup4th_Down_Notification;
//下 双击
extern NSString *const ZY_KeysActionGroup4th_Down_DoubleClick_Notification;
// 右
extern NSString *const ZY_KeysActionGroup4th_Right_Notification;
// 左
extern NSString *const ZY_KeysActionGroup4th_Left_Notification;
// 拨杆T（长焦端）
extern NSString *const ZY_KeysActionGroup4th_Lever_T_Notification;
//拨杆T（长焦端）释放
extern NSString *const ZY_KeysActionGroup4th_Lever_T_Release_Notification;
// 拨杆W
extern NSString *const ZY_KeysActionGroup4th_Lever_W_Notification;
// 拨杆W释放
extern NSString *const ZY_KeysActionGroup4th_Lever_W_Release_Notification;
// 录像/拍照（单击）
extern NSString *const ZY_KeysActionGroup4th_TAKEPIC_Single_Notification;
// 切换拍照/录像（双击）
extern NSString *const ZY_KeysActionGroup4th_TAKEPIC_Double_Notification;
// 切换前后摄像头（三击）
extern NSString *const ZY_KeysActionGroup4th_TAKEPIC_Triple_Notification;
//长按开始
extern NSString *const ZY_KeysActionGroup4th_TAKEPIC_LongTouchUp_Notification;
//长按结束
extern NSString *const ZY_KeysActionGroup4th_TAKEPIC_LongTouchDown_Notification;
// 拨轮+(顺时针)
extern NSString *const ZY_KeysActionGroup4th_WHEEL_CLOCKWISE_Notification;
// 后拨轮-(逆时针)
extern NSString *const ZY_KeysActionGroup4th_WHEEL_ANTICLOCKWISE_Notification;
// 变焦+(顺时针
extern NSString *const ZY_KeysActionGroup4th_ZOOM_UP_Notification;
// 变焦-(逆时针)
extern NSString *const ZY_KeysActionGroup4th_ZOOM_DOWN_Notification;
// 对焦+(顺时针)
extern NSString *const ZY_KeysActionGroup4th_FOCUS_UP_Notification;
// 对焦-(逆时针)
extern NSString *const ZY_KeysActionGroup4th_FOCUS_DOWN_Notification;



@interface ZYProductKeyNoti : NSObject
/**
 序列号 | 型号
 */
@property(nonatomic, copy)NSString *modelNumberString;

@end


// 按键触发事件类型
typedef NS_ENUM(NSUInteger, ZY_KeysActionEventType) {
    ZY_KeysActionEventTypeNone                   = 0,          // 空值事件
    ZY_KeysActionEventTypeTouchDown              = 0x10,       // 按下
    ZY_KeysActionEventTypeTouchUp                = 0x20,       // 释放
    ZY_KeysActionEventTypeClick                  = 0x30,       // 单击
    ZY_KeysActionEventTypeLongPressSecond1s      = 0x40,       // 长按1s
    ZY_KeysActionEventTypeLongPressSecond3s      = 0x50,       // 长按3s
    ZY_KeysActionEventTypeClickDouble            = 0x60,       // 双击
    ZY_KeysActionEventTypeClickTriple            = 0x70,       // 三击
};

// 按键键组类型
typedef NS_ENUM(NSUInteger, ZY_KeysActionGroup) {
    ZY_KeysActionGroupZero                      = 0,            // 空键组值  （CR106m， Smooth3， Smooth2 / SmoothQ）
    ZY_KeysActionGroup1st                       = 0x0100,       // 键组1
    ZY_KeysActionGroup2nd                       = 0x0200,       // 键组2      （Smooth4）
    ZY_KeysActionGroup3rd                       = 0x0300,       // 键组3
    ZY_KeysActionGroup4th                       = 0x0400,       // 键组4      （Smoothq2）
};


// 事件模型，抽象接收到的指令模型
@interface ZYKeysAction : NSObject

///**
// bit14-12  key_type  按键类型
// */
//@property (nonatomic, assign) NSUInteger actionType;

/**
 bit11-8  key_group  按键键组
 */
@property (nonatomic, assign) ZY_KeysActionGroup actionGroup;

/**
 bit7-4   key_event  按键事件
 */
@property (nonatomic, assign) ZY_KeysActionEventType actionEvent;

/**
 bit3-0  key_value   按键值
 */
@property (nonatomic, assign) NSUInteger actionValue;

/**
 事件名称
 */
@property (nonatomic, copy) NSString *actionName;

/**
 事件描述
 */
@property (nonatomic, copy) NSString *actionDescription;

//
///**
// 拓展字段
// */
//@property (nonatomic, copy) NSString *actionExtra;

/**
 事件回调的通知
 */
@property (nonatomic, copy) NSString *actionResponseNotify;


/// 通过字典初始化
/// @param dic 字典
+(instancetype)actionWithDiction:(NSDictionary *)dic;

//转字典
-(NSMutableDictionary *)toDictionary;

@end
