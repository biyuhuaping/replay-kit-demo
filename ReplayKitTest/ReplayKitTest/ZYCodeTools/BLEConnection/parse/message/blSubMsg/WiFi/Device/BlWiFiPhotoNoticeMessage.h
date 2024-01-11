//
//  BlWiFiPhotoNoticeMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIPHOTONOTICEMESSAGE_H__
#define __BLWIFIPHOTONOTICEMESSAGE_H__

#include "BlWiFiPhotoMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiPhotoNoticeMessage : public BlWiFiPhotoMessage
{
public:
    BlWiFiPhotoNoticeMessage();
    virtual ~BlWiFiPhotoNoticeMessage();
    
    virtual int subPhotoType() const;
    
    bool buildRequest(int photoParaId);
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 photoCmdType;
        uint16 photoParamId;
        uint16 photoCrtlValue;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTONOTICEMESSAGE_H__ */
