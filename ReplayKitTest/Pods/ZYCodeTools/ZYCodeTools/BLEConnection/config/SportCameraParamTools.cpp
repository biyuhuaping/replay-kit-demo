//
//  SportCameraParamTools.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/6/3.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "SportCameraParamTools.h"
#include "ParamDef.h"
#include <algorithm>

NAMESPACE_ZY_BEGIN

using namespace SportCamera;

SportCameraParamTools::SportCameraParamTools()
{
    
}

SportCameraParamTools::~SportCameraParamTools()
{
    
}

SportCameraParamTools* SportCameraParamTools::instance()
{
    if (sm_instance == NULL) {
        sm_instance = new SportCameraParamTools();
        sm_instance->config();
    }
    return sm_instance;
}

void SportCameraParamTools::configDevice(const std::string& deviceName, const std::string& deviceColor)
{
    m_deviceName = deviceName;
    m_deviceColor = deviceColor;
    
    std::vector<SportCameraParamInfo> vec;
    m_activeInfos.swap(vec);
    
    for (size_t i = 0; i < m_infos.size(); i++) {
        SportCameraParamInfo& info = m_infos[i];
        if(find(info.supportModels.begin(), info.supportModels.end(), m_deviceName) != info.supportModels.end()
           && find(info.supportColors.begin(), info.supportColors.end(), m_deviceColor) != info.supportColors.end())
            m_activeInfos.push_back(info);
    }
}

void SportCameraParamTools::getActiveConfig(std::vector<SportCameraParamInfo>& infos)
{
    infos = m_activeInfos;
}

void SportCameraParamTools::getSpecificSettings(std::vector<SportCameraParamInfo>& infos, int supportMode, const std::string& type, const std::string& name)
{
    for (size_t i = 0; i < m_activeInfos.size(); i++) {
        SportCameraParamInfo& info = m_activeInfos[i];
        if (info.supportMode == supportMode) {
            if (!type.empty() && type.compare(info.type) != 0) {
                continue;
            }
            if (!name.empty() && name.compare(info.name) != 0) {
                continue;
            }
            infos.push_back(info);
        }
    }
}

SportCameraParamTools* SportCameraParamTools::sm_instance = NULL;

void SportCameraParamTools::addInfo(const SportCameraParamInfo& info)
{
    m_infos.push_back(info);
}

