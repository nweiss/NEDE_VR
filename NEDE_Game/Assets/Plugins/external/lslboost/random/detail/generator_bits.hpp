/* lslboost random/detail/generator_bits.hpp header file
 *
 * Copyright Steven Watanabe 2011
 * Distributed under the Boost Software License, Version 1.0. (See
 * accompanying file LICENSE_1_0.txt or copy at
 * http://www.lslboost.org/LICENSE_1_0.txt)
 *
 * See http://www.lslboost.org for most recent version including documentation.
 *
 * $Id: generator_bits.hpp 72951 2011-07-07 04:57:37Z steven_watanabe $
 *
 */

#ifndef BOOST_RANDOM_DETAIL_GENERATOR_BITS_HPP
#define BOOST_RANDOM_DETAIL_GENERATOR_BITS_HPP

#include <lslboost/limits.hpp>

namespace lslboost {
namespace random {
namespace detail {

// This is a temporary measure that retains backwards
// compatibility.
template<class URNG>
struct generator_bits {
    static std::size_t value() {
        return std::numeric_limits<typename URNG::result_type>::digits;
    }
};

} // namespace detail
} // namespace random
} // namespace lslboost

#endif // BOOST_RANDOM_DETAIL_GENERATOR_BITS_HPP