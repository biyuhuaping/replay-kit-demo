//
//  BlTrackMessage.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/5/8.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __BLTRACKMESSAGE_H__
#define __BLTRACKMESSAGE_H__

#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlTrackMessage : public BlMessage
{
public:
    BlTrackMessage();
    virtual ~BlTrackMessage();
    
    bool buildRequest(int16 xOffset, int16 yOffset);
    virtual bool buildResponse(BYTE* data, int size);
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        int16 xOffset;
        int16 yOffset;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* __BLTRACKMESSAGE_H__ */
