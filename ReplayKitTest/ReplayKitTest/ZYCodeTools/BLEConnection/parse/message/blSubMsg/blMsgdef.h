//
//  common_def.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BL_DEF_H__
#define __BL_DEF_H__

#define BL_HEAD_CODE_SEND 0x3C24
#define BL_HEAD_CODE_RECV 0x3E24

#include "common_def.h"

//zyble 指令
extern const uint8 ZYBleInteractSync;           //同步及获取设备信息
extern const uint8 ZYBleInteractUpdateWrite;    //向设备写入固件
extern const uint8 ZYBleInteractCheck;          //校验设备固件
extern const uint8 ZYBleInteractByPass;         //旁路设备，使其向下转发所接收的命令
extern const uint8 ZYBleInteractReset;          //重启设备
extern const uint8 ZYBleInteractAppgo;          //运行设备
extern const uint8 ZYBleInteractBootReset;      //重启设备并进入升级模式
extern const uint8 ZYBleInteractEvent;          //其他控制指令

//zyble event指令的子类型
extern const uint8 ZYBleInteractEventBle;       //蓝牙控制事件
extern const uint8 ZYBleInteractEventAsyn;      //异步传输事件   超时时间200ms
extern const uint8 ZYBleInteractEventJoystick;  //摇杆/拨轮事件
extern const uint8 ZYBleInteractEventAngle;     //角度/拨轮事件
extern const uint8 ZYBleInteractEventRdis;      //RDIS控制数据事件
extern const uint8 ZYBleInteractEventHandle;    //手柄事件      超时时间200ms
extern const uint8 ZYBleInteractEventWifi;      //wifi控制事件
extern const uint8 ZYBleInteractEventOther;     //其他控制事件
extern const uint8 ZYBleInteractEventCCS;       //相机控制系统事件
extern const uint8 ZYBleInteractEventHDL;    //HDL手柄事件
extern const uint8 ZYBleInteractEventSTORY;    //STORY事件
#pragma -mark 协议里面没有，暂时保留这个key
extern const uint8 ZYBleInteractEventTrack;    //跟踪事件
//zyble wifi控制事件的子类型
extern const uint8 ZYBIWiFiDeviceCmdKey;           //200ms    传输键值
extern const uint8 ZYBIWiFiDeviceCmdStatus;        //200ms    获取wifi模块状态
extern const uint8 ZYBIWiFiDeviceCmdEnable;        //200ms    使能/关闭WIFI模块
extern const uint8 ZYBIWiFiDeviceCmdScan;          //200ms    开始/停止扫描
extern const uint8 ZYBIWiFiDeviceCmdConnect;       //200ms    连接wifi设备
extern const uint8 ZYBIWiFiDeviceCmdClean;         //200ms    清除连接设备信息
extern const uint8 ZYBIWiFiDeviceCmdDevice;        //200ms    获取扫描到的设备信息
extern const uint8 ZYBIWiFiDeviceCmdErr;           //200ms    获取错误代码
extern const uint8 ZYBIWiFiDeviceCmdDisconnect;    //200ms    中断连接
extern const uint8 ZYBIWiFiDeviceCmdPhoto;         //200ms    相机控制相关指令

extern const uint8 ZYBIWiFiHotspotCmdStatus;        //获取wifi模块状态
extern const uint8 ZYBIWiFiHotspotCmdEnable;        //使能WIFI模块
extern const uint8 ZYBIWiFiHotspotCmdDisable;       //禁能WIFI模块
extern const uint8 ZYBIWiFiHotspotCmdReset;         //重启wifi模块
extern const uint8 ZYBIWiFiHotspotCmdDhcpClean;     //清除DHCP池中的设备信息
extern const uint8 ZYBIWiFiHotspotCmdGetSSID;       //获取wifi SSID
extern const uint8 ZYBIWiFiHotspotCmdPSW;           //获取wifi模块密码
extern const uint8 ZYBIWiFiHotspotCmdSetPSW;        //设置wifi模块密码
extern const uint8 ZYBIWiFiHotspotCmdCHN;           //获取，和设置wifi模块信道
extern const uint8 ZYBIWiFiHotspotCmdGET_CHNLIST;   //获取wifi模块支持的信道列表
extern const uint8 ZYBIWiFiHotspotCmdCHN_SCAN;      //设置和获取wifi周围的信道信息

//zyble wifi 关闭和打开
extern const uint8 ZYBleInteractWifiON;     //开
extern const uint8 ZYBleInteractWifiOFF;    //关

extern const uint8 ZYBleInteractWifiStatusOff;          //wifi未开启
extern const uint8 ZYBleInteractWifiStatusOn;           //wifi已开启
extern const uint8 ZYBleInteractWifiStatusScan;         //扫描中
extern const uint8 ZYBleInteractWifiStatusConnecting;   //wifi连接中
extern const uint8 ZYBleInteractWifiStatusConnect;      //wifi已连接
extern const uint8 ZYBleInteractWifiStatusDisconnect;   //wifi断开
extern const uint8 ZYBleInteractWifiStatusError;        //错误状态
extern const uint8 ZYBleInteractWifiStatusConnectAndScan;  //已连接并且在扫描中

extern const uint8 ZYBleInteractWifiHotspotStatusOff;   //wifi未开启
extern const uint8 ZYBleInteractWifiHotspotStatusOn;    //wifi已开启
extern const uint8 ZYBleInteractWifiHotspotStatusErr;   //错误状态

