//
//  ZYProductKeyNoti+ActionInfo.m
//  ZYCamera
//
//  Created by iOS on 2019/4/23.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#import "ZYProductKeyNoti+ActionInfo.h"
#import "ZYBleProtocol.h"

@implementation ZYProductKeyNoti (ActionInfo)

/**
 筛选符合 originValue 的指令集合
 
 @param originValue 目标值
 @param sourceArray 待筛选指令数组
 @return 符合条件的指令数组
 */
+ (NSArray *)filterActionArray:(NSUInteger)originValue sourceArray:(NSArray <ZYKeysAction *>*)sourceArray{
    if (!sourceArray || (sourceArray.count == 0)) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(actionValue == %ld&0x0F) AND (actionEvent == %ld&0x0F0) AND (actionGroup == %ld&0xF00)", originValue, originValue, originValue];
    return [sourceArray filteredArrayUsingPredicate:predicate];
}

+ (NSArray <ZYKeysAction *>*)groupZeroActionInfo{
    NSDictionary *actionDict6 = @{@"actionGroup":@(ZY_KeysActionGroupZero),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON_CAPTURE_KEY),
                                  @"actionName":@"KEY_BUTTON_CAPTURE",
                                  @"actionDescription":@"拍照",
                                  @"actionResponseNotify":ZY_KeysActionAll_Notification};
    NSDictionary *actionDict7 = @{@"actionGroup":@(ZY_KeysActionGroupZero),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON_RECORD_KEY),
                                  @"actionName":@"KEY_BUTTON_RECORD",
                                  @"actionDescription":@"录像",
                                  @"actionResponseNotify":ZY_KeysActionAll_Notification};
    
    NSDictionary *actionDict8 = @{@"actionGroup":@(ZY_KeysActionGroupZero),
                                  @"actionEvent":@(ZY_KeysActionEventTypeTouchDown),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON_T_KEY),
                                  @"actionName":@"KEY_BUTTON_ADDZOOM",
                                  @"actionDescription":@"ADDZOOM开始",
                                  @"actionResponseNotify":ZY_KeysActionAll_Notification};
    NSDictionary *actionDict9 = @{@"actionGroup":@(ZY_KeysActionGroupZero),
                                  @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON_T_KEY),
                                  @"actionName":@"KEY_BUTTON_ADDZOOM",
                                  @"actionDescription":@"ADDZOOM结束",
                                  @"actionResponseNotify":ZY_KeysActionAll_Notification};
    
    NSDictionary *actionDict10 = @{@"actionGroup":@(ZY_KeysActionGroupZero),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchDown),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON_W_KEY),
                                   @"actionName":@"KEY_BUTTON_ADDZOOM",
                                   @"actionDescription":@"DECZOOM开始",
                                   @"actionResponseNotify":ZY_KeysActionAll_Notification};
    NSDictionary *actionDict110 = @{@"actionGroup":@(ZY_KeysActionGroupZero),
                                    @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                    @"actionValue":@(kCLICK_EVENT_BUTTON_W_KEY),
                                    @"actionName":@"KEY_BUTTON_ADDZOOM",
                                    @"actionDescription":@"DECZOOM结束",
                                    @"actionResponseNotify":ZY_KeysActionAll_Notification};
    
    return  @[[ZYKeysAction actionWithDiction:actionDict6],[ZYKeysAction actionWithDiction:actionDict6],[ZYKeysAction actionWithDiction:actionDict7],[ZYKeysAction actionWithDiction:actionDict8],[ZYKeysAction actionWithDiction:actionDict9],[ZYKeysAction actionWithDiction:actionDict10],[ZYKeysAction actionWithDiction:actionDict110]];
}

