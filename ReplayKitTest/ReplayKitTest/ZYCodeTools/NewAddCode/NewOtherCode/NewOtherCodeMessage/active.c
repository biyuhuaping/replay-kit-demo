/*
 * active.c
 *
 *  Created on: 2020-2-14
 *      Author: charlie.chi
 */

#include "active.h"
#include "aes.h"
#include "aes_cbc.h"


static const uint8_t active_key[32] = {
	0x8A, 0xCF, 0x81, 0x57, 0xC2, 0xA6, 0xBC, 0xA4,
	0x22, 0xF8, 0xB5, 0x30, 0x58, 0x08, 0xAF, 0x02,
	0xE1, 0xB0, 0x2E, 0x60, 0x7C, 0x04, 0x09, 0x92,
	0xDE, 0x32, 0xBF, 0xE9, 0xA7, 0xAD, 0x0E, 0x00,
};

// AES
static unsigned char chainCipherBlock[16];

static void active_aes_init(void)
{
	AES_Key_Table = (unsigned char *)active_key;
	memset(chainCipherBlock, 0x00, sizeof(chainCipherBlock));
	aesDecInit();
}

void active_aes_decrypt(uint8_t *buff)           //激活信息解密
{
    active_aes_init();
    aesDecrypt(buff , chainCipherBlock);
    
}

void active_aes_encrypt(uint8_t *buff)           //激活信息加密
{ 
    active_aes_init();
    aesEncrypt(buff, chainCipherBlock);    
}
void active_aes_encryptR(uint8_t *butt,uint8_t *value){
    active_aes_encrypt(butt);
    memcpy(value,chainCipherBlock, 16);
}

void active_aes_encryptWithBuff(uint8_t *buff,uint8_t *key){
    AES_Key_Table = key;
    memset(chainCipherBlock, 0x00, sizeof(chainCipherBlock));
    
    aesDecInit();
    aesEncrypt(buff, chainCipherBlock);
}
void active_aes_decryptWithBuff(uint8_t *buff,uint8_t *key){
//    AES_Test();
//    return;
    AES_Key_Table = key;
    memset(chainCipherBlock, 0x00, sizeof(chainCipherBlock));
    aesDecInit();
    aesDecrypt(buff, chainCipherBlock);
}

///
/// @param input 输入
/// @param key key
/// @param output 输出
void AES_ECB_encryptWithBuff(const uint8_t* input, const uint8_t* key, uint8_t* output){
    AES_ECB_encrypt(input, key, output, 16);

}
void AES_ECB_decryptWithBuff(const uint8_t* input, const uint8_t* key, uint8_t* output){
    AES_ECB_decrypt(input, key, output, 16);

}
