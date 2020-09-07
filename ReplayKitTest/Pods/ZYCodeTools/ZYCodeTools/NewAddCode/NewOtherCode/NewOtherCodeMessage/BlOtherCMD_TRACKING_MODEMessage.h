//
//  BlOtherCMD_TRACKING_MODEMessage.h
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#ifndef BlOtherCMD_TRACKING_MODEMessage_h
#define BlOtherCMD_TRACKING_MODEMessage_h

#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCMD_TRACKING_MODEMessage : public BlOtherMessage
{
public:
    BlOtherCMD_TRACKING_MODEMessage();
    virtual ~BlOtherCMD_TRACKING_MODEMessage();
    
    bool buildRequest(uint8 op,uint8 value);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 op;//op = 0 时代表获取 op = 1 时代表设置
        uint8 value;// 0 代表关闭 1代表开启
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* BlOtherCMD_TRACKING_MODEMessage_h */

