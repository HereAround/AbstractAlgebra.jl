module Generic

import LinearAlgebra: det, issymmetric, norm,
                      nullspace, rank, hessenberg

import LinearAlgebra: istriu, lu, lu!, tr

using Markdown, Random, InteractiveUtils

using Random: SamplerTrivial, GLOBAL_RNG
using RandomExtensions: RandomExtensions, make, Make, Make2, Make3, Make4

import Base: Array, abs, asin, asinh, atan, atanh, axes, bin, checkbounds, cmp, conj,
             convert, copy, cos, cosh, dec, deepcopy, deepcopy_internal,
             exponent, gcd, gcdx, getindex, hash, hcat, hex, intersect,
             invmod, isapprox, isempty, isequal, isfinite, isless, isone, isqrt,
             isreal, iszero, lcm, ldexp, length, Matrix, mod, ndigits, oct, one,
             parent, parse, powermod,
             precision, rand, Rational, rem, reverse, setindex!,
             show, similar, sign, sin, sinh, size, string, tan, tanh,
             trailing_zeros, transpose, truncate, typed_hvcat, typed_hcat,
             vcat, xor, zero, zeros, +, -, *, ==, ^, &, |, <<, >>, ~, <=, >=,
             <, >, //, /, !=

import Base: floor, ceil, hypot, log1p, expm1, sin, cos, sinpi, cospi,
             tan, cot, sinh, cosh, tanh, coth, atan, asin, acos, atanh, asinh,
             acosh, sinpi, cospi

# The type and helper function for the dictionaries for hashing
import ..AbstractAlgebra: CacheDictType, get_cached!

import ..AbstractAlgebra: CycleDec, Field, FieldElement, Integers, Map,
                          NCRing, NCRingElem, Perm, Rationals, Ring, RingElem,
                          RingElement, GFElem

import ..AbstractAlgebra: add!, addeq!, addmul!, base_ring, canonical_unit,
                          can_solve_with_solution_lu,
                          can_solve_with_solution_fflu, change_base_ring,
                          characteristic, check_parent, codomain, coeff,
                          coefficient_ring, coefficients,
                          coefficients_of_univariate, compose,
                          constant_coefficient,
                          content, data, deflate, deflation, degree, degrees,
                          degrees_range, denominator, derivative, div,
                          divexact, divides, divrem, domain, elem_type,
                          evaluate, exp, exponent_vectors, expressify,
                          factor, factor_squarefree,
                          gen, gens, get_field, identity_matrix, inflate,
                          integral, inv, is_constant, is_domain_type,
                          is_exact_type, is_gen, is_monomial, isreduced_form,
                          is_square, is_square_with_sqrt, is_term, is_unit,
                          is_univariate,
                          is_zero_divisor, is_zero_divisor_with_annihilator,
                          leading_monomial, leading_term, log,
                          leading_coefficient, leading_exponent_vector,
                          map_coefficients, max_precision, minpoly, modulus,
                          monomials, mul!, mul_classical, mul_karatsuba, mullow,
                          numerator, ncols, ngens, nrows, nvars, O, order,
                          parent_type, pol_length, primpart, promote_rule,
                          pseudodivrem, pseudorem, reduced_form,
                          remove, renormalize!,
                          set_coefficient!, set_field!,
                          set_length!, set_precision!, set_valuation!,
                          shift_left, shift_right, snf, sqrt, symbols,
                          tail, terms, term_degree, terms_degrees,
                          to_univariate, trailing_coefficient,
                          use_karamul,
                          valuation, var, var_index, vars, zero!,
                          @enable_all_show_via_expressify,
                          @attributes


using ..AbstractAlgebra

include("generic/GenericTypes.jl")

include("generic/PermGroups.jl")

include("generic/YoungTabs.jl")

include("generic/Residue.jl")

include("generic/ResidueField.jl")

include("generic/NumberField.jl")

include("generic/Poly.jl")

include("generic/NCPoly.jl")

include("generic/MPoly.jl")

include("generic/UnivPoly.jl")

include("generic/SparsePoly.jl")

include("generic/LaurentPoly.jl")

include("generic/LaurentMPoly.jl")

include("generic/RelSeries.jl")

include("generic/AbsSeries.jl")

include("generic/AbsMSeries.jl")

include("generic/LaurentSeries.jl")

include("generic/PuiseuxSeries.jl")

include("generic/Matrix.jl")

include("generic/MatrixAlgebra.jl")

include("generic/FreeAssAlgebra.jl")

include("generic/Fraction.jl")

include("generic/TotalFraction.jl")

include("generic/FactoredFraction.jl")

include("generic/RationalFunctionField.jl")

include("generic/FunctionField.jl")

include("generic/FreeModule.jl")

include("generic/Submodule.jl")

include("generic/QuotientModule.jl")

include("generic/DirectSum.jl")

include("generic/ModuleHomomorphism.jl")

include("generic/Module.jl")

include("generic/InvariantFactorDecomposition.jl")

include("generic/Map.jl")

include("generic/MapWithInverse.jl")

include("generic/MapCache.jl")

include("generic/Ideal.jl")

###############################################################################
#
#   Temporary miscellaneous files being moved from Hecke.jl
#
###############################################################################

include("generic/Misc/Poly.jl")
include("generic/Misc/Rings.jl")
include("generic/Misc/Localization.jl")

end # generic
