#include "rc4Encode.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define swap(i, j) \
{ \
    char tmp = i; \
    i = j; \
    j = tmp; \
}


void Transform(const char *key, int keylen, char* output, const char* input, int len)
{
	// 设置密钥
	char key_[256];
	memset(key_, 0, 256);
    for (int i = 0; i < 256; i++)
    {
        key_[i] = i;
    }
    int j = 0;
    for (int i = 0; i < 256; i++)
    {
        j = (j + key_[i] + key[i%keylen]) & 0xff; // (j + key_[i] + key[i%keylen]) % 256;
        swap(key_[i], key_[j]);
    }
    // 加/解密
    int i = 0;
    j = 0;
    for (int k = 0; k < len; k++)
    {
        i = (i+1) & 0xff; // (i + 1) % 256;
        j = (j + key_[i]) & 0xff; // (j + key_[i]) % 256;
        swap(key_[i], key_[j]);
        unsigned char subkey = key_[(key_[i] + key_[j]) & 0xff]; // key_[(key_[i] + key_[j]) % 256];
        output[k] = subkey ^ input[k];
    }
    
    return;
}