void SportCameraParamTools::config()
{
    addInfo({68, 0, Video_mode, supportMode_Other, "Video", "Current_Mode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({68, 1, Photo_mode, supportMode_Other, "Photo", "Current_Mode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({68, 2, MultiShot_mode, supportMode_Other, "MultiShot", "Current_Mode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({69, 0, Get_Gopro_None_Param, supportMode_Other, "Video/Single Pic/Burst", "Current_SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({69, 1, Get_Gopro_None_Param, supportMode_Other, "TL Video/Continuous/TimeLapse", "Current_SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({69, 2, Get_Gopro_None_Param, supportMode_Other, "Video+Photo/NightPhoto/NightLapse", "Current_SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({69, 3, Get_Gopro_None_Param, supportMode_Other, "Looping", "Current_SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({1, 0, Secondary_modes_Video, supportMode_Video, "Video", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({1, 1, Secondary_modes_TimeLapse_Video, supportMode_Video, "TimeLapse Video", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({1, 2, Secondary_modes_Video_Photo, supportMode_Video, "Video+Photo", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({1, 3, Secondary_modes_Looping, supportMode_Video, "Looping", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({19, 1, Secondary_modes_Single, supportMode_Photo, "Single", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
//    addInfo({19, 1, Get_Gopro_None_Param, supportMode_Photo, "Continuous", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({19, 2, Secondary_modes_Night, supportMode_Photo, "Night", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({34, 0, Secondary_modes_Burst, supportMode_MultiShot, "Burst", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({34, 1, Secondary_modes_Timelapse, supportMode_MultiShot, "Timelapse", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({34, 2, Secondary_modes_NightLapse, supportMode_MultiShot, "NightLapse", "SubMode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({2, 2, Black_Video_Resolutions_4K_SuperView, supportMode_Video, "4K SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 1, Black_Video_Resolutions_4K, supportMode_Video, "4K", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 1, Silver_Video_Resolutions_4K, supportMode_Video, "4K", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 5, Black_Video_Resolutions_2_7K_SuperView, supportMode_Video, "2_7K_SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 4, Black_Video_Resolutions_2_7K, supportMode_Video, "2_7K", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 4, Silver_Video_Resolutions_2_7K, supportMode_Video, "2_7K", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 6, Black_Video_Resolutions_2_7K_4_3, supportMode_Video, "2.7k 4:3", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 6, Silver_Video_Resolutions_2_7K_4_3, supportMode_Video, "2.7k 4:3", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 7, Black_Video_Resolutions_1440p, supportMode_Video, "1440", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 7, Silver_Video_Resolutions_1440p, supportMode_Video, "1440", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 7, Session_Video_Resolutions_1440p, supportMode_Video, "1440", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({2, 8, Black_Video_Resolutions_1080p_SuperView, supportMode_Video, "1080 SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 8, Silver_Video_Resolutions_1080p_SuperView, supportMode_Video, "1080 SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 8, Session_Video_Resolutions_1080p_SuperView, supportMode_Video, "1080 SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({2, 9, Black_Video_Resolutions_1080p, supportMode_Video, "1080", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 9, Silver_Video_Resolutions_1080p, supportMode_Video, "1080", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 9, Session_Video_Resolutions_1080p, supportMode_Video, "1080", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({2, 10, Black_Video_Resolutions_960p, supportMode_Video, "960", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 10, Silver_Video_Resolutions_960p, supportMode_Video, "960", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 10, Session_Video_Resolutions_960p, supportMode_Video, "960", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({2, 11, Black_Video_Resolutions_720p_SuperView, supportMode_Video, "720 SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 11, Silver_Video_Resolutions_720p_SuperView, supportMode_Video, "720 SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 11, Session_Video_Resolutions_720p_SuperView, supportMode_Video, "720 SuperView", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({2, 12, Black_Video_Resolutions_720p, supportMode_Video, "720", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 12, Silver_Video_Resolutions_720p, supportMode_Video, "720", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 12, Session_Video_Resolutions_720p, supportMode_Video, "720", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({2, 13, Black_Video_Resolutions_WVGA, supportMode_Video, "WVGA", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Black"}, ""});
    addInfo({2, 13, Silver_Video_Resolutions_WVGA, supportMode_Video, "WVGA", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({2, 13, Session_Video_Resolutions_WVGA, supportMode_Video, "WVGA", "Video_Resolution", {"HERO4", "HERO5", "HERO6"}, {"Session"}, ""});
    addInfo({3, 0, Black_Session_Video_Frame_Rate_240fps, supportMode_Video, "240", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 0, Silver_Video_Frame_Rate_240fps, supportMode_Video, "240", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 1, Black_Session_Video_Frame_Rate_120fps, supportMode_Video, "120", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 1, Silver_Video_Frame_Rate_120fps, supportMode_Video, "120", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 2, Black_Session_Video_Frame_Rate_100fps, supportMode_Video, "100", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 2, Silver_Video_Frame_Rate_100fps, supportMode_Video, "100", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 3, Black_Session_Video_Frame_Rate_90fps, supportMode_Video, "90", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 4, Black_Session_Video_Frame_Rate_80fps, supportMode_Video, "80", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 5, Black_Session_Video_Frame_Rate_60fps, supportMode_Video, "60", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 5, Silver_Video_Frame_Rate_60fps, supportMode_Video, "60", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 6, Black_Session_Video_Frame_Rate_50fps, supportMode_Video, "50", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 6, Silver_Video_Frame_Rate_50fps, supportMode_Video, "50", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 7, Black_Session_Video_Frame_Rate_48fps, supportMode_Video, "48", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 7, Silver_Video_Frame_Rate_48fps, supportMode_Video, "48", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 8, Black_Session_Video_Frame_Rate_30fps, supportMode_Video, "30", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 8, Silver_Video_Frame_Rate_30fps, supportMode_Video, "30", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 9, Black_Session_Video_Frame_Rate_25fps, supportMode_Video, "25", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Session"}, ""});
    addInfo({3, 9, Silver_Video_Frame_Rate_25fps, supportMode_Video, "25", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 10, Silver_Video_Frame_Rate_24fps, supportMode_Video, "24", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 11, Silver_Video_Frame_Rate_15fps, supportMode_Video, "15", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({3, 12, Silver_Video_Frame_Rate_12_5fps, supportMode_Video, "12.5", "Frame_Rate", {"HERO4", "HERO5", "HERO6"}, {"Silver"}, ""});
    addInfo({4, 0, Video_FOV_Wide, supportMode_Video, "Wide", "FOV_video", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({4, 1, Video_FOV_Medium, supportMode_Video, "Medium", "FOV_video", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({4, 2, Video_FOV_Narrow, supportMode_Video, "Narrow", "FOV_video", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({4, 4, Video_FOV_Linear, supportMode_Video, "Linear", "FOV_video", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({20, 0, Photo_setting_12MP_Wide, supportMode_Photo, "Wide", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({20, 8, Photo_setting_12MP_Medium, supportMode_Photo, "Medium", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({20, 9, Photo_setting_12MP_Narrow, supportMode_Photo, "Narrow", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({20, 10, Photo_setting_12MP_Linear, supportMode_Photo, "Linear", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({36, 0, MultiShot_Wide, supportMode_MultiShot, "Wide", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({36, 8, MultiShot_Narrow, supportMode_MultiShot, "Medium", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({36, 9, MultiShot_Medium, supportMode_MultiShot, "Narrow", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({36, 10, MultiShot_Linear, supportMode_MultiShot, "Linear", "FOV_video", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 0, Timelapse_Interval_0_5, supportMode_Video, "1/2 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 1, Timelapse_Interval_1, supportMode_Video, "1 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 2, Timelapse_Interval_2, supportMode_Video, "2 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 3, Timelapse_Interval_5, supportMode_Video, "5 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 4, Timelapse_Interval_10, supportMode_Video, "10 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 5, Timelapse_Interval_30, supportMode_Video, "30 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({5, 6, Timelapse_Interval_60, supportMode_Video, "60 Seconds", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({6, 0, Video_Looping_Duration_Max, supportMode_Video, "Max", "Looping_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({6, 1, Video_Looping_Duration_5Min, supportMode_Video, "5 Minutes", "Looping_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({6, 2, Video_Looping_Duration_20Min, supportMode_Video, "20 Minutes", "Looping_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({6, 3, Video_Looping_Duration_60Min, supportMode_Video, "60 Minutes", "Looping_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({6, 4, Video_Looping_Duration_120Min, supportMode_Video, "120 Minutes", "Looping_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({7, 1, Video_Photo_Interval5, supportMode_Video, "1 Photo / 5 Seconds", "Video_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({7, 2, Video_Photo_10, supportMode_Video, "1 Photo / 10 Seconds", "Video_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({7, 3, Video_Photo_30, supportMode_Video, "1 Photo / 30 Seconds", "Video_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({7, 4, Video_Photo_60Min, supportMode_Video, "1 Photo / 60 Seconds", "Video_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({8, 1, Video_Low_Light_ON, supportMode_Video, "ON", "Low_Light", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({8, 0, Video_Low_Light_OFF, supportMode_Video, "OFF", "Low_Light", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({9, 1, Video_Spot_Meter_on, supportMode_Video, "ON", "Spot_Meter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({9, 0, Video_Spot_Meter_off, supportMode_Video, "OFF", "Spot_Meter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({23, 1, PhotoSpot_Meter_on, supportMode_Photo, "ON", "Spot_Meter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({23, 0, Photo_Spot_Meter_off, supportMode_Photo, "OFF", "Spot_Meter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({39, 1, MultiShot_Spot_Meter_on, supportMode_MultiShot, "ON", "Spot_Meter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({39, 0, MultiShot_Spot_Meter_off, supportMode_MultiShot, "OFF", "Spot_Meter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({10, 1, Video_mode_On, supportMode_Video, "ON", "Protune", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({10, 0, Video_mode_Off, supportMode_Video, "OFF", "Protune", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({24, 1, Photo_mode_On, supportMode_Photo, "ON", "Protune", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({24, 0, Photo_mode_Off, supportMode_Photo, "OFF", "Protune", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({40, 1, Multishot_mode_On, supportMode_MultiShot, "ON", "Protune", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({40, 0, Multishot_mode_Off, supportMode_MultiShot, "OFF", "Protune", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 0, Video_White_Balance_Auto, supportMode_Video, "Auto", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 1, Video_White_Balance_3000k, supportMode_Video, "3000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 5, Video_White_Balance_4000k, supportMode_Video, "4000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 6, Video_White_Balance_4800k, supportMode_Video, "4800k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 2, Video_White_Balance_5500k, supportMode_Video, "5500k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 7, Video_White_Balance_6000k, supportMode_Video, "6000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 3, Video_White_Balance_6500k, supportMode_Video, "6500k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({11, 4, Video_White_Balance_Native, supportMode_Video, "Native", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 0, Photo_White_Balance_Auto, supportMode_Photo, "Auto", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 1, Photo_White_Balance_3000k, supportMode_Photo, "3000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 5, Photo_White_Balance_4000k, supportMode_Photo, "4000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 6, Photo_White_Balance_4800k, supportMode_Photo, "4800k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 2, Photo_White_Balance_5500k, supportMode_Photo, "5500k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 7, Photo_White_Balance_6000k, supportMode_Photo, "6000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 3, Photo_White_Balance_6500k, supportMode_Photo, "6500k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({26, 4, Photo_White_Balance_Native, supportMode_Photo, "Native", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 0, MultiShot_White_Balance_Auto, supportMode_MultiShot, "Auto", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 1, MultiShot_White_Balance_3000k, supportMode_MultiShot, "3000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 5, MultiShot_White_Balance_4000k, supportMode_MultiShot, "4000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 6, MultiShot_White_Balance_4800k, supportMode_MultiShot, "4800k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 2, MultiShot_White_Balance_5500k, supportMode_MultiShot, "5500k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 7, MultiShot_White_Balance_6000k, supportMode_MultiShot, "6000k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 3, MultiShot_White_Balance_6500k, supportMode_MultiShot, "6500k", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({41, 4, MultiShot_White_Balance_Native, supportMode_MultiShot, "Native", "White_Balance", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({12, 0, Video_mode_Color_GOPRO, supportMode_Video, "GoPro Color", "Color", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({12, 1, Video_mode_Color_Flat, supportMode_Video, "Flat", "Color", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({27, 0, Photo_mode_Color_GOPRO, supportMode_Photo, "GoPro Color", "Color", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({27, 1, Photo_mode_Color_Flat, supportMode_Photo, "Flat", "Color", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({42, 0, MultiShot_mode_Color_GOPRO, supportMode_MultiShot, "GoPro Color", "Color", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({42, 1, MultiShot_mode_Color_Flat, supportMode_MultiShot, "Flat", "Color", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 3, EV_24FPS_1_24, supportMode_Video, "24FPS 1/24", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 6, EV_24FPS_1_48, supportMode_Video, "24FPS 1/48", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 11, EV_24FPS_1_96, supportMode_Video, "24FPS 1/96", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 5, EV_30FPS_1_30, supportMode_Video, "30FPS 1/30", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 8, EV_30FPS_1_60, supportMode_Video, "30FPS 1/60", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 13, EV_30FPS_1_120, supportMode_Video, "30FPS 1/120", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 6, EV_48FPS_1_48, supportMode_Video, "48FPS 1/48", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 11, EV_48FPS_1_96, supportMode_Video, "48FPS 1/96", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 16, EV_48FPS_1_192, supportMode_Video, "48FPS 1/192", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 8, EV_60FPS_1_60, supportMode_Video, "60FPS 1/60", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 13, EV_60FPS_1_120, supportMode_Video, "60FPS 1/120", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 18, EV_60FPS_1_240, supportMode_Video, "60FPS 1/240", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 10, EV_90FPS_1_90, supportMode_Video, "90FPS 1/90", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 15, EV_90FPS_1_180, supportMode_Video, "90FPS 1/180", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 20, EV_90FPS_1_360, supportMode_Video, "90FPS 1/360", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 13, EV_120FPS_1_120, supportMode_Video, "120FPS 1/120", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 18, EV_120FPS_1_240, supportMode_Video, "120FPS 1/240", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 22, EV_120FPS_1_480, supportMode_Video, "120FPS 1/480", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 18, EV_240FPS_1_120, supportMode_Video, "240FPS 1/120", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 12, EV_240FPS_1_240, supportMode_Video, "240FPS 1/240", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({16, 23, EV_240FPS_1_480, supportMode_Video, "240FPS 1/480", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({72, 0, Photo_Shutter_auto, supportMode_Photo, "auto", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({72, 1, Photo_Shutter_125, supportMode_Photo, "1/125", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({72, 2, Photo_Shutter_250, supportMode_Photo, "1/250", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({72, 3, Photo_Shutter_500, supportMode_Photo, "1/500", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({72, 4, Photo_Shutter_1000, supportMode_Photo, "1/1000", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({72, 5, Photo_Shutter_2000, supportMode_Photo, "1/2000", "Manual_Exposure", {"HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({17, 0, Video_ISO_Mode_Max, supportMode_Video, "Max", "ISO_Mode", {"HERO4"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({17, 1, Video_ISO_Mode_Lock, supportMode_Video, "Lock", "ISO_Mode", {"HERO4"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 0, Video_ISO_Limit_6400, supportMode_Video, "6400", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 1, Video_ISO_Limit_1600, supportMode_Video, "1600", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 2, Video_ISO_Limit_400, supportMode_Video, "400", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 3, Video_ISO_Limit_3200, supportMode_Video, "3200", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 4, Video_ISO_Limit_800, supportMode_Video, "800", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 7, Video_ISO_Limit_200, supportMode_Video, "200", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({13, 8, Video_ISO_Limit_100, supportMode_Video, "100", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({31, 1, Photo_ISO_Limit_400, supportMode_Photo, "400", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({31, 0, Photo_ISO_Limit_800, supportMode_Photo, "800", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({31, 2, Photo_ISO_Limit_200, supportMode_Photo, "200", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({31, 3, Photo_ISO_Limit_100, supportMode_Photo, "100", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({47, 1, MultiShot_ISO_Limit_400, supportMode_MultiShot, "400", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({47, 0, MultiShot_ISO_Limit_800, supportMode_MultiShot, "800", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({47, 2, MultiShot_ISO_Limit_200, supportMode_MultiShot, "200", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({47, 3, MultiShot_ISO_Limit_100, supportMode_MultiShot, "100", "ISO_Limit", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, "v4.00FW"});
    addInfo({30, 0, Photo_ISO_Min_800, supportMode_Photo, "800", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({30, 1, Photo_ISO_Min_400, supportMode_Photo, "400", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({30, 2, Photo_ISO_Min_200, supportMode_Photo, "200", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({30, 3, Photo_ISO_Min_100, supportMode_Photo, "100", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({46, 0, MultiShot_ISO_Min_800, supportMode_MultiShot, "800", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({46, 1, MultiShot_ISO_Min_400, supportMode_MultiShot, "400", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({46, 2, MultiShot_ISO_Min_200, supportMode_MultiShot, "200", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({46, 3, MultiShot_ISO_Min_100, supportMode_MultiShot, "100", "ISO_Min", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({14, 0, Video_mode_Sharpness_High, supportMode_Video, "High", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({14, 1, Video_mode_Sharpness_Med, supportMode_Video, "Medium", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({14, 2, Video_mode_Sharpness_Low, supportMode_Video, "Low", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({14, 3, Get_Gopro_None_Param, supportMode_Video, "On", "Sharpness", {"HERO4"}, {"Session"}, ""});
    addInfo({14, 4, Get_Gopro_None_Param, supportMode_Video, "Off", "Sharpness", {"HERO4"}, {"Session"}, ""});
    addInfo({28, 0, Photo_mode_Sharpness_High, supportMode_Photo, "High", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({28, 1, Photo_mode_Sharpness_Med, supportMode_Photo, "Medium", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({28, 2, Photo_mode_Sharpness_Low, supportMode_Photo, "Low", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({44, 0, MultiShot_mode_Sharpness_High, supportMode_MultiShot, "High", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({44, 1, MultiShot_mode_Sharpness_Med, supportMode_MultiShot, "Medium", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({44, 2, MultiShot_mode_Sharpness_Low, supportMode_MultiShot, "Low", "Sharpness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 8, Video_EV__2, supportMode_Video, "-2", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 7, Video_EV__1_5, supportMode_Video, "-1.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 6, Video_EV__1, supportMode_Video, "-1", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 5, Video_EV__0_5, supportMode_Video, "-0.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 4, Video_EV_0, supportMode_Video, "0", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 3, Video_EV_0_5, supportMode_Video, "0.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 2, Video_EV_1, supportMode_Video, "1", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 1, Video_EV_1_5, supportMode_Video, "1.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({15, 0, Video_EV_2, supportMode_Video, "2", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 8, Photo_EV__2, supportMode_Photo, "-2", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 7, Photo_EV__1_5, supportMode_Photo, "-1.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 6, Photo_EV__1, supportMode_Photo, "-1", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 5, Photo_EV__0_5, supportMode_Photo, "-0.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 4, Photo_EV_0, supportMode_Photo, "0", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 3, Photo_EV_0_5, supportMode_Photo, "0.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 2, Photo_EV_1, supportMode_Photo, "1", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 1, Photo_EV_1_5, supportMode_Photo, "1.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({29, 0, Photo_EV_2, supportMode_Photo, "2", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 8, MultiShot_EV__2, supportMode_MultiShot, "-2", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 7, MultiShot_EV__1_5, supportMode_MultiShot, "-1.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 6, MultiShot_EV__1, supportMode_MultiShot, "-1", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 5, MultiShot_EV__0_5, supportMode_MultiShot, "-0.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 4, MultiShot_EV_0, supportMode_MultiShot, "0", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 3, MultiShot_EV_0_5, supportMode_MultiShot, "0.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 2, MultiShot_EV_1, supportMode_MultiShot, "1", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 1, MultiShot_EV_1_5, supportMode_MultiShot, "1.5", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({45, 0, MultiShot_EV_2, supportMode_MultiShot, "2", "EV_Comp", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 0, Photo_NightPhoto_Exposure_Auto, supportMode_Photo, "Auto", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 1, Photo_NightPhoto_Exposure_2, supportMode_Photo, "2s", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 2, Photo_NightPhoto_Exposure_5, supportMode_Photo, "5s", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 3, Photo_NightPhoto_Exposure_10, supportMode_Photo, "10s", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 4, Photo_NightPhoto_Exposure_15, supportMode_Photo, "15s", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 5, Photo_NightPhoto_Exposure_20, supportMode_Photo, "20s", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({22, 6, Photo_NightPhoto_Exposure_30, supportMode_Photo, "30s", "Shutter", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 0, MultiShot_NightLapse_Exposure_Auto, supportMode_MultiShot, "Auto", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 1, MultiShot_NightLapse_Exposure_2, supportMode_MultiShot, "2s", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 2, MultiShot_NightLapse_Exposure_5, supportMode_MultiShot, "5s", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 3, MultiShot_NightLapse_Exposure_10, supportMode_MultiShot, "10s", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 4, MultiShot_NightLapse_Exposure_15, supportMode_MultiShot, "15s", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 5, MultiShot_NightLapse_Exposure_20, supportMode_MultiShot, "20s", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({35, 6, MultiShot_NightLapse_Exposure_30, supportMode_MultiShot, "30s", "Shutter_Exposure", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({21, 0, Photo_Continuous_rate_3, supportMode_Photo, "3 Frames / Second", "Continuous_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({21, 1, Photo_Continuous_rate_5, supportMode_Photo, "5 Frames / Second", "Continuous_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({21, 2, Photo_Continuous_rate_10, supportMode_Photo, "10 Frames / Second", "Continuous_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 0, Burst_Rate_3_1, supportMode_MultiShot, "3 Photos / 1 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 1, Burst_Rate_5_1, supportMode_MultiShot, "5 Photos / 1 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 2, Burst_Rate_10_1, supportMode_MultiShot, "10 Photos / 1 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 3, Burst_Rate_10_2, supportMode_MultiShot, "10 Photos / 2 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 4, Burst_Rate_10_3, supportMode_MultiShot, "10 Photos / 3 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 5, Burst_Rate_30_1, supportMode_MultiShot, "30 Photos / 1 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 6, Burst_Rate_30_2, supportMode_MultiShot, "30 Photos / 2 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 7, Burst_Rate_30_3, supportMode_MultiShot, "30 Photos / 3 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({37, 8, Burst_Rate_30_6, supportMode_MultiShot, "30 Photos / 6 Second", "Burst_Rate", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 0, Timelapse_Interval_0_5, supportMode_MultiShot, "1 Photo / 0.5 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 1, Timelapse_Interval_1, supportMode_MultiShot, "1 Photo / 1 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 2, Timelapse_Interval_2, supportMode_MultiShot, "1 Photo / 2 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 5, Timelapse_Interval_5, supportMode_MultiShot, "1 Photo / 5 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 10, Timelapse_Interval_10, supportMode_MultiShot, "1 Photo / 10 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 30, Timelapse_Interval_30, supportMode_MultiShot, "1 Photo / 30 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({38, 60, Timelapse_Interval_60, supportMode_MultiShot, "1 Photo / 60 Sec", "TimeLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 0, MultiShot_Interval_NightLapse_Continues, supportMode_MultiShot, "Continuous", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 4, MultiShot_Interval_NightLapse_4s, supportMode_MultiShot, "4 Seconds", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 5, MultiShot_Interval_NightLapse_5s, supportMode_MultiShot, "5 Seconds", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 10, MultiShot_Interval_NightLapse_10s, supportMode_MultiShot, "10 Seconds", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 15, MultiShot_Interval_NightLapse_15s, supportMode_MultiShot, "15 Seconds", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 20, MultiShot_Interval_NightLapse_20s, supportMode_MultiShot, "20 Seconds", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 30, MultiShot_Interval_NightLapse_30s, supportMode_MultiShot, "30 Seconds", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 60, MultiShot_Interval_NightLapse_1m, supportMode_MultiShot, "1 Minute", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 120, MultiShot_Interval_NightLapse_2m, supportMode_MultiShot, "2 Minutes", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 300, MultiShot_Interval_NightLapse_5m, supportMode_MultiShot, "5 Minutes", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 1800, MultiShot_Interval_NightLapse_30m, supportMode_MultiShot, "30 Minutes", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({43, 3600, MultiShot_Interval_NightLapse_60m, supportMode_MultiShot, "60 Minutes", "NightLapse_Interval", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({49, 1, LCD_Display_On, supportMode_Other, "ON", "LCD_Display", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({49, 0, LCD_Display_Off, supportMode_Other, "OFF", "LCD_Display", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({50, 0, Orientation_Up, supportMode_Other, "Auto", "Orientation", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({50, 1, Orientation_Down, supportMode_Other, "UP", "Orientation", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({50, 2, Orientation_Gyro_based, supportMode_Other, "DOWN", "Orientation", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({51, 0, Default_Boot_Mode_Video, supportMode_Other, "Video", "Default_Boot_Mode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({51, 1, Default_Boot_Mode_Photo, supportMode_Other, "Photo", "Default_Boot_Mode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({51, 2, Default_Boot_Mode_MultiShot, supportMode_Other, "MultiShot", "Default_Boot_Mode", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({52, 1, Quick_Capture_On, supportMode_Other, "ON", "Quick_Capture", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({52, 2, Quick_Capture_Off, supportMode_Other, "OFF", "Quick_Capture", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({53, 0, LED_Blink_Off, supportMode_Other, "OFF", "LED_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({53, 1, LED_Blink_2, supportMode_Other, "2 LED", "LED_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({53, 2, LED_Blink_4, supportMode_Other, "4 LED", "LED_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({54, 2, Beeps_Off, supportMode_Other, "Mute", "Volume_beeps", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({54, 1, Beeps_0_7, supportMode_Other, "70%", "Volume_beeps", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({54, 0, Beeps_Full, supportMode_Other, "100%", "Volume_beeps", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({56, 1, Screen_Display_On, supportMode_Other, "ON", "Screen_data", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({56, 0, Screen_Display_Off, supportMode_Other, "OFF", "Screen_data", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({57, 0, LCD_Brightness_High, supportMode_Other, "High", "LCD_Brightness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({57, 1, LCD_Brightness_Medium, supportMode_Other, "Medium", "LCD_Brightness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({57, 2, LCD_Brightness_Low, supportMode_Other, "Low", "LCD_Brightness", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({58, 1, LCD_Lock_On, supportMode_Other, "ON", "LCD_Lock", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({58, 0, LCD_Lock_Off, supportMode_Other, "OFF", "LCD_Lock", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({59, 0, LCD_sleep_Never_sleep, supportMode_Other, "Never sleep", "LCD_sleep", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({59, 1, LCD_sleep_1min_sleep_timeout, supportMode_Other, "1 min sleep", "LCD_sleep", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({59, 2, LCD_sleep_2min_sleep_timeout, supportMode_Other, "2 min sleep", "LCD_sleep", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({59, 3, LCD_sleep_3min_sleep_timeout, supportMode_Other, "3 min sleep", "LCD_sleep", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({60, 0, Auto_Off_Never, supportMode_Other, "Never", "Auto_Power_Off", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({60, 1, Auto_Off_1m, supportMode_Other, "1 min", "Auto_Power_Off", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({60, 2, Auto_Off_2m, supportMode_Other, "2 mins", "Auto_Power_Off", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({60, 3, Auto_Off_3m, supportMode_Other, "3 mins", "Auto_Power_Off", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({60, 4, Auto_Off_5m, supportMode_Other, "5 mins", "Auto_Power_Off", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({62, 0, Get_Gopro_None_Param, supportMode_Other, "No Battery", "Internal_Battery", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({62, 1, Get_Gopro_None_Param, supportMode_Other, "Battery is available", "Internal_Battery", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({63, 4, Get_Gopro_None_Param, supportMode_Other, "Charging", "Battery_Level", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({63, 3, Get_Gopro_None_Param, supportMode_Other, "Full", "Battery_Level", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({63, 2, Get_Gopro_None_Param, supportMode_Other, "Halfway", "Battery_Level", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({63, 1, Get_Gopro_None_Param, supportMode_Other, "Low", "Battery_Level", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({63, 0, Get_Gopro_None_Param, supportMode_Other, "Empty", "Battery_Level", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({65, 0, Get_Gopro_None_Param, supportMode_Other, "Not Streaming", "Streaming_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({65, 1, Get_Gopro_None_Param, supportMode_Other, "Streaming", "Streaming_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({64, 0, Get_Gopro_None_Param, supportMode_Other, "Not recording/Processing", "Processing_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({64, 1, Get_Gopro_None_Param, supportMode_Other, "Recording/processing", "Processing_status", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({66, 0, Get_Gopro_None_Param, supportMode_Other, "Have SD card", "SD_card", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({66, 2, Get_Gopro_None_Param, supportMode_Other, "No SD card", "SD_card", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
    addInfo({67, -1, Get_Gopro_None_Param, supportMode_Other, "Number of Clients", "Number_of_clients", {"HERO4", "HERO5", "HERO6"}, {"Black", "Silver", "Session"}, ""});
}

NAMESPACE_ZY_END
