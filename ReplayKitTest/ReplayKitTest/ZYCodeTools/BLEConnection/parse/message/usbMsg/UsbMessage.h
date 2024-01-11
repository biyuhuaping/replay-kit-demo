//
//  UsbMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBMESSAGE_H__
#define __USBMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "BaseMessage.h"
#include "usbMsgDef.h"

NAMESPACE_ZY_BEGIN

class UsbMessage : public BaseMessage
{
public:
    UsbMessage();
    virtual ~UsbMessage();
    
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 encryption:1; //是否加密(1为加密)
        uint8 type:2;       //0x01:指令, 0x10:媒体数据
        uint8 lenBytes:2;   //0x01表示2字节, 0x11表示4字节
        uint8 errCode:7;    //错误码 0x00无错误
        uint8 re:4;
    } headCode;
#pragma pack(pop)
    virtual BYTE* getHeadPtr() const;
    virtual int getHeadSize() const;
    BYTE* getBuff() const;
    int getBuffSize() const;
    void setBuff(BYTE* buff, int len, bool copy = true, bool freeWithDone = true);
    
    virtual unsigned short getCrc() const;
    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
    static int genUID();
protected:
    BYTE* m_buff;
    int m_buffSize;
    bool m_free;
};

NAMESPACE_ZY_END

#endif /* __USBMESSAGE_H__ */
