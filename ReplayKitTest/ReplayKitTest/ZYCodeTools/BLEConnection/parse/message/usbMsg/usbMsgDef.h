//
//  usbMsgDef.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USB_MSG_DEF_H__
#define __USB_MSG_DEF_H__


#include "common_def.h"

extern const uint16 ZYUMTBase;
extern const uint16 ZYUMTInstruction;
extern const uint16 ZYUMTInstructionStar;
extern const uint16 ZYUMTInstructionBl;
extern const uint16 ZYUMTInstructionMS;
extern const uint16 ZYUMTInstructionHB;
extern const uint16 ZYUMTMedia;

extern const uint8 UsbMessageDecrytion;         //不加密
extern const uint8 UsbMessageEncrytion;         //加密

extern const uint8 UsbMessageTypeInstruction;   //指令
extern const uint8 UsbMessageTypeMedia;         //媒体数据

extern const uint8 UsbMessageLen2Bytes;         //指令
extern const uint8 UsbMessageLen4Bytes;         //媒体数据

extern const uint8 UsbMessageErrCodeNone;       //无错误

extern const uint8 UsbMessageCodeStar;          //star指令
extern const uint8 UsbMessageCodeZybl;          //zybl指令
extern const uint8 UsbMessageCodeMediaStream;   //媒体流指令
extern const uint8 UsbMessageCodeHeartBeat;     //心跳指令

extern const uint8 UMCMediaStreamStatusSuccess;        //连接成功
extern const uint8 UMCMediaStreamStatusOtherUsb;       //连接请求失败，已经usb连接一台手机
extern const uint8 UMCMediaStreamStatusOtherWiFi;      //连接请求失败，已经wifi连接一台手机
extern const uint8 UMCMediaStreamStatusErr;            //连接请求失败，指令出错

extern const uint8 UMCMediaStreamStatusClose;          //关闭
extern const uint8 UMCMediaStreamStatusOpen;           //打开



#endif /* __USB_MSG_DEF_H__ */
