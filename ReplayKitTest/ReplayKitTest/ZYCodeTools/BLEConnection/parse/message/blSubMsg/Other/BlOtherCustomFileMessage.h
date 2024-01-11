//
//  BlOtherCustomFileMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/10.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLOTHERCUSTOMFILEMESSAGE_H__
#define __BLOTHERCUSTOMFILEMESSAGE_H__

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCustomFileMessage : public BlOtherMessage
{
public:
    BlOtherCustomFileMessage();
    virtual ~BlOtherCustomFileMessage();
    
    bool buildRequest(int page,uint8 direction,uint8 dataLen, BYTE* data = NULL);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint16 page;
        uint8 direction;
        BYTE data[10];
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLOTHERCUSTOMFILEMESSAGE_H__ */
