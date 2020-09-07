//
//  ZYProductKeyNoti.m
//  ZYCamera
//
//  Created by Liao GJ on 2018/8/27.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ZYStablizerDefineENUM.h"

#pragma mark 云台

NSString * const Device_TakePhoto_Notification            = @"Device_TakePhoto_Notification";
NSString * const Device_Gropup0_Record_Notification       = @"Device_Gropup0_Record_Notification";
NSString * const Device_Gropup0_Capture_Notification       = @"Device_Gropup0_Capture_Notification";
NSString * const Device_Gropup0_PhotoTripleClick_Notification       = @"Device_Gropup0_PhotoTripleClick_Notification";
NSString * const Device_Gropup0_PhotoDoubleClick_Notification       = @"Device_Gropup0_PhotoDoubleClick_Notification";
NSString * const Device_Gropup0_PhotoSingleClick_Notification       = @"Device_Gropup0_PhotoSingleClick_Notification";


NSString * const Device_Gropup0_New_PhotoTripleClick_Notification  = @"Device_Gropup0_New_PhotoTripleClick_Notification";
NSString * const Device_Gropup0_New_PhotoDoubleClick_Notification  = @"Device_Gropup0_New_PhotoDoubleClick_Notification";
NSString * const Device_Gropup0_New_PhotoSingleClick_Notification  = @"Device_Gropup0_New_PhotoSingleClick_Notification";



NSString * const Device_Gropup0_ModeTripleClick_Notification       = @"Device_Gropup0_ModeTripleClick_Notification";
NSString * const Device_Gropup0_ModeDoubleClick_Notification       = @"Device_Gropup0_ModeDoubleClick_Notification";
NSString * const Device_Gropup0_ModeSingleClick_Notification       = @"Device_Gropup0_ModeSingleClick_Notification";

NSString * const Device_Gropup0_LeftClick_Notification             = @"Device_Gropup0_LeftClick_Notification";
NSString * const Device_Gropup0_RightClick_Notification            = @"Device_Gropup0_RightClick_Notification";
NSString * const Device_Gropup0_UpClick_Notification               = @"Device_Gropup0_UpClick_Notification";
NSString * const Device_Gropup0_DownClick_Notification             = @"Device_Gropup0_DownClick_Notification";



NSString * const Device_TLeverClick_Notification          = @"Device_TLeverClick_Notification";
NSString * const Device_TLeverLongPressed_Notification    = @"Device_TLeverLongPressed_Notification";
NSString * const Device_TLeverLongRelease_Notification    = @"Device_TLeverLongRelease_Notification";
NSString * const Device_TPress_Notification    = @"Device_TPress_Notification";
NSString * const Device_TRelease_Notification    = @"Device_TRelease_Notification";

NSString * const Device_WLeverClickt_Notification         = @"Device_WLeverClickt_Notification";
NSString * const Device_WLeverLongPressed_Notification    = @"Device_WLeverLongPressed_Notification";
NSString * const Device_WLeverLongRelease_Notification    = @"Device_WLeverLongRelease_Notification";
NSString * const Device_WPress_Notification    = @"Device_WPress_Notification";
NSString * const Device_WRelease_Notification    = @"Device_WRelease_Notification";


NSString * const Device_ErrorTypeDidChange_Notification     = @"Device_ErrorTypeDidChange_Notification";
NSString * const Device_BatteryTypeDidChange_Notification     = @"Device_BatteryTypeDidChange_Notification";
NSString * const Device_BatteryDidChange_Notification     = @"Device_BatteryDidChange_Notification";
NSString * const Device_WorkModeDidChange_Notification    = @"Device_WorkModeDidChange_Notification";


//

//
#pragma mark - Smooth3
/**
 Smooth3，拍照（单击），不带参数
 */
NSString * const Device_Smooth3_TakePhoto_Notification      = @"Device_Smooth3_TakePhoto_Notification";

/**
 Smooth3，双击，不带参数
 */
NSString * const Device_Smooth3_DoubleClick_Notification    = @"Device_Smooth3_DoubleClick_Notification";
/**
 Smooth3，FN键（单击），不带参数
 */
NSString * const Device_Smooth3_FunClick_Notification       = @"Device_Smooth3_FunClick_Notification";

/**
 Smooth3，FJ键（长按1秒），不带参数
 */