extern const uint8 ZYBleInteractWifiCmdPhotoInfo;    //200 查询相机设备信息
extern const uint8 ZYBleInteractWifiCmdPhotoParam;   //200 查询相机参数信息
extern const uint8 ZYBleInteractWifiCmdPhotoCtrl;    //200 发送相机控制命令
extern const uint8 ZYBleInteractWifiCmdPhotoNotice;  //200 通知参数变更
extern const uint8 ZYBleInteractWifiCmdPhotoParams;  //200 一次性获取参数
extern const uint8 ZYBleInteractWifiCmdCameraInfo;   //400 获取、设置相机型

extern const uint8 ZYBIWPModelNumber;               //相机型号  "19"
extern const uint8 ZYBIWPModelName;                 //相机名    "HERO5 Black"
extern const uint8 ZYBIWPFirmwareVersion;           //序列号    "HD5.02.02.60.00"
extern const uint8 ZYBIWPSerialNumber;              //版本号    "C3161325213315"
extern const uint8 ZYBIWPBoardType;                 //版型    "0x05"
extern const uint8 ZYBIWPApMac;                     //mac地址    "f6dd9e56f363"
extern const uint8 ZYBIWPApSsid;                    //ssid    "GP25213315"
extern const uint8 ZYBIWPApHasDefaultCredentials;   //有默认凭据    "0"
extern const uint8 ZYBIWPCapabilities;              //功能    "16"

extern const uint8 ZYBIWSDisconnectFail;             //断开连接失败
extern const uint8 ZYBIWSDisconnectSuccess;          //断开连接成功

extern const uint8 ZYBICCSCmdSetConfigValue;    //设定指定CONFIG当前值
extern const uint8 ZYBICCSCmdGetConfigValue;    //获取指定CONFIG当前值
extern const uint8 ZYBICCSCmdGetConfigItems;    //获取指定CONFIG的可用项列表
extern const uint8 ZYBICCSCmdAns;               //相机控制应答指令

extern const uint8 ZYBICCSCmdStatusNoErr;   //无错误
extern const uint8 ZYBICCSCmdStatusGenErr;  //通用错误
extern const uint8 ZYBICCSCmdStatusWait;    //等待通知

extern const uint8 ZYBIOtherCmdCheckMD5;    //MD5值校验
extern const uint8 ZYBIOtherCmdFileAsyn;    //文件是否异步传输
extern const uint8 ZYBIOtherCmdUpdateState; //图传板的升级状态
extern const uint8 ZYBIOtherCmdDeviceInfo;  //检查当前设备能否控制图传设备
extern const uint8 ZYBIOtherCmdSystemTime;  //同步手机，稳定器系统时间
extern const uint8 ZYBIOtherCmdCustomFile;  //传输文件
extern const uint8 ZYBIOtherCmdSyncData;    //同步数据
extern const uint8 ZYBIOtherCmdPathData;    //查询轨迹拍摄信息
extern const uint8 ZYBIOtherCmdDeviceType;  //稳定器搭载的设备类型
extern const uint8 ZYBIOtherCmdMoveLineStatue;  //1：暂停 2：结束 3：开始 4.移动中
extern const uint8 ZYBIOtherCmdOTAWAIT;     // 传输数据包完成之后是否需要等待设备进度
extern const uint8 ZYBIOtherHeart; // 心跳

extern const uint8 ZYBIOtherKEYFUNC_DEFINE_SET; // 重新定义按键映射功能
extern const uint8 ZYBIOtherKEYFUNC_DEFINE_READ; // 重新定义按键映射功能
extern const uint8 ZYBIOtherCHECK_ACTIVEINFO; // 查询激活状态信息
extern const uint8 ZYBIOtherSET_ACTIVEINFO; // 发送激活密钥
extern const uint8 ZYBIOtherCMD_LOG_READ ; // 读LOG数据
extern const uint8 ZYBIOtherTRACKING_MODE ; // 设置自动跟踪模式
extern const uint8 ZYBIOtherTRACKING_ANCHOR; // 设置跟踪时的锚点


extern const uint8 ZYBIOtherCmdValueFileSyn;        //文件同步传输
extern const uint8 ZYBIOtherCmdValueFileAsyn;       //文件异步传输

extern const uint8 ZYBIOtherCmdDeviceInfoFree;     //设备可控
extern const uint8 ZYBIOtherCmdDeviceInfoBusy;     //设备不可控

extern const uint8 ZYHDL_CMD_FACTORY_MODE; //进入、退出工程模式
extern const uint8 ZYHDL_CMD_FACTORY_SHOW ; //工程模式界面显示指定字符串
extern const uint8 ZYBIHDL_CMD_FACTORY_TEST ; //执行工程模式测试项
extern const uint8 ZYBlHDL_CMD_SHOW_INFO ; //显示指定提示画面

extern const uint8 ZYBIOtherHeartAppOrigin;//原生app(zyplay)
extern const uint8 ZYBIOtherHeartAppOther;     //第三方app
//zy STORY事件的控制子命令
extern const uint8 ZYBISTORY_CMD_CTRL_POSITION;//角度控制
extern const uint8 ZYBISTORY_CMD_CTRL_SPEED;//速度控制

#define MAX_NAME_SIZE 32

#endif /* __BL_DEF_H__ */