+ (NSArray <ZYKeysAction *>*)group2ndActionInfo{
    NSDictionary *actionDict0 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON2_UP_KEY),
                                  @"actionName":@"KEY_BUTTON2_UP",
                                  @"actionDescription":@"拨轮上",
                                  @"actionResponseNotify":Device_Smooth4_Up_Notification};
    NSDictionary *actionDict01 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON2_UP_KEY),
                                   @"actionName":@"KEY_BUTTON2_UP",
                                   @"actionDescription":@"拨轮上",
                                   @"actionResponseNotify":Device_Smooth4_Up_Notification};
    
    NSDictionary *actionDict1 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON2_DOWN_KEY),
                                  @"actionName":@"KEY_BUTTON2_DOWN",
                                  @"actionDescription":@"拨轮下",
                                  @"actionResponseNotify":Device_Smooth4_Down_Notification};
    NSDictionary *actionDict11 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON2_DOWN_KEY),
                                   @"actionName":@"KEY_BUTTON2_DOWN",
                                   @"actionDescription":@"拨轮下",
                                   @"actionResponseNotify":Device_Smooth4_Down_Notification};
    
    NSDictionary *actionDict2 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON2_RIGHT_KEY),
                                  @"actionName":@"KEY_BUTTON2_RIGHT",
                                  @"actionDescription":@"拨轮右",
                                  @"actionResponseNotify":Device_Smooth4_Right_Notification};
    NSDictionary *actionDict21 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON2_RIGHT_KEY),
                                   @"actionName":@"KEY_BUTTON2_RIGHT",
                                   @"actionDescription":@"拨轮右",
                                   @"actionResponseNotify":Device_Smooth4_Right_Notification};
    
    NSDictionary *actionDict3 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON2_LEFT_KEY),
                                  @"actionName":@"KEY_BUTTON2_LEFT",
                                  @"actionDescription":@"拨轮左",
                                  @"actionResponseNotify":Device_Smooth4_Left_Notification};
    NSDictionary *actionDict31 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON2_LEFT_KEY),
                                   @"actionName":@"KEY_BUTTON2_LEFT",
                                   @"actionDescription":@"拨轮左",
                                   @"actionResponseNotify":Device_Smooth4_Left_Notification};
    
    NSDictionary *actionDict4 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON2_PHOTOS_KEY),
                                  @"actionName":@"KEY_BUTTON2_PHOTOS",
                                  @"actionDescription":@"拍照",
                                  @"actionResponseNotify":Device_Smooth4_Photos_Notification};
    NSDictionary *actionDict41 = @{@"actionGroup":@(ZY_KeysActionGroup2nd),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON2_PHOTOS_KEY),
                                   @"actionName":@"KEY_BUTTON2_PHOTOS",
                                   @"actionDescription":@"拍照",
                                   @"actionResponseNotify":Device_Smooth4_Photos_Notification};
    
    return  @[[ZYKeysAction actionWithDiction:actionDict0],[ZYKeysAction actionWithDiction:actionDict01],[ZYKeysAction actionWithDiction:actionDict1],[ZYKeysAction actionWithDiction:actionDict11],[ZYKeysAction actionWithDiction:actionDict2],[ZYKeysAction actionWithDiction:actionDict21],[ZYKeysAction actionWithDiction:actionDict3],[ZYKeysAction actionWithDiction:actionDict31],[ZYKeysAction actionWithDiction:actionDict4],[ZYKeysAction actionWithDiction:actionDict41]];
}

