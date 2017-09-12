//  Copyright (c) 2001-2011 Hartmut Kaiser
// 
//  Distributed under the Boost Software License, Version 1.0. (See accompanying 
//  file LICENSE_1_0.txt or copy at http://www.lslboost.org/LICENSE_1_0.txt)

#if !defined(BOOST_SPIRIT_WHAT_MAY_04_2007_0116PM)
#define BOOST_SPIRIT_WHAT_MAY_04_2007_0116PM

#if defined(_MSC_VER)
#pragma once
#endif

#include <lslboost/mpl/assert.hpp>
#include <lslboost/spirit/home/support/info.hpp>
#include <lslboost/spirit/home/karma/meta_compiler.hpp>

namespace lslboost { namespace spirit { namespace karma
{
    template <typename Expr>
    inline info what(Expr const& xpr)
    {
        // Report invalid expression error as early as possible.
        // If you got an error_invalid_expression
        // error message here, then the expression (expr) is not a
        // valid spirit karma expression.
        BOOST_SPIRIT_ASSERT_MATCH(karma::domain, Expr);
        return compile<karma::domain>(xpr).what(unused);
    }

}}}

#endif