NSString * const Device_Smooth3_FunLongPressed_Notification = @"Device_Smooth3_FunLongPressed_Notification";

/**
 Smooth3，CW，不带参数
 */
NSString * const Device_Smooth3_CW_Notification             = @"Device_Smooth3_CW_Notification";

/**
 Smooth3，CWW，不带参数
 */
NSString * const Device_Smooth3_CCW_Notification            = @"Device_Smooth3_CCW_Notification";

#pragma mark - Smooth 4

/**
 Smooth 4，菜单，不带参数
 */
NSString * const Device_Smooth4_Menu_Notification        = @"Device_Smooth4_Menu_Notification";

/**
 Smooth 4，菜单，长按1秒,不带参数
 */
NSString * const Device_Smooth4_Menu_PRESSED_1S_Notification        = @"Device_Smooth4_Menu_PRESSED_1S_Notification";

/**
 Smooth 4，DISP按键，不带参数
 */
NSString * const Device_Smooth4_Disp_Notification = @"Device_Smooth4_Disp_Notification";

/**
 Smooth 4，DISP按键，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Disp_PRESSED_1S_Notification = @"Device_Smooth4_Disp_PRESSED_1S_Notification";


/**
 Smooth 4，拨轮上，不带参数
 */
NSString * const Device_Smooth4_Up_Notification = @"Device_Smooth4_Up_Notification";

/**
 Smooth 4，拨轮上，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Up_PRESSED_1S_Notification = @"Device_Smooth4_Up_PRESSED_1S_Notification";

/**
 Smooth 4，拨轮下，不带参数
 */
NSString * const Device_Smooth4_Down_Notification = @"Device_Smooth4_Down_Notification";

/**
 Smooth 4，拨轮下，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Down_PRESSED_1S_Notification = @"Device_Smooth4_Down_PRESSED_1S_Notification";

/**
 Smooth 4，拨轮右，不带参数
 */
NSString * const Device_Smooth4_Right_Notification = @"Device_Smooth4_Right_Notification";

/**
 Smooth 4，拨轮右，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Right_PRESSED_1S_Notification = @"Device_Smooth4_Right_PRESSED_1S_Notification";

/**
 Smooth 4，拨轮左，不带参数
 */
NSString * const Device_Smooth4_Left_Notification = @"Device_Smooth4_Left_Notification";

/**
 Smooth 4，拨轮左，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Left_PRESSED_1S_Notification = @"Device_Smooth4_Left_PRESSED_1S_Notification";


/**
 Smooth 4，中键，闪光灯，不带参数
 */
NSString * const Device_Smooth4_Flash_Notification = @"Device_Smooth4_Flash_Notification";

/**
 Smooth 4，中键，闪光灯，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Flash_PRESSED_1S_Notification = @"Device_Smooth4_Flash_PRESSED_1S_Notification";

/**
 Smooth 4，拨轮功能切换，不带参数
 */
NSString * const Device_Smooth4_Switch_Notification = @"Device_Smooth4_Switch_Notification";

/**
 Smooth 4，拨轮功能切换，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Switch_PRESSED_1S_Notification = @"Device_Smooth4_Switch_PRESSED_1S_Notification";

/**
 Smooth 4
 */
NSString * const Device_Smooth4_Step_B_Notification = @"Device_Smooth4_Step_B_Notification";

/**
 Smooth 4，录像，不带参数
 */
NSString * const Device_Smooth4_Record_Notification = @"Device_Smooth4_Record_Notification";

/**
 Smooth 4，录像，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Record_PRESSED_1S_Notification = @"Device_Smooth4_Record_PRESSED_1S_Notification";



/**
 Smooth 4，拍照模式，不带参数
 */
NSString * const Device_Smooth4_Photos_Mode_Notification = @"Device_Smooth4_Photos_Mode_Notification";

/**
 Smooth 4，拍照模式，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Photos_Mode_PRESSED_1S_Notification = @"Device_Smooth4_Photos_Mode_PRESSED_1S_Notification";

/**
 Smooth 4，拍照，不带参数
 */
NSString * const Device_Smooth4_Photos_Notification = @"Device_Smooth4_Photos_Notification";

/**
 Smooth 4，拍照，长按1秒，不带参数
 */
NSString * const Device_Smooth4_Photos_PRESSED_1S_Notification = @"Device_Smooth4_Photos_PRESSED_1S_Notification";

