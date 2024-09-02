#include <stdio.h>
#include <iostream>
#include <math.h>

#include <gmp.h>
#include <ethash/keccak.hpp>
#include <givaro/givinteger.h>

#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/kdf.h>
#include <openssl/hmac.h>
#include <openssl/err.h>
#include <openssl/params.h>
#include <openssl/core_names.h>
#include <openssl/aes.h>
#include <openssl/modes.h>

using namespace ethash;
using namespace Givaro;

int main(int argc , char *argv[])
{  
    mpz_t pi; 
    mpz_init_set_str (pi, "3141592653589793238462643383279502884", 10);

    hash256 h = keccak256(nullptr, 0);

    Integer a(2);
    int16_t b(a);

    EVP_CIPHER_CTX *ctx;
    ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_aes_128_gcm(), NULL, NULL, NULL);

    return 0;
}