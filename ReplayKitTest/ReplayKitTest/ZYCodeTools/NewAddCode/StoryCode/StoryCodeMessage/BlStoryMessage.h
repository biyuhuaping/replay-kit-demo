//
//  BlStoryMessage.h
//  ZYCamera
//
//  Created by Liao GJ on 2020/2/12.
//  Copyright © 2020 ZYAPPTEAM. All rights reserved.
//

#ifndef BlStoryMessage_h
#define BlStoryMessage_h

#include "BlMessage.h"

NAMESPACE_ZY_BEGIN

class BlStoryMessage : public BlMessage
{
public:
    BlStoryMessage();
    virtual ~BlStoryMessage();
    
    virtual int subType() const;
};

NAMESPACE_ZY_END

#endif /* BlStoryMessage_h */
