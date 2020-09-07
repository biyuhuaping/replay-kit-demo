//
//  BlOtherCMD_TRACKING_ANCHORMessage.h
//  ZYCodeTools
//
//  Created by Liao GJ on 2020/8/13.
//  Copyright © 2020 ZHIYUN. All rights reserved.
//

#ifndef BlOtherCMD_TRACKING_ANCHORMessage_h
#define BlOtherCMD_TRACKING_ANCHORMessage_h
#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCMD_TRACKING_ANCHORMessage : public BlOtherMessage
{
public:
    BlOtherCMD_TRACKING_ANCHORMessage();
    virtual ~BlOtherCMD_TRACKING_ANCHORMessage();
    
    bool buildRequest(uint8 op,uint16 x,uint16 y);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 op;//op = 0 时代表获取 op = 1 时代表设置
        uint16 x;//x,y 为当前锚点位置
        uint16 y;//
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* BlOtherCMD_TRACKING_ANCHORMessage_h */

