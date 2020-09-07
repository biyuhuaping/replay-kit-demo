//
//  BlOtherCMD_KEYFUNC_DEFINE_SETMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMD_KEYFUNC_DEFINE_SETMessage_h
#define BlOtherCMD_KEYFUNC_DEFINE_SETMessage_h
#include "BlOtherMessage.h"

NAMESPACE_ZY_BEGIN

class BlOtherCMD_KEYFUNC_DEFINE_SETMessage : public BlOtherMessage
{
public:
    BlOtherCMD_KEYFUNC_DEFINE_SETMessage();
    virtual ~BlOtherCMD_KEYFUNC_DEFINE_SETMessage();
    
    bool buildRequest(uint16 keyInfo,uint8 keyFun);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint16 keyInfo;
        uint8 keyFun;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
};

NAMESPACE_ZY_END

#endif /* BlOtherCMD_KEYFUNC_DEFINE_SETMessage_h */