/**
 Smooth 4，前拨轮+(顺时针)，不带参数
 */
NSString * const Device_Smooth4_Front_CW_Notification = @"Device_Smooth4_Front_CW_Notification";

/**
 Smooth 4，后拨轮-(逆时针)，不带参数
 */
NSString * const Device_Smooth4_Front_CCW_Notification = @"Device_Smooth4_Front_CCW_Notification";

/**
 Smooth 4，侧拨轮+(顺时针)，不带参数
 */
NSString * const Device_Smooth4_Side_CW_Notification = @"Device_Smooth4_Side_CW_Notification";

/**
 Smooth 4，侧拨轮-(逆时针)，不带参数
 */
NSString * const Device_Smooth4_Side_CCW_Notification = @"Device_Smooth4_Side_CCW_Notification";

/**
 Smooth 4，对焦变焦模式
 */
NSString * const Device_Smooth_FocusMode_Notification = @"Device_Smooth_FocusMode_Notification";



// MARK: - 键组 4事件

/**
 通用通知
 用法： 当检测到到键组4中的事件时，在userinfo中添加指令模型字典发送此通知，由上层根据指令字典去自己解析事件
 */
NSString *const ZY_KeysActionGroup4th_Common_Notification = @"ZY_KeysActionGroup4th_Common_Notification";

NSString *const ZY_KeysActionAll_Notification = @"ZY_KeysActionAll_Notification";

// 菜单
NSString *const ZY_KeysActionGroup4th_Menu_Notification = @"ZY_KeysActionGroup4th_Menu_Notification";
// 上
NSString *const ZY_KeysActionGroup4th_Up_Notification = @"ZY_KeysActionGroup4th_Up_Notification";
// 下
NSString *const ZY_KeysActionGroup4th_Down_Notification = @"ZY_KeysActionGroup4th_Down_Notification";
NSString *const ZY_KeysActionGroup4th_Down_DoubleClick_Notification = @"ZY_KeysActionGroup4th_Down_DoubleClick_Notification";//双击
// 右
NSString *const ZY_KeysActionGroup4th_Right_Notification = @"ZY_KeysActionGroup4th_Right_Notification";
// 左
NSString *const ZY_KeysActionGroup4th_Left_Notification = @"ZY_KeysActionGroup4th_Left_Notification";
// 拨杆T（长焦端）
NSString *const ZY_KeysActionGroup4th_Lever_T_Notification = @"ZY_KeysActionGroup4th_Lever_T_Notification";
NSString *const ZY_KeysActionGroup4th_Lever_T_Release_Notification = @"ZY_KeysActionGroup4th_Lever_T_Release_Notification";

// 拨杆W
NSString *const ZY_KeysActionGroup4th_Lever_W_Notification = @"ZY_KeysActionGroup4th_Lever_W_Notification";
NSString *const ZY_KeysActionGroup4th_Lever_W_Release_Notification = @"ZY_KeysActionGroup4th_Lever_W_Release_Notification";
// 录像/拍照
NSString *const ZY_KeysActionGroup4th_TAKEPIC_Single_Notification = @"ZY_KeysActionGroup4th_TAKEPIC_Single_Notification";
// 切换拍照/录像
NSString *const ZY_KeysActionGroup4th_TAKEPIC_Double_Notification = @"ZY_KeysActionGroup4th_TAKEPIC_Double_Notification";
// 切换前后摄像头
NSString *const ZY_KeysActionGroup4th_TAKEPIC_Triple_Notification = @"ZY_KeysActionGroup4th_TAKEPIC_Triple_Notification";
//长按开始
NSString *const ZY_KeysActionGroup4th_TAKEPIC_LongTouchUp_Notification = @"ZY_KeysActionGroup4th_TAKEPIC_LongTouchUp_Notification";
//长按结束
NSString *const ZY_KeysActionGroup4th_TAKEPIC_LongTouchDown_Notification = @"ZY_KeysActionGroup4th_TAKEPIC_LongTouchDown_Notification";

