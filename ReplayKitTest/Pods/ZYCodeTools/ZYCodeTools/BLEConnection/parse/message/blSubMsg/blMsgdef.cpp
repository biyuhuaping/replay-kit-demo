//
//  BlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "blMsgdef.h"
#include "common_def.h"

#define MakeWiFiCode(device, code) ((device&0xE0)|(code&0x1F))

const uint8 WiFiDevice           = 0x00;
const uint8 WiFiHotspot          = 0x20;

//zyble 指令
const uint8 ZYBleInteractSync           = 0x01;
const uint8 ZYBleInteractUpdateWrite    = 0x02;
const uint8 ZYBleInteractCheck          = 0x03;
const uint8 ZYBleInteractByPass         = 0x04;
const uint8 ZYBleInteractReset          = 0x05;
const uint8 ZYBleInteractAppgo          = 0x06;
const uint8 ZYBleInteractBootReset      = 0x07;
const uint8 ZYBleInteractEvent          = 0x08;

//zyble event指令的子类型
const uint8 ZYBleInteractEventBle       = 0x11;    //蓝牙控制事件
const uint8 ZYBleInteractEventAsyn      = 0x12;    //异步传输事件   超时时间200ms
const uint8 ZYBleInteractEventJoystick  = 0x13;    //摇杆/拨轮事件
const uint8 ZYBleInteractEventAngle     = 0x14;    //角度/拨轮事件
const uint8 ZYBleInteractEventRdis      = 0x15;    //RDIS控制数据事件
const uint8 ZYBleInteractEventHandle    = 0x16;    //手柄事件      超时时间200ms
const uint8 ZYBleInteractEventWifi      = 0x17;    //wifi控制事件
const uint8 ZYBleInteractEventOther     = 0x18;    //其他控制事件
const uint8 ZYBleInteractEventCCS       = 0x19;    //相机控制系统事件
const uint8 ZYBleInteractEventHDL       = 0x1A;    //HDL手柄事件
const uint8 ZYBleInteractEventSTORY     = 0x1C;    //STORY事件
#pragma -mark 协议里面没有，暂时保留这个key
const uint8 ZYBleInteractEventTrack     = 0x1D;    //跟踪事件

//zyble wifi控制事件的子类型
const uint8 ZYBleInteractWifiCmdKey         = 0x01;  //200ms    传输键值
const uint8 ZYBleInteractWifiCmdStatus      = 0x02;  //200ms    获取wifi模块状态
const uint8 ZYBleInteractWifiCmdEnable      = 0x03;  //200ms    使能/关闭WIFI模块
const uint8 ZYBleInteractWifiCmdScan        = 0x04;  //200ms    开始/停止扫描
const uint8 ZYBleInteractWifiCmdConnect     = 0x05;  //200ms    连接wifi设备
const uint8 ZYBleInteractWifiCmdClean       = 0x06;  //200ms    清除连接设备信息
const uint8 ZYBleInteractWifiCmdDevice      = 0x07;  //200ms    获取扫描到的设备信息
const uint8 ZYBleInteractWifiCmdErr         = 0x08;  //200ms    获取错误代码
const uint8 ZYBleInteractWifiCmdDisconnect  = 0x09;  //200ms    中断连接
const uint8 ZYBleInteractWifiCmdPhoto       = 0x0B;  //200ms    相机控制相关指令

const uint8 ZYBleInteractWifiStatus         = 0x01;  //获取wifi模块状态
const uint8 ZYBleInteractWifiEnable         = 0x02;  //使能WIFI模块
const uint8 ZYBleInteractWifiDisable        = 0x03;  //禁能WIFI模块
const uint8 ZYBleInteractWifiReset          = 0x04;  //重启wifi模块
const uint8 ZYBleInteractWifiDhcpClean      = 0x05;  //清除DHCP池中的设备信息
const uint8 ZYBleInteractWifiGetSSID        = 0x06;  //获取wifi SSID
const uint8 ZYBleInteractWifiPSW            = 0x07;  //获取wifi模块密码
const uint8 ZYBleInteractWifiSetPSW         = 0x08;  //设置wifi模块密码
const uint8 ZYBleInteractWifiCHN            = 0x09;  //获取，和设置wifi模块信道
const uint8 ZYBleInteractWifiGET_CHNLIST    = 0x0A;  //获取wifi模块支持的信道列表
const uint8 ZYBleInteractWifiCHN_SCAN       = 0x0B;  //设置和获取wifi周围的信道信息

