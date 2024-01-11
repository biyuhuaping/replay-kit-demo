//
//  BlMessage.hpp
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __USBINSTRUCTIONMESSAGE_H__
#define __USBINSTRUCTIONMESSAGE_H__

#include <stdio.h>
#include "common_def.h"
#include "UsbMessage.h"

NAMESPACE_ZY_BEGIN

class UsbInstructionMessage : public UsbMessage
{
public:
    UsbInstructionMessage();
    virtual ~UsbInstructionMessage();
    
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint16 cmdid;  //编号
        uint16 crc;    //校验码
        uint16 len;    //数据包长度 2字节
    } headContent;
    
    typedef struct {
        headCode code;
        headContent content;
    } head;
#pragma pack(pop)
    virtual BYTE* getHeadPtr() const;
    virtual int getHeadSize() const;
    
    void setHead(const head& head);
    head& getHead() const;
    
    virtual unsigned short getCrc() const;
    
    virtual bool buildResponse(BYTE* data, int size);
    virtual int messageType() const;
protected:
    head m_head;
    uint8 m_codeType;
    unsigned short m_crc;
};

NAMESPACE_ZY_END

#endif /* __USBINSTRUCTIONMESSAGE_H__ */