// 拨轮+(顺时针)
NSString *const ZY_KeysActionGroup4th_WHEEL_CLOCKWISE_Notification = @"ZY_KeysActionGroup4th_WHEEL_CLOCKWISE_Notification";
// 后拨轮-(逆时针)
NSString *const ZY_KeysActionGroup4th_WHEEL_ANTICLOCKWISE_Notification = @"ZY_KeysActionGroup4th_WHEEL_ANTICLOCKWISE_Notification";
// 变焦+(顺时针
NSString *const ZY_KeysActionGroup4th_ZOOM_UP_Notification = @"ZY_KeysActionGroup4th_ZOOM_UP_Notification";
// 变焦-(逆时针)
NSString *const ZY_KeysActionGroup4th_ZOOM_DOWN_Notification = @"ZY_KeysActionGroup4th_ZOOM_DOWN_Notification";
// 对焦+(顺时针)
NSString *const ZY_KeysActionGroup4th_FOCUS_UP_Notification = @"ZY_KeysActionGroup4th_FOCUS_UP_Notification";
// 对焦-(逆时针)
NSString *const ZY_KeysActionGroup4th_FOCUS_DOWN_Notification = @"ZY_KeysActionGroup4th_FOCUS_DOWN_Notification";


#import "ZYProductKeyNoti.h"
#import "ZYBleProtocol.h"
#import "ZYBleDeviceDataModel.h"
#import "ZYProductKeyNoti+ActionInfo.h"

@interface ZYProductKeyNoti()
@property (nonatomic, strong)   NSMutableDictionary *dicKeyS;//用于按键开始的时间
@property(nonatomic, strong)    NSDate *clickDate;
@property(nonatomic, assign)int temp ;//用于记录双击

@end

@implementation ZYProductKeyNoti
-(void)dealloc{
#ifdef DEBUG
    
    NSLog(@"%@",[self class]);
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Device_Button_Event_Notification_ResourceData object:nil];
 
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
         [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buttonNotification:) name:Device_Button_Event_Notification_ResourceData object:nil];

    }
    return self;
}

-(NSMutableDictionary *)dicKeyS{
    if (_dicKeyS == nil) {
        _dicKeyS = [[NSMutableDictionary alloc] init];
    }
    return _dicKeyS;
}