const uint8 ZYBIWiFiDeviceCmdKey            = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdKey);           //200ms    传输键值
const uint8 ZYBIWiFiDeviceCmdStatus         = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdStatus);        //200ms    获取wifi模块状态
const uint8 ZYBIWiFiDeviceCmdEnable         = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdEnable);        //200ms    使能/关闭WIFI模块
const uint8 ZYBIWiFiDeviceCmdScan           = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdScan);          //200ms    开始/停止扫描
const uint8 ZYBIWiFiDeviceCmdConnect        = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdConnect);       //200ms    连接wifi设备
const uint8 ZYBIWiFiDeviceCmdClean          = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdClean);         //200ms    清除连接设备信息
const uint8 ZYBIWiFiDeviceCmdDevice         = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdDevice);        //200ms    获取扫描到的设备信息
const uint8 ZYBIWiFiDeviceCmdErr            = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdErr);           //200ms    获取错误代码
const uint8 ZYBIWiFiDeviceCmdDisconnect     = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdDisconnect);    //200ms    中断连接
const uint8 ZYBIWiFiDeviceCmdPhoto          = MakeWiFiCode(WiFiDevice, ZYBleInteractWifiCmdPhoto);         //200ms    相机控制相关指令

const uint8 ZYBIWiFiHotspotCmdStatus        = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiStatus);       //获取wifi模块状态
const uint8 ZYBIWiFiHotspotCmdEnable        = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiEnable);       //使能WIFI模块
const uint8 ZYBIWiFiHotspotCmdDisable       = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiDisable);      //禁能WIFI模块
const uint8 ZYBIWiFiHotspotCmdReset         = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiReset);        //重启wifi模块
const uint8 ZYBIWiFiHotspotCmdDhcpClean     = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiDhcpClean);    //清除DHCP池中的设备信息
const uint8 ZYBIWiFiHotspotCmdGetSSID       = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiGetSSID);      //获取wifi SSID
const uint8 ZYBIWiFiHotspotCmdPSW           = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiPSW);          //获取wifi模块密码
const uint8 ZYBIWiFiHotspotCmdSetPSW        = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiSetPSW);          //设置wifi模块密码
const uint8 ZYBIWiFiHotspotCmdCHN           = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiCHN);          //获取，和设置wifi模块信道
const uint8 ZYBIWiFiHotspotCmdGET_CHNLIST   = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiGET_CHNLIST);          //获取wifi模块支持的信道列表
const uint8 ZYBIWiFiHotspotCmdCHN_SCAN      = MakeWiFiCode(WiFiHotspot, ZYBleInteractWifiCHN_SCAN);          //设置和获取wifi周围的信道信息

const uint8 ZYBleInteractWifiON   = 0x01;  //开
const uint8 ZYBleInteractWifiOFF  = 0x00;  //关

const uint8 ZYBleInteractWifiStatusOff          = 0x00;    //wifi未开启
const uint8 ZYBleInteractWifiStatusOn           = 0x01;    //wifi已开启
const uint8 ZYBleInteractWifiStatusScan         = 0x02;    //扫描中
const uint8 ZYBleInteractWifiStatusConnecting   = 0x03;    //wifi连接中
const uint8 ZYBleInteractWifiStatusConnect      = 0x05;    //wifi已连接
const uint8 ZYBleInteractWifiStatusDisconnect   = 0x06;    //wifi断开
const uint8 ZYBleInteractWifiStatusError        = 0x07;    //错误状态
const uint8 ZYBleInteractWifiStatusConnectAndScan = 0x08;  //已连接并且在扫描中

const uint8 ZYBleInteractWifiHotspotStatusOff          = 0x00;    //wifi未开启
const uint8 ZYBleInteractWifiHotspotStatusOn           = 0x01;    //wifi已开启
const uint8 ZYBleInteractWifiHotspotStatusErr          = 0x02;    //错误状态

const uint8 ZYBleInteractWifiCmdPhotoInfo    = 0x01;    //200 查询相机设备信息
const uint8 ZYBleInteractWifiCmdPhotoParam   = 0x02;    //200 查询相机参数信息
const uint8 ZYBleInteractWifiCmdPhotoCtrl    = 0x03;    //200 发送相机控制命令
const uint8 ZYBleInteractWifiCmdPhotoNotice  = 0x04;    //200 通知参数变更
const uint8 ZYBleInteractWifiCmdPhotoParams  = 0x05;    //200 一次性获取参数
const uint8 ZYBleInteractWifiCmdCameraInfo   = 0x06;    //400 获取、设置相机型

