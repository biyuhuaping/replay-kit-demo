//
//  common_def.h
//  ZYCamera
//
//  Created by Frost Zhang on 2018/2/11.
//  Copyright © 2018年 ZYAPPTEAM. All rights reserved.
//

#ifndef __CCS_TOOL_H__
#define __CCS_TOOL_H__

#include "common_def.h"
#include <vector>
#include <string>

NAMESPACE_ZY_BEGIN

typedef struct {
    uint16 configIdx;
    std::string value;
} ccs_item_value;

typedef struct {
    uint8 configIdx;
    std::string value;
} ccs_sync_value;

int getCCSItemValue(BYTE* data, int size, ccs_item_value* value);
int getCCSItemValueList(BYTE* data, int size, std::vector<ccs_item_value>& itemValueList);
int freeCCSItemValueList(const std::vector<ccs_item_value>& itemValueList);

int getSyncItemValue(BYTE* data, int size, ccs_sync_value* value);
int getSyncItemValueList(BYTE* data, int size, std::vector<ccs_sync_value>& itemValueList);

#define DEF_FIELD(val, len) \
int val##Size = (len);

#define DEF_OUT_BUF() \
BYTE* data = (BYTE*)calloc(1, dataLen); \
int offset = 0; \

#define SET_VALUE_FIELD(val) \
memcpy(data+offset, &val, val##Size); \
offset+=val##Size;

#define SET_BUFF_FIELD(val) \
memcpy(data+offset, val, val##Size); \
offset+=val##Size;

#define FILL_VALUE_WITH_3_FIELD_BV(val1, len1, val2, len2,val3,len3) \
DEF_FIELD(val1, len1) \
DEF_FIELD(val2, len2) \
DEF_FIELD(val3, len3) \
int dataLen = val1##Size+val2##Size+val3##Size; \
DEF_OUT_BUF()\
SET_BUFF_FIELD(val1) \
SET_VALUE_FIELD(val2) \
SET_VALUE_FIELD(val3)

#define FILL_VALUE_WITH_2_FIELD_BV(val1, len1, val2, len2) \
DEF_FIELD(val1, len1) \
DEF_FIELD(val2, len2) \
int dataLen = val1##Size+val2##Size; \
DEF_OUT_BUF()\
SET_BUFF_FIELD(val1) \
SET_VALUE_FIELD(val2)

#define FILL_VALUE_WITH_2_FIELD_VB(val1, len1, val2, len2) \
DEF_FIELD(val1, len1) \
DEF_FIELD(val2, len2) \
int dataLen = val1##Size+val2##Size; \
DEF_OUT_BUF()\
SET_VALUE_FIELD(val1) \
SET_BUFF_FIELD(val2)

#define FILL_VALUE_WITH_2_FIELD_BB(val1, len1, val2, len2) \
DEF_FIELD(val1, len1) \
DEF_FIELD(val2, len2) \
int dataLen = val1##Size+val2##Size; \
DEF_OUT_BUF()\
SET_BUFF_FIELD(val1) \
SET_BUFF_FIELD(val2)

#define FILL_VALUE_WITH_3_FIELDBVB(val1, len1, val2, len2, val3, len3) \
DEF_FIELD(val1, len1) \
DEF_FIELD(val2, len2) \
DEF_FIELD(val3, len3) \
int dataLen = val1##Size+val2##Size+val3##Size; \
DEF_OUT_BUF()\
SET_BUFF_FIELD(val1) \
SET_VALUE_FIELD(val2) \
SET_BUFF_FIELD(val3)

NAMESPACE_ZY_END

#endif /* __CCS_TOOL_H__ */