#pragma mark - notificaiotn
-(void)buttonNotification:(NSNotification *)notify{
    
    //    if (self.workingState != 1) {
    //        return;
    //    }
    //    NSLog(@"%@ xxx %s",self.deviceInfo.name,__func__);
#pragma mark - 提取之前存在，现在应该不需要了
    /*
     
     if (![[ZYBleDeviceClient defaultClient].curDeviceInfo.name isEqualToString:self.deviceInfo.name]) {
     return;
     }
     */
    //    NSLog(@"%@ xxx %s",self.deviceInfo.name,__func__);
    
    NSNumber *data = [notify.userInfo objectForKey:@"KEY"];
    
    NSUInteger param = data.unsignedIntegerValue;
    /**
     键组4之后开始使用
     在指令集合中，尝试筛选符合该值指令，若存在符合条件的指令（即数组元素个数不为0），则发送至上层，此处通知统一在 userInfo 中附带指令的字典模型，由上层去解析指令的具体信息
     */
    NSLog(@"%d",param);
    NSArray <ZYKeysAction *>*actionArray = [ZYProductKeyNoti filterActionArray:param sourceArray:[ZYProductKeyNoti group4ThActionInfo]];
    if (actionArray && (actionArray.count > 0)) {
        ZYKeysAction *actonInfo = actionArray.firstObject;
        
        NSLog(@"筛选后指令数组：%@", actionArray);
//        [self postNotiWithPara:param andNotiName:actonInfo.actionResponseNotify userInfo:actonInfo.mj_keyValues];
        [[NSNotificationCenter defaultCenter] postNotificationName:actonInfo.actionResponseNotify object:nil userInfo:[actonInfo toDictionary]];
        return;
    }
    
    {
        //        NSLog(@"data:%x  value:%lx",param,KEY_BUTTON_GROUP(param));
        
        switch (KEY_BUTTON_GROUP(param)) {
                
            case kCLICK_GROUP_0:
                if(KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON_W_KEY)){
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_WLeverClickt_Notification object:nil userInfo:nil];
                        NSLog(@"W S!");
                    }else if(KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)){
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_WLeverLongPressed_Notification object:nil userInfo:nil];
                        NSLog(@"W L!");
                    }else if(KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_RELEASE_NOTIFY_KEY)){
                        if ([self.modelNumberString isEqualToString:modelNumberCraneM2]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_WRelease_Notification object:nil userInfo:nil];
                        }
                        else{
                          [[NSNotificationCenter defaultCenter] postNotificationName:Device_WLeverLongRelease_Notification object:nil userInfo:nil];
                        }
                        NSLog(@"W relsease!");
                    }
                    else if(KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_PRESSED_NOTIFY_KEY)){
                        if ([self.modelNumberString isEqualToString:modelNumberCraneM2]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_WPress_Notification object:nil userInfo:nil];
                            NSLog(@"W S!");
                        }
                    }
                }else if(KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON_T_KEY)){
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_TLeverClick_Notification object:nil userInfo:nil];
                        NSLog(@"T S!");
                    }else if(KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)){
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_TLeverLongPressed_Notification object:nil userInfo:nil];
                        NSLog(@"T L!");
                    }else if(KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_RELEASE_NOTIFY_KEY)){
                        if ([self.modelNumberString isEqualToString:modelNumberCraneM2]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_TRelease_Notification object:nil userInfo:nil];
                        }
                        else{
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_TLeverLongRelease_Notification object:nil userInfo:nil];
                        }
                        NSLog(@"T relsease!");
                    }
                    else if(KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_PRESSED_NOTIFY_KEY)){
                        if ([self.modelNumberString isEqualToString:modelNumberCraneM2]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_TPress_Notification object:nil userInfo:nil];
                            NSLog(@"T S!");
                        }
                    }
                    
                }else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_PHOTO_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_TRIPLE_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_New_PhotoTripleClick_Notification object:nil userInfo:nil];
                        
                    }
                    else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_DOUBLE_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_New_PhotoDoubleClick_Notification object:nil userInfo:nil];
                    }
                    else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {//新拍照click
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_New_PhotoSingleClick_Notification object:nil userInfo:nil];

                    }
                }else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_PHOTOS_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_TRIPLE_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_PhotoTripleClick_Notification object:nil userInfo:nil];
                        
                    }
                    else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_DOUBLE_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_PhotoDoubleClick_Notification object:nil userInfo:nil];
                    }
                    else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {//拍照click
                        if (![self.modelNumberString isEqualToString:modelNumberSmooth3]) {
                            NSLog(@"SM 2 拍照");
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_TakePhoto_Notification object:nil userInfo:nil];
                        }
                        else{
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_PhotoSingleClick_Notification object:nil userInfo:nil];

                        }
                    }else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_RELEASE_NOTIFY_KEY)){//拍照释放
                        if ([self.modelNumberString isEqualToString:modelNumberSmooth3]) {
                            self.temp ++;
                            @weakify(self)
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                @strongify(self)
                                if (self.temp == 2 ) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth3_DoubleClick_Notification object:nil userInfo:nil];
                                    NSLog(@"SM 3 双击");
                                    self.temp = 0;
                                }else if (self.temp == 1){
                                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth3_TakePhoto_Notification object:nil userInfo:nil];
                                    NSLog(@"SM 3 单击");
                                    self.temp = 0;
                                }else{
                                    self.temp = 0;
                                }
                            });
                        }
                    }
                }else if (KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_FN_KEY)){
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {//FN 单击
                        
                        _clickDate = [NSDate dateWithTimeIntervalSinceNow:0];
                        
                    }else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)){
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth3_FunLongPressed_Notification object:nil userInfo:nil];
                        
                        NSLog(@"FN长按1秒");
                    }else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_RELEASE_NOTIFY_KEY)){
                        
                        NSTimeInterval interval = [_clickDate timeIntervalSinceNow];
                        if (interval>-1.0) {
                            NSLog(@"FN 单击");
                            [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth3_FunClick_Notification object:nil userInfo:nil];
                            
                        }
                    }
                }else if (KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_CW_KEY)){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth3_CW_Notification object:nil userInfo:nil];
                }else if (KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_CCW_KEY)){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth3_CCW_Notification object:nil userInfo:nil];
                }
                else if (KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_CAPTURE_KEY)){
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {//capture 单击
                        
                        
                         [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_Capture_Notification object:nil userInfo:nil];
                    }
                }
                else if (KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_RECORD_KEY)){
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {//capture 单击
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_Record_Notification object:nil userInfo:nil];
                    }
                }
                else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_MOD_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_TRIPLE_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_ModeTripleClick_Notification object:nil userInfo:nil];
                        
                    }
                    else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_DOUBLE_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_ModeDoubleClick_Notification object:nil userInfo:nil];
                    }
                    else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {//拍照click
                       
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_ModeSingleClick_Notification object:nil userInfo:nil];

                    }
                }
                else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_LEFT_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_LeftClick_Notification object:nil userInfo:nil];
                    }
                }
                else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_RIGHT_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_RightClick_Notification object:nil userInfo:nil];
                    }
                }
                else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_UP_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_UpClick_Notification object:nil userInfo:nil];
                    }
                }
                else if(KEY_BUTTON_PRESS_EQUAL(param,kCLICK_EVENT_BUTTON_DOWN_KEY)) {
                    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:Device_Gropup0_DownClick_Notification object:nil userInfo:nil];
                    }
                }

                return;
                
            case kCLICK_GROUP_2:
                
            {
                // 如果 （不是单击） && （不是长按一秒） && （不是松开）,则不处理该事件
                if ((KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY) == NO)&&
                    (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY) == NO) &&
                    (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_RELEASE_NOTIFY_KEY) == NO)){
                    return;
                }
                if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_MENU_KEY)){
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Menu_PRESSED_1S_Notification];
                        
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Menu_Notification];
                        
                    }
                    
                    
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_DISP_KEY)){
                    
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Disp_PRESSED_1S_Notification];
                        
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Disp_Notification];
                        
                    }
                    
                    
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_UP_KEY)){

                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Up_PRESSED_1S_Notification];

                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Up_Notification];
                    }

                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_DOWN_KEY)){

                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Down_PRESSED_1S_Notification];
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Down_Notification];
                    }

                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_RIGHT_KEY)){

                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Right_PRESSED_1S_Notification];

                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Right_Notification];

                    }

                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_LEFT_KEY)){
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Left_PRESSED_1S_Notification];

                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Left_Notification];

                    }


                }else
                    if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_FLASH_KEY)){
                    
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Flash_PRESSED_1S_Notification];
                        
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Flash_Notification];
                        
                    }
                    
                    
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_SWITCH_KEY)){
                    
                    
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Switch_PRESSED_1S_Notification];
                        
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Switch_Notification];
                    }
                    
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_STEP_B_KEY)){
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Record_PRESSED_1S_Notification];
                        
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Record_Notification];
                    }
                    
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_PHOTOS_MODE_KEY)){
                    
                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Photos_Mode_PRESSED_1S_Notification];
                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Photos_Mode_Notification];
                    }
                    
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_PHOTOS_KEY)){

                    if(KEY_BUTTON_EVENT_PRESS_EQUAL(param,kCLICK_EVENT_PRESSED_1S_NOTIFY_KEY)) {
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Photos_PRESSED_1S_Notification];

                    }else{
                        [self postNotiWithPara:param andNotiName:Device_Smooth4_Photos_Notification];

                    }

                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_FRONT_CW_KEY)){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth4_Front_CW_Notification object:nil userInfo:nil];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_FRONT_CCW_KEY)){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth4_Front_CCW_Notification object:nil userInfo:nil];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_SIDE_CW_KEY)){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth4_Side_CW_Notification object:nil userInfo:nil];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON2_SIDE_CCW_KEY)){
                    [[NSNotificationCenter defaultCenter] postNotificationName:Device_Smooth4_Side_CCW_Notification object:nil userInfo:nil];
                } else {
                    
                }
                
            }
                break;
            case kCLICK_GROUP_4 :
            {
                return;
                if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_MENU_KEY)){
                    // 菜单
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Menu_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_UP_KEY)){
                    // 上
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Up_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_DOWN_KEY)){
                    // 下
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Down_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_LEFT_KEY)){
                    // 左
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Left_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_RIGHT_KEY)){
                    // 右
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Right_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_LEVER_T_KEY)){
                    // 拨杆T（长焦端）
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Lever_T_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_LEVER_W_KEY)){
                    // 拨杆W
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_Lever_W_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY)){
                    // 这里考虑三种情况：点击，双击，三击，来处理对应事件
//                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_TAKEPIC_Notification];
//                    ZY_KeysActionGroup4th_SWITCH_PICORREC_Notification
//                    ZY_KeysActionGroup4th_SWITCH_CAMERA_Notification
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_WHEEL_CLOCKWISE_KEY)){
                    //
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_WHEEL_CLOCKWISE_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_WHEEL_ANTICLOCKWISE_KEY)){
                    // 拨轮-(逆时针)
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_WHEEL_ANTICLOCKWISE_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_ZOOM_UP_KEY)){
                    // 变焦+(顺时针)
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_ZOOM_UP_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_ZOOM_DOWN_KEY)){
                    // 变焦-(逆时针)
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_ZOOM_DOWN_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_FOCUS_UP_KEY)){
                    // 对焦+(顺时针)
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_FOCUS_UP_Notification];
                }else if (KEY_BUTTON_PRESS_EQUAL(param, kCLICK_EVENT_BUTTON4_FOCUS_DOWN_KEY)){
                    // 对焦-(逆时针)
                    [self postNotiWithPara:param andNotiName:ZY_KeysActionGroup4th_FOCUS_DOWN_Notification];
                }
            }
                break;
            default:
                break;
        }
    }
}

