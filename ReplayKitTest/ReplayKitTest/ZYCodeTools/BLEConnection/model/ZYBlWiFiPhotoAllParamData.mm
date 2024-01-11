//
//  ZYBlWiFiPhotoAllParamData.m
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/14.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#import "ZYBlWiFiPhotoAllParamData.h"
#import "BlWiFiPhotoAllParamMessage.h"
#import "ZYBlData_internal.h"
using namespace zy;
SAFE_CAST(BlWiFiPhotoAllParamMessage);

@interface ZYBlWiFiPhotoAllParamData()
{
    BlWiFiPhotoAllParamMessage* _message;
}
@end

@implementation ZYBlWiFiPhotoAllParamData

@synthesize message = _message;

-(instancetype) init
{
    if ([super init]) {
        self.message = new BlWiFiPhotoAllParamMessage();
    }
    return self;
}

-(void*) createRawData
{
    CAST_MESSAGE(BlWiFiPhotoAllParamMessage);
    if (self.dataType == 0) {
        message->buildRequest();
    }
    return self.message;
}

-(void) setRawData:(void*)data
{
    [self setRawData:data freeWhenDone:YES];
}

-(void) setRawData:(void*)data freeWhenDone:(BOOL)free
{
    self.free = free;
    CAST_MESSAGE(BlWiFiPhotoAllParamMessage);
    if (message) {
        delete message;
        self.message = NULL;
    }
    self.message = (zy::BlWiFiPhotoAllParamMessage*)data;
    
    [self update];
}

-(void) update
{
    CAST_MESSAGE(BlWiFiPhotoAllParamMessage);
    _Video_Resolution = message->m_allInfo.Video_Resolution;
    _Video_Frame_Rate = message->m_allInfo.Video_Frame_Rate;
    _Video_FOV = message->m_allInfo.Video_FOV;
    _Video_AE = message->m_allInfo.Video_AE;
    _Video_White_Balance = message->m_allInfo.Video_White_Balance;
    _Video_ISO_Max = message->m_allInfo.Video_ISO_Max;
    _Video_ISO_Min = message->m_allInfo.Video_ISO_Min;
    _Video_ISO_limit= message->m_allInfo.Video_ISO_limit;
    _Video_AdvanceMode= message->m_allInfo.Video_AdvanceMode;
    _Video_Interval= message->m_allInfo.Video_Interval;
    _Video_Loop_Interval= message->m_allInfo.Video_Loop_Interval;
    _Video_Timelapse_Interval= message->m_allInfo.Video_Timelapse_Interval;
    _Video_Shutter = message->m_allInfo.Video_Shutter;
    _Video_Sub_Mode = message->m_allInfo.Video_Sub_Mode;
    
    _Photo_Fov = message->m_allInfo.Photo_Fov;
    _Photo_AE = message->m_allInfo.Photo_AE;
    _Photo_White_Balance = message->m_allInfo.Photo_White_Balance;
    _Photo_ISO_Max = message->m_allInfo.Photo_ISO_Max;
    _Photo_ISO_Min = message->m_allInfo.Photo_ISO_Min;
    _Photo_AdvanceMode = message->m_allInfo.Photo_AdvanceMode;
    _Photo_Shutter = message->m_allInfo.Photo_Shutter;
    _Photo_Night_Shutter = message->m_allInfo.Photo_Night_Shutter;
    _Photo_Sub_Mode = message->m_allInfo.Photo_Sub_Mode;
    
    _MultiShot_Fov = message->m_allInfo.MultiShot_Fov;
    _MultiShot_AE = message->m_allInfo.MultiShot_AE;
    _MultiShot_White_Balance = message->m_allInfo.MultiShot_White_Balance;
    _MultiShot_ISO_Max = message->m_allInfo.MultiShot_ISO_Max;
    _MultiShot_ISO_Min = message->m_allInfo.MultiShot_ISO_Min;
    _MultiShot_Interval = message->m_allInfo.MultiShot_Interval;
    _MultiShot_AdvanceMode = message->m_allInfo.MultiShot_AdvanceMode;
    _MultiShot_Shutter = message->m_allInfo.MultiShot_Shutter;
    _MultiShot_Sub_Mode = message->m_allInfo.MultiShot_Sub_Mode;
    
    _Other_LCD_Sleep = message->m_allInfo.Other_LCD_Sleep;
    _Other_Default_Boot_Mode = message->m_allInfo.Other_Default_Boot_Mode;
    _Other_Video_Format = message->m_allInfo.Other_Video_Format;
    _Other_Auto_Power_Off = message->m_allInfo.Other_Auto_Power_Off;
    _Other_Current_Main_Mode = message->m_allInfo.Other_Current_Main_Mode;
    _Other_Current_Sub_Mode = message->m_allInfo.Other_Current_Sub_Mode;
    _Other_Internal_Battery = message->m_allInfo.Other_Internal_Battery;
    _Other_Battery_Level = message->m_allInfo.Other_Battery_Level;
    _Other_Processing_status = message->m_allInfo.Other_Processing_status;
    _Other_SD_card = message->m_allInfo.Other_SD_card;
    _Other_Available_Space = message->m_allInfo.Other_Available_Space;
    
    _MultiShot_Capture_Rate = message->m_allInfo.MultiShot_Capture_Rate;
    _Photo_Delay_Interval = message->m_allInfo.Photo_Delay_Interval;
    _Other_RecordOrPhoto = message->m_allInfo.Other_RecordOrPhoto;
}

@end
