#include <stdio.h>
#include <gmp.h>
#include <ethash/keccak.hpp>

using namespace ethash;

int main(int argc , char *argv[])
{  
    mpz_t pi; 
    mpz_init_set_str (pi, "3141592653589793238462643383279502884", 10);

    hash256 h = keccak256(nullptr, 0);

    return 0;
}