//



-(void)postNotiWithPara:(NSUInteger)param andNotiName:(NSString *)notiName{
    
    [self postNotiWithPara:param andNotiName:notiName userInfo:nil];
}

/**
 集中处理发送至上层的通知

 @param param 收到的值
 @param notiName 通知名称
 @param userInfo 在键组4之后会附带指令数据字典
 */
-(void)postNotiWithPara:(NSUInteger)param andNotiName:(NSString *)notiName userInfo:(nullable NSDictionary *)userInfo{
    NSNumber *key = @(KEY_BUTTON_GROUP(param)|KEY_BUTTON_PRESS_KEY(param));
    
    if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_CLICKED_NOTIFY_KEY)) {
        
        if (key) {
            [self.dicKeyS setObject:[NSDate date] forKey:key];
        }
        return;
    }else if (KEY_BUTTON_EVENT_PRESS_EQUAL(param, kCLICK_EVENT_RELEASE_NOTIFY_KEY)){
        NSDate *date = [self.dicKeyS objectForKey:key];
        
        
        if (date && ([[NSDate date] timeIntervalSinceDate:date] > 1)) {
            return;
        }
    }
    else{
        NSDate *date = [self.dicKeyS objectForKey:key];
        if (date) {
            [self.dicKeyS setObject:[NSDate distantPast] forKey:key];
        }
    }
    //    NSLog(@"%@-------",notiName);
    [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:nil userInfo:userInfo];
}