const uint8 ZYBIWPModelNumber                   = 0x01; //相机型号  "19"
const uint8 ZYBIWPModelName                     = 0x02; //相机名    "HERO5 Black"
const uint8 ZYBIWPFirmwareVersion               = 0x03; //序列号    "HD5.02.02.60.00"
const uint8 ZYBIWPSerialNumber                  = 0x04; //版本号    "C3161325213315"
const uint8 ZYBIWPBoardType                     = 0x05; //版型    "0x05"
const uint8 ZYBIWPApMac                         = 0x06; //mac地址    "f6dd9e56f363"
const uint8 ZYBIWPApSsid                        = 0x07; //ssid    "GP25213315"
const uint8 ZYBIWPApHasDefaultCredentials       = 0x08; //有默认凭据    "0"
const uint8 ZYBIWPCapabilities                  = 0x09; //功能    "16"

const uint8 ZYBIWSDisconnectFail             = 0x00; //断开连接失败
const uint8 ZYBIWSDisconnectSuccess          = 0x01; //断开连接成功

const uint8 ZYBICCSCmdSetConfigValue    = 0x01; //设定指定CONFIG当前值
const uint8 ZYBICCSCmdGetConfigValue    = 0x02; //获取指定CONFIG当前值
const uint8 ZYBICCSCmdGetConfigItems    = 0x03; //获取指定CONFIG的可用项列表
const uint8 ZYBICCSCmdAns               = 0x04; //相机控制应答指令

const uint8 ZYBICCSCmdStatusNoErr       = 0x00; //无错误
const uint8 ZYBICCSCmdStatusGenErr      = 0x01; //通用错误
const uint8 ZYBICCSCmdStatusWait        = 0x02; //等待通知

const uint8 ZYBIOtherCmdCheckMD5    = 0x01; //MD5值校验
const uint8 ZYBIOtherCmdFileAsyn    = 0x02; //文件是否异步传输
const uint8 ZYBIOtherCmdUpdateState = 0x03; //图传板的升级状态
const uint8 ZYBIOtherCmdDeviceInfo  = 0x04; //检查当前设备能否控制图传设备
const uint8 ZYBIOtherCmdSystemTime  = 0x05; //同步手机，稳定器系统时间
const uint8 ZYBIOtherCmdCustomFile  = 0x06; //传输文件
const uint8 ZYBIOtherCmdSyncData    = 0x07; //同步数据
const uint8 ZYBIOtherCmdPathData    = 0x08; //查询轨迹拍摄信息
const uint8 ZYBIOtherCmdDeviceType  = 0x09; //稳定器搭载的设备类型
const uint8 ZYBIOtherCmdMoveLineStatue  = 0x0A; //1：暂停 2：结束 3：开始 4.移动中
const uint8 ZYBIOtherCmdOTAWAIT         = 0x0B; // 传输数据包完成之后是否需要等待设备进度
const uint8 ZYBIOtherHeart               = 0x10; // 心跳

const uint8 ZYBIOtherKEYFUNC_DEFINE_SET  = 0x11; // 重新定义按键映射功能
const uint8 ZYBIOtherKEYFUNC_DEFINE_READ = 0x12; // 重新定义按键映射功能
const uint8 ZYBIOtherCHECK_ACTIVEINFO    = 0x13; // 查询激活状态信息
const uint8 ZYBIOtherSET_ACTIVEINFO      = 0x14; // 发送激活密钥
const uint8 ZYBIOtherCMD_LOG_READ        = 0x15; // 读LOG数据
const uint8 ZYBIOtherTRACKING_MODE       = 0x16; // 设置自动跟踪模式
const uint8 ZYBIOtherTRACKING_ANCHOR     = 0x17; // 设置跟踪时的锚点

const uint8 ZYBIOtherCmdValueFileSyn    = 0x00;     //文件同步传输
const uint8 ZYBIOtherCmdValueFileAsyn   = 0x01;     //文件异步传输

const uint8 ZYBIOtherCmdDeviceInfoFree  = 0x00;     //设备可控
const uint8 ZYBIOtherCmdDeviceInfoBusy  = 0x01;     //设备不可控

const uint8 ZYHDL_CMD_FACTORY_MODE      = 0x01; //进入、退出工程模式
const uint8 ZYHDL_CMD_FACTORY_SHOW      = 0x02; //工程模式界面显示指定字符串
const uint8 ZYBIHDL_CMD_FACTORY_TEST    = 0x03; //执行工程模式测试项
const uint8 ZYBlHDL_CMD_SHOW_INFO       = 0x04; //显示指定提示画面

const uint8 ZYBIOtherHeartAppOrigin    = 0x00;     //原生app(zyplay)
const uint8 ZYBIOtherHeartAppOther     = 0x01;     //第三方app

//zy STORY事件的控制子命令
const uint8 ZYBISTORY_CMD_CTRL_POSITION = 0x01;//角度控制
const uint8 ZYBISTORY_CMD_CTRL_SPEED = 0x02;//速度控制


