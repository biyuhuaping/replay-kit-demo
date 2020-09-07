//
//  BlStoryCtrlPositionMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlStoryCtrlPositionMessage_h
#define BlStoryCtrlPositionMessage_h
#include "BlStoryMessage.h"

NAMESPACE_ZY_BEGIN

class BlStoryCtrlPositionMessage : public BlStoryMessage
{
public:
    BlStoryCtrlPositionMessage();
    virtual ~BlStoryCtrlPositionMessage();
    
    bool buildRequest(uint16 pitchDegree,uint16 rollDegree,uint16 yawDegree,uint16 duration);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint16 pitchDegree;
        uint16 rollDegree;
        uint16 yawDegree;
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
#endif /* BlStoryCtrlPositionMessage_h */