@end

@implementation ZYKeysAction

- (NSString *)description{
    return [NSString stringWithFormat:@"<描述：%@，键组：%#lx，事件类型：%#lx，值：%#lx>, 通知：%@", self.actionDescription, (unsigned long)self.actionGroup, (unsigned long)self.actionEvent, (unsigned long)self.actionValue, self.actionResponseNotify];
}

+(instancetype)actionWithDiction:(NSDictionary *)dic{
    ZYKeysAction *action = [[ZYKeysAction alloc] init];
    if ([dic objectForKey:@"actionGroup"]) {
        action.actionGroup = [[dic objectForKey:@"actionGroup"] integerValue];
    }
    if ([dic objectForKey:@"actionEvent"]) {
        action.actionEvent = [[dic objectForKey:@"actionEvent"] integerValue];
    }
    if ([dic objectForKey:@"actionValue"]) {
        action.actionValue = [[dic objectForKey:@"actionValue"] integerValue];
    }
    if ([dic objectForKey:@"actionName"]) {
        action.actionName = [dic objectForKey:@"actionName"] ;
    }
    if ([dic objectForKey:@"actionDescription"]) {
        action.actionDescription = [dic objectForKey:@"actionDescription"] ;
    }
    if ([dic objectForKey:@"actionResponseNotify"]) {
        action.actionResponseNotify = [dic objectForKey:@"actionResponseNotify"] ;
    }
    return action;
}

-(NSMutableDictionary *)toDictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:@(self.actionGroup) forKey:@"actionGroup"];
    [dic setObject:@(self.actionEvent) forKey:@"actionEvent"];
    [dic setObject:@(self.actionValue) forKey:@"actionValue"];
    
    if (self.actionName) {
        [dic setObject:self.actionName forKey:@"actionName"];
    }
    if (self.actionDescription) {
        [dic setObject:self.actionDescription forKey:@"actionDescription"];
    }
    if (self.actionResponseNotify) {
        [dic setObject:self.actionResponseNotify forKey:@"actionResponseNotify"];
    }
    
    
    return dic;
}
@end
