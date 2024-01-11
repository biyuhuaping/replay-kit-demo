//
//  BlOtherCMDDeviceTypeMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/21.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMDDeviceTypeMessage_h
#define BlOtherCMDDeviceTypeMessage_h
#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCMDDeviceTypeMessage : public BlOtherMessage
{
public:
    BlOtherCMDDeviceTypeMessage();
    virtual ~BlOtherCMDDeviceTypeMessage();
    
    bool buildRequest(uint8 direct, uint8 type);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 direct;//获取设备类型 0x80 设置设备类型0x00
        uint8 type;//0卡片机 1手机
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END


#endif /* BlOtherCMDDeviceTypeMessage_h */
