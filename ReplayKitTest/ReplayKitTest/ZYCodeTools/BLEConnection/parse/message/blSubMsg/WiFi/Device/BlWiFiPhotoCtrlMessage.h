//
//  BlWiFiPhotoCtrlMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLWIFIPHOTOCTRLMESSAGE_H__
#define __BLWIFIPHOTOCTRLMESSAGE_H__

#include "BlWiFiPhotoMessage.h"

NAMESPACE_ZY_BEGIN

class BlWiFiPhotoCtrlMessage : public BlWiFiPhotoMessage
{
public:
    BlWiFiPhotoCtrlMessage();
    virtual ~BlWiFiPhotoCtrlMessage();
    
    virtual int subPhotoType() const;
    
    bool buildRequest(int photoParamId, int photoCrtlValue);
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 photoCmdType;
        uint8 photoParamId;
        uint8 photoCrtlValue;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLWIFIPHOTOCTRLMESSAGE_H__ */
