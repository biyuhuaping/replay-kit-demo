//
//  BlOtherCMDSyncDataMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2019/4/22.
//  Copyright © 2019 ZYAPPTEAM. All rights reserved.
//

#ifndef BlOtherCMDSyncDataMessage_h
#define BlOtherCMDSyncDataMessage_h
#include "BlOtherMessage.h"
#include "ccsTool.h"
#include <vector>
NAMESPACE_ZY_BEGIN

class BlOtherCMDSyncDataMessage : public BlOtherMessage
{
public:
    BlOtherCMDSyncDataMessage();
    virtual ~BlOtherCMDSyncDataMessage();
    
    bool buildRequest(int configIdx,uint8 msgId);
    virtual bool buildResponse(BYTE* data, int size);
    virtual int subType() const;
private:
#pragma pack(push)
#pragma pack(1)
    typedef struct {
        uint8 cmdType;
        uint8 msgId;//0为通知，其他为需要回复
    } MSG_BODY;
#pragma pack(pop)
public:
    union {
        MSG_BODY body;
        BYTE buff[1];
    } m_data;
    std::vector<ccs_sync_value> m_itemlist;
};

NAMESPACE_ZY_END


#endif /* BlOtherCMDSyncDataMessage_h */
