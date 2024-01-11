//
//  UsbMediaMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBMEDIAMESSAGE_H__
#define __USBMEDIAMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "UsbMessage.h"

NAMESPACE_ZY_BEGIN

class UsbMediaMessage : public UsbMessage
{
public:
    UsbMediaMessage();
    virtual ~UsbMediaMessage();
    
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint16 cmdid;  //编号
        uint16 crc;    //校验码
        uint32 len;    //数据包长度 4字节
    } headContent;
    
    typedef struct {
        headCode code;
        headContent content;
    } head;
#pragma pack(pop)
    virtual BYTE* getHeadPtr() const;
    virtual int getHeadSize() const;
    void setHead(const UsbMediaMessage::head& head);
    UsbMediaMessage::head& getHead() const;
    BYTE* getBody() const;
    int getBodySize() const;
    void setBody(BYTE* body, int len, bool copy = true, bool freeWithDone = true);
    unsigned short getCrc() const;
    void setCrc(unsigned short crc);
    
    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
protected:
    head m_head;
    BYTE* m_body;
    int m_bodySize;
    unsigned short m_crc;
    bool m_free;
};

NAMESPACE_ZY_END

#endif /* __USBMEDIAMESSAGE_H__ */
