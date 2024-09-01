#include <stdio.h>
#include <iostream>
#include <math.h>

#include <gmp.h>
#include <ethash/keccak.hpp>
#include <givaro/givinteger.h>

using namespace ethash;
using namespace Givaro;

int main(int argc , char *argv[])
{  
    mpz_t pi; 
    mpz_init_set_str (pi, "3141592653589793238462643383279502884", 10);

    hash256 h = keccak256(nullptr, 0);

    Integer a(2);

    return 0;
}