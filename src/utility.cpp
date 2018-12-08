#include <dark/utility.hpp>

namespace dark {

bc::ec_secret new_key()
{
    const auto seed = new_seed();
    return new_key(seed);
}

// The key may be invalid, caller may test for null secret.
bc::ec_secret new_key(const bc::data_chunk& seed)
{
    const bc::wallet::hd_private key(seed);
    return key.secret();
}

// Not testable due to lack of random engine injection.
bc::data_chunk new_seed(size_t bit_length)
{
    size_t fill_seed_size = bit_length / bc::byte_bits;
    bc::data_chunk seed(fill_seed_size);
    bc::pseudo_random_fill(seed);
    return seed;
}

} // namespace dark
