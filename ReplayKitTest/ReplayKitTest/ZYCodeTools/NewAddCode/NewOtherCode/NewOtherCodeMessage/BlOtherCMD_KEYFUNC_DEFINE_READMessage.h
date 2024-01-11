//
//  BlOtherCMD_KEYFUNC_DEFINE_READMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMD_KEYFUNC_DEFINE_READMessage_h
#define BlOtherCMD_KEYFUNC_DEFINE_READMessage_h
#include "BlOtherMessage.h"
#include <vector>

NAMESPACE_ZY_BEGIN

class BlOtherCMD_KEYFUNC_DEFINE_READMessage : public BlOtherMessage
{
public:
    BlOtherCMD_KEYFUNC_DEFINE_READMessage();
    virtual ~BlOtherCMD_KEYFUNC_DEFINE_READMessage();
    
    bool buildRequest(uint16 keyInfo);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint16 keyInfo;
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    
    //response:
    std::vector<uint8> keyFunlist;
};

NAMESPACE_ZY_END

#endif /* BlOtherCMD_KEYFUNC_DEFINE_READMessage_h */
