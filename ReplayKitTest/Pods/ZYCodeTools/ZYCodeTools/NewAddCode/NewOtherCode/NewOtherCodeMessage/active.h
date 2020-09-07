/*
 * active.h
 *
 *  Created on: 2020-2-14
 *      Author: charlie.chi
 */

#ifndef ACTIVE_H_
#define ACTIVE_H_

#include <stdint.h>
#include <string.h>

enum {
ACTIVEMODE_NONE = 0,
ACTIVEMODE_AESONLY,

};

enum {
ACTIVE_STATE_NONE = 0x00,           //未激活
ACTIVE_STATE_ACT,                   //已激活
ACTIVE_STATE_EXPIRE,                //激活已到期
};

struct activeinfo_t{
    
    uint8_t  avtive_state;
    uint8_t  random_data[11];
    uint16_t active_date;
    uint16_t crc16;
};

void active_aes_encryptWithBuff(uint8_t *buff,uint8_t *key);
void active_aes_decryptWithBuff(uint8_t *buff,uint8_t *key);

///
/// @param input 输入
/// @param key key
/// @param output 输出
void AES_ECB_encryptWithBuff(const uint8_t* input, const uint8_t* key, uint8_t* output);
void AES_ECB_decryptWithBuff(const uint8_t* input, const uint8_t* key, uint8_t* output);
#endif // ACTIVE_H_
