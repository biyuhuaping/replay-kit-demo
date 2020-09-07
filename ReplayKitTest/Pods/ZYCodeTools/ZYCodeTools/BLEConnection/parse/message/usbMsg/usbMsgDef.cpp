//
//  BlMessage.cpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#include "usbMsgDef.h"
#include "common_def.h"

const uint8 UsbMessageDecrytion = 0x00;         //不加密
const uint8 UsbMessageEncrytion = 0x01;         //加密

const uint8 UsbMessageTypeInstruction = 0x01;   //指令
const uint8 UsbMessageTypeMedia = 0x10;         //媒体数据

const uint8 UsbMessageLen2Bytes = 0x01;         //指令
const uint8 UsbMessageLen4Bytes = 0x10;         //媒体数据

const uint8 UsbMessageErrCodeNone = 0x00;       //无错误

const uint16 ZYUMTBase = 0x0000;
const uint16 ZYUMTInstruction = 0x0100;
const uint16 ZYUMTInstructionStar = 0x0100;
const uint16 ZYUMTInstructionBl = 0x0101;
const uint16 ZYUMTInstructionMS = 0x0102;
const uint16 ZYUMTInstructionHB = 0x0103;
const uint16 ZYUMTMedia = 0x0200;

const uint8 UsbMessageCodeStar = 0x00;          //star指令
const uint8 UsbMessageCodeZybl = 0x01;          //zybl指令
const uint8 UsbMessageCodeMediaStream = 0x02;   //媒体流指令
const uint8 UsbMessageCodeHeartBeat = 0x03;     //心跳指令

const uint8 UMCMediaStreamStatusSuccess     = 0x00;    //连接成功
const uint8 UMCMediaStreamStatusOtherUsb    = 0x01;    //连接请求失败，已经usb连接一台手机
const uint8 UMCMediaStreamStatusOtherWiFi   = 0x02;    //连接请求失败，已经wifi连接一台手机
const uint8 UMCMediaStreamStatusErr         = 0x03;    //连接请求失败，指令出错
const uint8 UMCMediaStreamStatusOpened      = 0x04;    //已经开启媒体数据流
const uint8 UMCMediaStreamStatusClosed      = 0x05;    //已近关闭媒体数据流
const uint8 UMCMediaStreamStatusUnknownErr  = 0x06;    //其它未定义错误


const uint8 UMCMediaStreamStatusClose   = 0x00;    //关闭
const uint8 UMCMediaStreamStatusOpen    = 0x01;    //打开
const uint8 UMCMediaStreamStatusQuery   = 0x02;    //查询媒体流状态



