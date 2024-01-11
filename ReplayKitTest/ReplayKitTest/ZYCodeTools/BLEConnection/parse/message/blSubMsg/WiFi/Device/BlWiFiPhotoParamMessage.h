//
//  BlWiFiPhotoInfoMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIPHOTOPARAMMESSAGE_H__
#define __BLWIFIPHOTOPARAMMESSAGE_H__

#include "BlWiFiPhotoMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiPhotoParamMessage : public BlWiFiPhotoMessage
{
public:
    BlWiFiPhotoParamMessage();
    virtual ~BlWiFiPhotoParamMessage();
    
    virtual int subPhotoType() const;
    int subPhotoParamId() const;
    
    bool buildRequest(int photoParaId);
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 photoCmdType;
        uint8 photoParamId;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    //respond
    uint16 m_photoParamValue;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTOINFOMESSAGE_H__ */
