//
//  BlStoryCtrlSpeedMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlStoryCtrlSpeedMessage_h
#define BlStoryCtrlSpeedMessage_h
#include "BlStoryMessage.h"

NAMESPACE_ZY_BEGIN

class BlStoryCtrlSpeedMessage : public BlStoryMessage
{
public:
    BlStoryCtrlSpeedMessage();
    virtual ~BlStoryCtrlSpeedMessage();
    
    bool buildRequest(uint16 pitchSpeed,uint16 rollSpeed,uint16 yawSpeed,uint16 duration);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint16 pitchSpeed;
        uint16 rollSpeed;
        uint16 yawSpeed;
        uint16 duration;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    
};

NAMESPACE_ZY_END

#endif /* BlStoryCtrlSpeedMessage_h */