+ (NSArray <ZYKeysAction *>*)group4ThActionInfo{
    
    NSDictionary *actionDict0 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_MENU_KEY),
                                  @"actionName":@"KEY_BUTTON4_MENU",
                                  @"actionDescription":@"菜单",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Menu_Notification};
    NSDictionary *actionDict1 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_UP_KEY),
                                  @"actionName":@"KEY_BUTTON4_UP",
                                  @"actionDescription":@"拨轮上",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Up_Notification};
    NSDictionary *actionDict2 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_DOWN_KEY),
                                  @"actionName":@"KEY_BUTTON4_DOWN",
                                  @"actionDescription":@"拨轮下",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Down_Notification};
    NSDictionary *actionDict22 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClickDouble),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_DOWN_KEY),
                                  @"actionName":@"KEY_BUTTON4_DOWN",
                                  @"actionDescription":@"拨轮下双击",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Down_DoubleClick_Notification};
    NSDictionary *actionDict3 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_LEFT_KEY),
                                  @"actionName":@"KEY_BUTTON4_LEFT",
                                  @"actionDescription":@"拨轮左",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Left_Notification};
    NSDictionary *actionDict4 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_RIGHT_KEY),
                                  @"actionName":@"KEY_BUTTON4_RIGHT",
                                  @"actionDescription":@"拨轮右",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Right_Notification};
    
    NSDictionary *actionDict5 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_LEVER_T_KEY),
                                  @"actionName":@"KEY_BUTTON4_LEVER_T",
                                  @"actionDescription":@"拨杆T（长焦端）",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Lever_T_Notification};
    NSDictionary *actionDict51 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_LEVER_T_KEY),
                                  @"actionName":@"KEY_BUTTON4_LEVER_T",
                                  @"actionDescription":@"拨杆T（长焦端）",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Lever_T_Release_Notification};
    NSDictionary *actionDict6 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_LEVER_W_KEY),
                                  @"actionName":@"KEY_BUTTON4_LEVER_W",
                                  @"actionDescription":@"拨杆W",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Lever_W_Notification};
    NSDictionary *actionDict61 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_LEVER_W_KEY),
                                  @"actionName":@"KEY_BUTTON4_LEVER_W",
                                  @"actionDescription":@"拨杆W",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_Lever_W_Release_Notification};
    NSDictionary *actionDict7 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY),
                                  @"actionName":@"KEY_BUTTON4_TAKEPICBTN",
                                  @"actionDescription":@"录像/拍照",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_TAKEPIC_Single_Notification};
    NSDictionary *actionDict71 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeClickDouble),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY),
                                   @"actionName":@"KEY_BUTTON4_TAKEPICBTN",
                                   @"actionDescription":@"切换拍照/录像",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_TAKEPIC_Double_Notification};
    NSDictionary *actionDict72 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeClickTriple),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY),
                                   @"actionName":@"KEY_BUTTON4_TAKEPICBTN",
                                   @"actionDescription":@"三击   录像/拍照",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_TAKEPIC_Triple_Notification};
    
    NSDictionary *actionDict73 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeLongPressSecond1s),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY),
                                   @"actionName":@"KEY_BUTTON4_TAKEPICBTN",
                                   @"actionDescription":@"长按开始   录像/拍照",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_TAKEPIC_LongTouchUp_Notification};
    
    
    NSDictionary *actionDict74 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeTouchUp),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_TAKEPICBTN_KEY),
                                   @"actionName":@"KEY_BUTTON4_TAKEPICBTN",
                                   @"actionDescription":@"长按释放   录像/拍照",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_TAKEPIC_LongTouchDown_Notification};
    
    NSDictionary *actionDict8 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_WHEEL_CLOCKWISE_KEY),
                                  @"actionName":@"KEY_BUTTON4_WHEEL_CLOCKWISE",
                                  @"actionDescription":@"拨轮+(顺时针)",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_WHEEL_CLOCKWISE_Notification};
    NSDictionary *actionDict9 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_WHEEL_ANTICLOCKWISE_KEY),
                                  @"actionName":@"KEY_BUTTON4_WHEEL_ANTICLOCKWISE",
                                  @"actionDescription":@"后拨轮-(逆时针)",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_WHEEL_ANTICLOCKWISE_Notification};
    NSDictionary *actionDict10 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                  @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                  @"actionValue":@(kCLICK_EVENT_BUTTON4_ZOOM_UP_KEY),
                                  @"actionName":@"KEY_BUTTON4_UP",
                                  @"actionDescription":@"变焦+(顺时针)",
                                  @"actionResponseNotify":ZY_KeysActionGroup4th_ZOOM_UP_Notification};
    NSDictionary *actionDict11 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_ZOOM_DOWN_KEY),
                                   @"actionName":@"KEY_BUTTON4_UP",
                                   @"actionDescription":@"变焦-(逆时针)",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_ZOOM_DOWN_Notification};
    NSDictionary *actionDict12 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_FOCUS_UP_KEY),
                                   @"actionName":@"KEY_BUTTON4_UP",
                                   @"actionDescription":@"变焦-(逆时针)",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_FOCUS_UP_Notification};
    
    NSDictionary *actionDict13 = @{@"actionGroup":@(ZY_KeysActionGroup4th),
                                   @"actionEvent":@(ZY_KeysActionEventTypeClick),
                                   @"actionValue":@(kCLICK_EVENT_BUTTON4_FOCUS_DOWN_KEY),
                                   @"actionName":@"KEY_BUTTON4_UP",
                                   @"actionDescription":@"变焦-(逆时针)",
                                   @"actionResponseNotify":ZY_KeysActionGroup4th_FOCUS_DOWN_Notification};
    
    return  @[[ZYKeysAction actionWithDiction:actionDict0],[ZYKeysAction actionWithDiction:actionDict1],[ZYKeysAction actionWithDiction:actionDict2],[ZYKeysAction actionWithDiction:actionDict22],[ZYKeysAction actionWithDiction:actionDict3],[ZYKeysAction actionWithDiction:actionDict4],[ZYKeysAction actionWithDiction:actionDict5],[ZYKeysAction actionWithDiction:actionDict51],[ZYKeysAction actionWithDiction:actionDict6],[ZYKeysAction actionWithDiction:actionDict61],[ZYKeysAction actionWithDiction:actionDict7],[ZYKeysAction actionWithDiction:actionDict71],[ZYKeysAction actionWithDiction:actionDict72],[ZYKeysAction actionWithDiction:actionDict73],[ZYKeysAction actionWithDiction:actionDict74],[ZYKeysAction actionWithDiction:actionDict8],[ZYKeysAction actionWithDiction:actionDict9],[ZYKeysAction actionWithDiction:actionDict10],[ZYKeysAction actionWithDiction:actionDict11],[ZYKeysAction actionWithDiction:actionDict12],[ZYKeysAction actionWithDiction:actionDict13]];

}

/**
 源指令数组
 */
+ (NSArray <ZYKeysAction *>*)allKeysActionInfo{
    
    return nil;
}

@end
