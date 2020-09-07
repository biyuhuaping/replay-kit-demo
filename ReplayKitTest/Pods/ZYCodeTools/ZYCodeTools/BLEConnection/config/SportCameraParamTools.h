//
//  SportCameraParamTools.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/6/3.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __SPORT_CAMERA_PARAM_INFO_H__
#define __SPORT_CAMERA_PARAM_INFO_H__

#include <stdio.h>
#include <string>
#include <vector>
#include "common_def.h"

NAMESPACE_ZY_BEGIN

enum {
    supportMode_Video       = 0x01,
    supportMode_Photo       = 0x01 << 1,
    supportMode_MultiShot   = 0x01 << 2,
    supportMode_Other       = 0x01 << 3,
};

typedef struct
{
    int queryCode;          //查询编码
    int queryVal;           //查询值
    int setVal;             //设置值
    int supportMode;        //支持模式
    std::string name;       //参数名
    std::string type;       //参数类型
    std::vector<std::string> supportModels; //支持机型列表
    std::vector<std::string> supportColors; //支持颜色列表
    std::string versionLimit; //最低固件版本
} SportCameraParamInfo;

class SportCameraParamTools
{
public:
    ~SportCameraParamTools();
    static SportCameraParamTools* instance();
    void configDevice(const std::string& deviceName, const std::string& deviceColor);
    void getActiveConfig(std::vector<SportCameraParamInfo>& infos);
    void getSpecificSettings(std::vector<SportCameraParamInfo>& infos, int supportMode, const std::string& type = "", const std::string& name = "");
private:
    SportCameraParamTools();
    void config();
    void addInfo(const SportCameraParamInfo& info);
    static SportCameraParamTools* sm_instance;
    std::vector<SportCameraParamInfo> m_infos;
    std::vector<SportCameraParamInfo> m_activeInfos;
    std::string m_deviceName;
    std::string m_deviceColor;
};

NAMESPACE_ZY_END

#endif /* __SPORT_CAMERA_PARAM_INFO_H__ */
