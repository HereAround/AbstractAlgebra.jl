###############################################################################
#
#   GenericTypes.jl : Generic Types
#
###############################################################################

###############################################################################
#
#   SymmetricGroup
#
###############################################################################

@doc Markdown.doc"""
    SymmetricGroup{T<:Integer}

The full symmetric group singleton type.
`SymmetricGroup(n)` constructs the full symmetric group $S_n$ on $n$-symbols. The type of elements of the group is inferred from the type of `n`.

# Examples:
```jldoctest; setup = :(using AbstractAlgebra)
julia> G = SymmetricGroup(5)
Full symmetric group over 5 elements

julia> elem_type(G)
Perm{Int64}

julia> H = SymmetricGroup(UInt16(5))
Full symmetric group over 5 elements

julia> elem_type(H)
Perm{UInt16}
```
"""
struct SymmetricGroup{T<:Integer} <: AbstractAlgebra.AbstractPermutationGroup
   n::T

   function SymmetricGroup{T}(n::Integer) where T<:Integer
      n < 0 && throw(DomainError(n, "SymmetricGroup constructor requires a non-negative integer"))
      new{T}(n)
   end
end

SymmetricGroup(n::Integer) = SymmetricGroup{typeof(n)}(n)

@doc Markdown.doc"""
    AllPerms(n::T) where T

Return an iterator over arrays representing all permutations of `1:n`.
Similar to `Combinatorics.permutations(1:n)`
"""
struct AllPerms{T<:Integer}
   all::Int
   c::Vector{Int}
   elts::Perm{T}

   function AllPerms(n::T) where T
      new{T}(Int(factorial(n)), ones(Int, n), Perm(collect(T, 1:n), false))
   end
end

###############################################################################
#
#   Partition
#
###############################################################################

@doc Markdown.doc"""
    Partition(part::Vector{<:Integer}[, check::Bool=true]) <: AbstractVector{Int}

Represent integer partition in the non-increasing order.

`part` will be sorted, if necessary. Checks for validity of input can be skipped by calling the (inner) constructor with `false` as the second argument.

Functionally `Partition` is a thin wrapper over `Vector{Int}`.

Fieldnames:
 * `n::Int` - the partitioned number
 * `part::Vector{Int}` - a non-increasing sequence of summands of `n`.

# Examples:
```jldoctest; setup = :(using AbstractAlgebra)
julia> p = Partition([4,2,1,1,1])
4₁2₁1₃

julia> p.n == sum(p.part)
true
```
"""
struct Partition{T} <: AbstractVector{T}
   n::Int
   part::Vector{T}

   Partition(part::AbstractVector{<:Integer}, check::Bool=true) =
      Partition(sum(part), part, check)

   function Partition(n::Integer, part::AbstractVector{T}, check::Bool=true) where T
      if check
	 issorted(part, rev=true) || sort!(part, rev=true)
         if length(part) > 0
            part[end] >= 1 || throw(ArgumentError("Found non-positive entry in partition: $(part[end])"))
         end
         @assert n == sum(part)
      end
      return new{T}(n, part)
   end
end

@doc Markdown.doc"""
    AllParts(n::Integer)

Return an iterator over all integer Partitions of `n`.

Partitions are produced as `Vector{typeof(n)}` in ascending order according to RuleAsc (Algorithm 3.1) from

> Jerome Kelleher and Barry O’Sullivan,
> *Generating All Partitions: A Comparison Of Two Encodings*
> ArXiv:0909.2331

See also `Combinatorics.partitions(1:n)`.

Note: All returned partitions share memory, so advancing to the next one will change the previous. For persistent storage one should `copy` the result

# Examples
```jldoctest; setup = :(using AbstractAlgebra)
julia> ap = AllParts(5);

julia> for p in ap; println(p) end
[1, 1, 1, 1, 1]
[2, 1, 1, 1]
[3, 1, 1]
[2, 2, 1]
[4, 1]
[3, 2]
[5]

julia> unique(collect(ap))
1-element Vector{Vector{Int64}}:
 [5]


```
"""
struct AllParts{T<:Integer}
   n::T
   tmp::Vector{T}
   part::Vector{T}

   AllParts{T}(n::Integer) where T =
      new{T}(n, ones(T, n), ones(T, n))
   AllParts(n::T; copy=true) where T<:Integer = AllParts{T}(n)
end

###############################################################################
#
#   SkewDiagram
#
###############################################################################

@doc Markdown.doc"""
    SkewDiagram(lambda::Partition, mu::Partition) <: AbstractMatrix{Int}

Implements a skew diagram, i.e. a difference of two Young diagrams
represented by partitions `lambda` and `mu`.
(below dots symbolise the removed entries)

# Examples
```jldoctest; setup = :(using AbstractAlgebra)
julia> l = Partition([4,3,2])
4₁3₁2₁

julia> m = Partition([3,1,1])
3₁1₂

julia> xi = SkewDiagram(l,m)
3×4 AbstractAlgebra.Generic.SkewDiagram{Int64}:
 ⋅  ⋅  ⋅  1
 ⋅  1  1
 ⋅  1

```
"""
struct SkewDiagram{T<:Integer} <: AbstractMatrix{T}
   lam::Partition{T}
   mu::Partition{T}

   function SkewDiagram(lambda::Partition{T}, mu::Partition{T}) where T
      @boundscheck let
         lambda.n >= mu.n ||
            throw("Can't create SkewDiagram: $mu is partition of  $(mu.n) > $(lambda.n).")
         length(lambda) >= length(mu) ||
               throw("Can't create SkewDiagram: $mu is longer than $(lambda)!")
         for (l, m) in zip(lambda, mu)
            l >= m || throw("a row of $mu is longer than a row of $lambda")
         end
      end
      return new{T}(lambda, mu)
   end
end

###############################################################################
#
#   Young Tableau
#
###############################################################################

@doc Markdown.doc"""
    YoungTableau(part::Partition[, fill::Vector{Int}=collect(1:sum(part))])  <: AbstractMatrix{Int}

Return the Young tableaux of partition `part`, filled linearly
by `fill` vector. Note that `fill` vector is in **row-major** format.

Fields:
* `part` - the partition defining Young diagram
* `fill` - the row-major fill vector: the entries of the diagram.

# Examples:
```jldoctest; setup = :(using AbstractAlgebra)
julia> p = Partition([4,3,1]); y = YoungTableau(p)
┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ 4 │
├───┼───┼───┼───┘
│ 5 │ 6 │ 7 │
├───┼───┴───┘
│ 8 │
└───┘

julia> y.part
4₁3₁1₁

julia> y.fill
8-element Vector{Int64}:
 1
 2
 3
 4
 5
 6
 7
 8
```
"""
struct YoungTableau{T<:Integer} <: AbstractMatrix{T}
   part::Partition{T}
   fill::Vector{T}

   function YoungTableau(part::Partition{T},
      fill::AbstractVector{<:Integer}=collect(T(1):sum(part))) where T
      @boundscheck sum(part) == length(fill) || throw(ArgumentError("Can't fill Young digaram of $part with $fill: different number of elements."))

      return new{T}(part, fill)
   end
end

###############################################################################
#
#   PolyRing / Poly
#
###############################################################################

mutable struct PolyRing{T <: RingElement} <: AbstractAlgebra.PolyRing{T}
   base_ring::Ring
   S::Symbol

   function PolyRing{T}(R::Ring, s::Symbol, cached::Bool = true) where T <: RingElement
      return get_cached!(PolyID, (R, s), cached) do
         new{T}(R, s)
      end::PolyRing{T}
   end
end

const PolyID = CacheDictType{Tuple{Ring, Symbol}, Ring}()

mutable struct Poly{T <: RingElement} <: AbstractAlgebra.PolyElem{T}
   coeffs::Vector{T}
   length::Int
   parent::PolyRing{T}

   Poly{T}() where T <: RingElement = new{T}(Array{T}(undef, 0), 0)

   function Poly{T}(b::Vector{T}) where T <: RingElement
      z = new{T}(b)
      z.length = normalise(z, length(b))
      return z
   end

   Poly{T}(a::T) where T <: RingElement = iszero(a) ? new{T}(Array{T}(undef, 0), 0) : new{T}([a], 1)
end

###############################################################################
#
#   NCPolyRing / NCPoly
#
###############################################################################

mutable struct NCPolyRing{T <: NCRingElem} <: AbstractAlgebra.NCPolyRing{T}
   base_ring::NCRing
   S::Symbol

   function NCPolyRing{T}(R::NCRing, s::Symbol, cached::Bool = true) where T <: NCRingElem
      return get_cached!(NCPolyID, (R, s), cached) do
         new{T}(R, s)
      end::NCPolyRing{T}
   end
end

const NCPolyID = CacheDictType{Tuple{NCRing, Symbol}, NCRing}()

mutable struct NCPoly{T <: NCRingElem} <: AbstractAlgebra.NCPolyElem{T}
   coeffs::Vector{T}
   length::Int
   parent::NCPolyRing{T}

   NCPoly{T}() where T <: NCRingElem = new{T}(Array{T}(undef, 0), 0)

   function NCPoly{T}(b::Vector{T}) where T <: NCRingElem
      z = new{T}(b)
      z.length = normalise(z, length(b))
      return z
   end

   NCPoly{T}(a::T) where T <: NCRingElem = iszero(a) ? new{T}(Array{T}(undef, 0), 0) : new{T}([a], 1)
end

###############################################################################
#
#   MPolyRing / MPoly
#
###############################################################################

# S is a Symbol which can take the values:
# :lex
# :revlex
# :deglex
# :degrevlex
#
# T is an Int which is the number of variables
# (plus one if ordered by total degree)

mutable struct MPolyRing{T <: RingElement} <: AbstractAlgebra.MPolyRing{T}
   base_ring::Ring
   S::Vector{Symbol}
   ord::Symbol
   num_vars::Int
   N::Int

   function MPolyRing{T}(R::Ring, s::Vector{Symbol}, ord::Symbol, N::Int,
                         cached::Bool = true) where T <: RingElement
      return get_cached!(MPolyID, (R, s, ord, N), cached) do
         new{T}(R, s, ord, length(s), N)
      end::MPolyRing{T}
   end
end

const MPolyID = CacheDictType{Tuple{Ring, Vector{Symbol}, Symbol, Int}, Ring}()

mutable struct MPoly{T <: RingElement} <: AbstractAlgebra.MPolyElem{T}
   coeffs::Vector{T}
   exps::Matrix{UInt}
   length::Int
   parent::MPolyRing{T}

   function MPoly{T}(R::MPolyRing) where T <: RingElement
      N = R.N
      return new{T}(Array{T}(undef, 0), Array{UInt}(undef, N, 0), 0, R)
   end

   MPoly{T}(R::MPolyRing, a::Vector{T}, b::Matrix{UInt}) where T <: RingElement = new{T}(a, b, length(a), R)

   function MPoly{T}(R::MPolyRing, a::T) where T <: RingElement
      N = R.N
      return iszero(a) ? new{T}(Array{T}(undef, 0), Array{UInt}(undef, N, 0), 0, R) :
                                          new{T}([a], zeros(UInt, N, 1), 1, R)
   end
end

# Iterators

struct MPolyCoeffs{T <: AbstractAlgebra.NCRingElem}
   poly::T
end

struct MPolyExponentVectors{T <: AbstractAlgebra.RingElem}
   poly::T
end

struct MPolyTerms{T <: AbstractAlgebra.NCRingElem}
   poly::T
end

struct MPolyMonomials{T <: AbstractAlgebra.NCRingElem}
   poly::T
end

mutable struct MPolyBuildCtx{T, S}
  poly::T
  state::S

  function MPolyBuildCtx(R::T, s::S) where {S, T}
    return new{elem_type(T), S}(R())
  end
end

###############################################################################
#
#   UnivPolyRing / UnivPoly
#
###############################################################################

mutable struct UnivPolyRing{T <: RingElement, U <: AbstractAlgebra.MPolyElem{T}} <: AbstractAlgebra.UnivPolyRing{T}
   base_ring::Ring
   S::Vector{Symbol}
   ord::Symbol
   mpoly_ring::AbstractAlgebra.MPolyRing{T}

   function UnivPolyRing{T, U}(R::Ring, ord::Symbol, cached::Bool=true) where {T <: RingElement, U <: AbstractAlgebra.MPolyElem{T}}
      return get_cached!(UnivPolyID, (R, ord, U), cached) do
         new{T, U}(R, Vector{Symbol}(undef, 0), ord,
                      PolynomialRing(R, Vector{Symbol}(undef, 0); cached=cached, ordering=ord)[1])
      end::UnivPolyRing{T, U}
   end
end

const UnivPolyID = CacheDictType{Tuple{Ring, Symbol, DataType}, Ring}()

mutable struct UnivPoly{T <: RingElement, U <: MPoly} <: AbstractAlgebra.UnivPolyElem{T}
   p::U
   parent::UnivPolyRing{T}
end

struct UnivPolyCoeffs{T <: AbstractAlgebra.RingElem}
   poly::T
end

struct UnivPolyExponentVectors{T <: AbstractAlgebra.RingElem}
   poly::T
end

struct UnivPolyTerms{T <: AbstractAlgebra.RingElem}
   poly::T
end

struct UnivPolyMonomials{T <: AbstractAlgebra.RingElem}
   poly::T
end

###############################################################################
#
#   SparsePolyRing / SparsePoly
#
###############################################################################

# Q: Why is SparsePolyRing not a subtype of AbstractAlgebra.PolyRing{T} ?

mutable struct SparsePolyRing{T <: RingElement} <: AbstractAlgebra.Ring
   base_ring::Ring
   S::Symbol
   num_vars::Int

   function SparsePolyRing{T}(R::Ring, s::Symbol, cached::Bool = true) where T <: RingElement
      return get_cached!(SparsePolyID, (R, s), cached) do
         new{T}(R, s)
      end::SparsePolyRing{T}
   end
end

const SparsePolyID = CacheDictType{Tuple{Ring, Symbol}, SparsePolyRing}()

mutable struct SparsePoly{T <: RingElement} <: AbstractAlgebra.RingElem
   coeffs::Vector{T}
   exps::Array{UInt}
   length::Int
   parent::SparsePolyRing{T}

   SparsePoly{T}() where T <: RingElement = new{T}(Array{T}(undef, 0), Array{UInt}(undef, 0), 0)

   SparsePoly{T}(a::Vector{T}, b::Vector{UInt}) where T <: RingElement = new{T}(a, b, length(a))

   SparsePoly{T}(a::T) where T <: RingElement = iszero(a) ? new{T}(Array{T}(undef, 0), Array{UInt}(undef, 0), 0) :
                                               new{T}([a], [UInt(0)], 1)
end


###############################################################################
#
#   LaurentPolyRing / LaurentPoly
#
###############################################################################

abstract type LaurentPolynomialRing{T} <: AbstractAlgebra.LaurentPolynomialRing{T} end

mutable struct LaurentPolyWrapRing{T  <: RingElement,
                                   PR <: AbstractAlgebra.PolyRing{T}
                                  } <: LaurentPolynomialRing{T}
   polyring::PR

   function LaurentPolyWrapRing(pr::PR, cached::Bool = true) where {
                                             T <: RingElement,
                                             PR <: AbstractAlgebra.PolyRing{T}}

      return get_cached!(LaurentPolyWrapRingID, pr, cached) do
         new{T, PR}(pr)
      end::LaurentPolyWrapRing{T, PR}
   end
end

const LaurentPolyWrapRingID = CacheDictType{Ring, LaurentPolyWrapRing}()

mutable struct LaurentPolyWrap{T  <: RingElement,
                               PE <: AbstractAlgebra.PolyElem{T},
                               LR <: LaurentPolyWrapRing{T}
                              } <: AbstractAlgebra.LaurentPolyElem{T}
   parent::LR
   poly::PE
   mindeg::Int

   # A LaurentPolyWrap object is specified by a backing polynomial `poly` and
   # an integer `mindeg`, and represents `poly * x^mindeg`, where `x` is a generator
   # of the parent ring; no "normalization" is done, i.e.
   # `LaurentPolyWrap(poly*x^i, mindeg-i)` is another valid representation for the same
   # Laurent polynomial, where i is an integer.

   function LaurentPolyWrap(parent::LR, poly::PE, mindeg::Int = 0) where {
                                             T  <: RingElement,
                                             PE <: AbstractAlgebra.PolyElem{T},
                                             LR <: LaurentPolyWrapRing{T}}
      new{T, PE, LR}(parent, poly, mindeg)
   end
end

###############################################################################
#
#   LaurentMPolyRing / LaurentMPoly
#
###############################################################################

mutable struct LaurentMPolyWrapRing{T  <: RingElement,
                                    PR <: AbstractAlgebra.MPolyRing{T}
                                   } <: AbstractAlgebra.LaurentMPolyRing{T}
   mpolyring::PR

   function LaurentMPolyWrapRing(pr::PR, cached::Bool = true) where {
                                             T <: RingElement,
                                             PR <: AbstractAlgebra.MPolyRing{T}}

      return get_cached!(LaurentMPolyWrapRingID, pr, cached) do
         new{T, PR}(pr)
      end::LaurentMPolyWrapRing{T, PR}
   end
end

const LaurentMPolyWrapRingID = CacheDictType{Ring, LaurentMPolyWrapRing}()

mutable struct LaurentMPolyWrap{T  <: RingElement,
                                PE <: AbstractAlgebra.MPolyElem{T},
                                LR <: LaurentMPolyWrapRing{T}
                               } <: AbstractAlgebra.LaurentMPolyElem{T}
   parent::LR
   mpoly::PE            # not necessarily owned by object
   mindegs::Vector{Int} # meaning ditto, vector not necessarily owned by object
   function LaurentMPolyWrap(parent::LR,
                             poly::PE,
                             mindegs::Vector{Int} = zeros(Int, nvars(parent))
                            ) where {T  <: RingElement,
                                     PE <: AbstractAlgebra.MPolyElem{T},
                                     LR <: LaurentMPolyWrapRing{T}}
      new{T, PE, LR}(parent, poly, mindegs)
   end
end

###############################################################################
#
#   ResRing / Res
#
###############################################################################

mutable struct ResRing{T <: RingElement} <: AbstractAlgebra.ResRing{T}
   base_ring::Ring
   modulus::T

   function ResRing{T}(modulus::T, cached::Bool = true) where T <: RingElement
      c = canonical_unit(modulus)
      if !isone(c)
        modulus = divexact(modulus, c)
      end
      R = parent(modulus)

      return get_cached!(ModulusDict, (R, modulus), cached) do
         new{T}(R, modulus)
      end::ResRing{T}
   end
end

const ModulusDict = CacheDictType{Tuple{Ring, RingElement}, Ring}()

mutable struct Res{T <: RingElement} <: AbstractAlgebra.ResElem{T}
   data::T
   parent::ResRing{T}

   Res{T}(a::T) where T <: RingElement = new{T}(a)
end

###############################################################################
#
#   ResField / ResFieldElem
#
###############################################################################

mutable struct ResField{T <: RingElement} <: AbstractAlgebra.ResField{T}
   base_ring::Ring
   modulus::T

   function ResField{T}(modulus::T, cached::Bool = true) where T <: RingElement
      c = canonical_unit(modulus)
      if !isone(c)
        modulus = divexact(modulus, c)
      end
      R = parent(modulus)
      return get_cached!(ModulusFieldDict, (R, modulus), cached) do
         new{T}(R, modulus)
      end::ResField{T}
   end
end

const ModulusFieldDict = CacheDictType{Tuple{Ring, RingElement}, Field}()

mutable struct ResF{T <: RingElement} <: AbstractAlgebra.ResFieldElem{T}
   data::T
   parent::ResField{T}

   ResF{T}(a::T) where T <: RingElement = new{T}(a)
end

###############################################################################
#
#   RelSeriesRing / RelSeries
#
###############################################################################

mutable struct RelSeriesRing{T <: RingElement} <: AbstractAlgebra.SeriesRing{T}
   base_ring::Ring
   prec_max::Int
   S::Symbol

   function RelSeriesRing{T}(R::Ring, prec::Int, s::Symbol, cached::Bool = true) where T <: RingElement
      return get_cached!(RelSeriesID, (R, prec, s), cached) do
         new{T}(R, prec, s)
      end::RelSeriesRing{T}
   end
end

const RelSeriesID = CacheDictType{Tuple{Ring, Int, Symbol}, Ring}()

mutable struct RelSeries{T <: RingElement} <: AbstractAlgebra.RelSeriesElem{T}
   coeffs::Vector{T}
   length::Int
   prec::Int
   val::Int
   parent::RelSeriesRing{T}

   function RelSeries{T}(a::Vector{T}, length::Int, prec::Int, val::Int) where T <: RingElement
      new{T}(a, length, prec, val)
   end

   RelSeries{T}(a::RelSeries{T}) where T <: RingElement = a
end

###############################################################################
#
#   AbsSeriesRing / AbsSeries
#
###############################################################################

mutable struct AbsSeriesRing{T <: RingElement} <: AbstractAlgebra.SeriesRing{T}
   base_ring::Ring
   prec_max::Int
   S::Symbol

   function AbsSeriesRing{T}(R::Ring, prec::Int, s::Symbol, cached::Bool = true) where T <: RingElement
      return get_cached!(AbsSeriesID, (R, prec, s), cached) do
         new{T}(R, prec, s)
      end::AbsSeriesRing{T}
   end
end

const AbsSeriesID = CacheDictType{Tuple{Ring, Int, Symbol}, Ring}()

mutable struct AbsSeries{T <: RingElement} <: AbstractAlgebra.AbsSeriesElem{T}
   coeffs::Vector{T}
   length::Int
   prec::Int
   parent::AbsSeriesRing{T}

   AbsSeries{T}(a::Vector{T}, length::Int, prec::Int) where T <: RingElement = new{T}(a, length, prec)
   AbsSeries{T}(a::AbsSeries{T}) where T <: RingElement = a
end

###############################################################################
#
#   LaurentSeriesRing / LarentSeriesRingElem
#
###############################################################################

mutable struct LaurentSeriesRing{T <: RingElement} <: AbstractAlgebra.Ring
   base_ring::Ring
   prec_max::Int
   S::Symbol

   function LaurentSeriesRing{T}(R::Ring, prec::Int, s::Symbol, cached::Bool = true) where T <: RingElement
      return get_cached!(LaurentSeriesID, (R, prec, s), cached) do
         new{T}(R, prec, s)
      end::LaurentSeriesRing{T}
   end
end

const LaurentSeriesID = CacheDictType{Tuple{Ring, Int, Symbol}, Ring}()

mutable struct LaurentSeriesRingElem{T <: RingElement} <: AbstractAlgebra.RingElem
   coeffs::Vector{T}
   length::Int
   prec::Int
   val::Int
   scale::Int
   parent::LaurentSeriesRing{T}

   function LaurentSeriesRingElem{T}(a::Vector{T}, length::Int, prec::Int, val::Int, scale::Int) where T <: RingElement
      new{T}(a, length, prec, val, scale)
   end
end

###############################################################################
#
#   LaurentSeriesField / LarentSeriesFieldElem
#
###############################################################################

mutable struct LaurentSeriesField{T <: FieldElement} <: AbstractAlgebra.Field
   base_ring::Field
   prec_max::Int
   S::Symbol

   function LaurentSeriesField{T}(R::Field, prec::Int, s::Symbol, cached::Bool = true) where T <: FieldElement
      return get_cached!(LaurentSeriesID, (R, prec, s), cached) do
         new{T}(R, prec, s)
      end::LaurentSeriesField{T}
   end
end

mutable struct LaurentSeriesFieldElem{T <: FieldElement} <: AbstractAlgebra.FieldElem
   coeffs::Vector{T}
   length::Int
   prec::Int
   val::Int
   scale::Int
   parent::LaurentSeriesField{T}

   function LaurentSeriesFieldElem{T}(a::Vector{T}, length::Int, prec::Int, val::Int, scale::Int) where T <: FieldElement
      new{T}(a, length, prec, val, scale)
   end
end

const LaurentSeriesElem{T} = Union{LaurentSeriesRingElem{T}, LaurentSeriesFieldElem{T}} where T <: RingElement

###############################################################################
#
#   PuiseuxSeriesRing / PuiseuxSeriesRingElem
#
###############################################################################

mutable struct PuiseuxSeriesRing{T <: RingElement} <: AbstractAlgebra.Ring
   laurent_ring::Ring

   function PuiseuxSeriesRing{T}(R::LaurentSeriesRing{T}, cached::Bool = true) where T <: RingElement
      return get_cached!(PuiseuxSeriesID, R, cached) do
         new{T}(R)
      end::PuiseuxSeriesRing{T}
   end
end

const PuiseuxSeriesID = CacheDictType{Ring, Ring}()

mutable struct PuiseuxSeriesRingElem{T <: RingElement} <: AbstractAlgebra.RingElem
   data::LaurentSeriesRingElem{T}
   scale::Int
   parent::PuiseuxSeriesRing{T}

   function PuiseuxSeriesRingElem{T}(d::LaurentSeriesRingElem{T}, scale::Int) where T <: RingElement
      new{T}(d, scale)
   end
end

###############################################################################
#
#   PuiseuxSeriesField / PuiseuxSeriesFieldElem
#
###############################################################################

mutable struct PuiseuxSeriesField{T <: FieldElement} <: AbstractAlgebra.Field
   laurent_ring::Field

   function PuiseuxSeriesField{T}(R::LaurentSeriesField{T}, cached::Bool = true) where T <: FieldElement
      return get_cached!(PuiseuxSeriesFieldID, R, cached) do
         new{T}(R)
      end::PuiseuxSeriesField{T}
   end
end

const PuiseuxSeriesFieldID = CacheDictType{Ring, Field}()

mutable struct PuiseuxSeriesFieldElem{T <: FieldElement} <: AbstractAlgebra.FieldElem
   data::LaurentSeriesFieldElem{T}
   scale::Int
   parent::PuiseuxSeriesField{T}

   function PuiseuxSeriesFieldElem{T}(d::LaurentSeriesFieldElem{T}, scale::Int) where T <: FieldElement
      new{T}(d, scale)
   end
end

const PuiseuxSeriesElem{T} = Union{PuiseuxSeriesRingElem{T}, PuiseuxSeriesFieldElem{T}} where T <: RingElement

###############################################################################
#
#   AbsMSeriesRing / AbsMSeries
#
###############################################################################

mutable struct AbsMSeriesRing{T <: RingElement, S} <:
                                                 AbstractAlgebra.MSeriesRing{T}
   poly_ring::AbstractAlgebra.MPolyRing{T}
   prec_max::Vector{Int} # used for weights in weighted mode
   sym::Vector{Symbol} # -1 if not weighted
   weighted_prec::Int

   function AbsMSeriesRing{T, S}(poly_ring::AbstractAlgebra.MPolyRing{T},
            prec::Vector{Int}, s::Vector{Symbol}, cached::Bool = true) where
                          {T <: RingElement, S <: AbstractAlgebra.MPolyElem{T}}
      U = elem_type(poly_ring)
      return get_cached!(AbsMSeriesID, (poly_ring, prec, s, -1), cached) do
         new{T, U}(poly_ring, prec, s, -1)
      end::AbsMSeriesRing{T, S}
   end

   function AbsMSeriesRing{T, S}(poly_ring::AbstractAlgebra.MPolyRing{T},
      weights::Vector{Int}, prec::Int, s::Vector{Symbol}, cached::Bool = true) where
                    {T <: RingElement, S <: AbstractAlgebra.MPolyElem{T}}
      U = elem_type(poly_ring)
      return get_cached!(AbsMSeriesID, (poly_ring, weights, s, prec), cached) do
         new{T, U}(poly_ring, weights, s, prec)
      end::AbsMSeriesRing{T, S}
   end
end
 
const AbsMSeriesID = CacheDictType{Tuple{Ring,
                                       Vector{Int}, Vector{Symbol}, Int}, Ring}()

mutable struct AbsMSeries{T <: RingElement, S} <:
                                              AbstractAlgebra.AbsMSeriesElem{T}
   poly::S
   prec::Vector{Int}
   parent::AbsMSeriesRing{T, S}

   function AbsMSeries{T, S}(R::AbsMSeriesRing{T},
                      pol::S, prec::Vector{Int}) where
                          {T <: RingElement, S <: AbstractAlgebra.MPolyElem{T}}
      return new{T, S}(pol, prec, R)
   end
end

###############################################################################
#
#   FracField / Frac
#
###############################################################################

mutable struct FracField{T <: RingElem} <: AbstractAlgebra.FracField{T}
   base_ring::Ring

   function FracField{T}(R::Ring, cached::Bool = true) where T <: RingElem
      return get_cached!(FracDict, R, cached) do
         new{T}(R)
      end::FracField{T}
   end
end

const FracDict = CacheDictType{Ring, Ring}()

mutable struct Frac{T <: RingElem} <: AbstractAlgebra.FracElem{T}
   num::T
   den::T
   parent::FracField{T}

   Frac{T}(num::T, den::T) where T <: RingElem = new{T}(num, den)
end

###############################################################################
#
#   TotFracRing / TotFrac
#
###############################################################################

mutable struct TotFracRing{T <: RingElem} <: AbstractAlgebra.Ring
   base_ring::Ring

   function TotFracRing{T}(R::Ring, cached::Bool = true) where T <: RingElem
      return get_cached!(TotFracDict, R, cached) do
         new{T}(R)
      end::TotFracRing{T}
   end
end

const TotFracDict = CacheDictType{Ring, Ring}()

mutable struct TotFrac{T <: RingElem} <: AbstractAlgebra.RingElem
   num::T
   den::T
   parent::TotFracRing{T}

   TotFrac{T}(num::T, den::T) where T <: RingElem = new{T}(num, den)
end

###############################################################################
#
#   FactoredFracField / FactoredFrac
#
###############################################################################

mutable struct FactoredFracField{T <: RingElement} <: AbstractAlgebra.FracField{T}
   base_ring::AbstractAlgebra.Ring

   function FactoredFracField{T}(R::Ring, cached::Bool = true) where T <: RingElement
      return get_cached!(FactoredFracDict, R, cached) do
         new{T}(R)
      end::FactoredFracField{T}
   end
end

const FactoredFracDict = CacheDictType{Ring, Ring}()

mutable struct FactoredFracTerm{T <: RingElement}
   base::T
   exp::Int
end

# *** ownership conventions:
# the object owns the .terms vector but not necessarily its entries, so mutating
# the vector is allowed when mutating the object but be aware before mutating
# any entry of the vector
mutable struct FactoredFrac{T <: RingElement} <: AbstractAlgebra.FracElem{T}
   unit::T
   terms::Vector{FactoredFracTerm{T}}
   parent::FactoredFracField{T}
end

###############################################################################
#
#   RationalFunctionField / rational_function
#
###############################################################################

mutable struct RationalFunctionField{T <: FieldElement, U <: Union{PolyElem{T}, MPolyElem{T}}} <: AbstractAlgebra.Field
   S::Union{Symbol, Vector{Symbol}}
   fraction_field::FracField{U}
   base_ring::Field

   function RationalFunctionField{T, U}(k::Field, frac_field::FracField{U}, sym::Union{Symbol, Vector{Symbol}}, cached::Bool = true) where {T <: FieldElement, U <: Union{PolyElem, MPolyElem}}
      return get_cached!(RationalFunctionFieldDict, (k, sym), cached) do
         T1 = elem_type(k)
         new{T1, U}(sym, frac_field, k)
      end::RationalFunctionField{T, U}
   end
end

const RationalFunctionFieldDict = CacheDictType{Tuple{Field, Union{Symbol, Vector{Symbol}}}, Field}()

mutable struct Rat{T <: FieldElement, U <: Union{PolyElem, MPolyElem}} <: AbstractAlgebra.FieldElem
   d::Frac{U}
   parent::RationalFunctionField{T, U}

   Rat{T, U}(f::Frac{U}) where {T <: FieldElement, U <: Union{PolyElem, MPolyElem}} = new{T, U}(f)
end

###############################################################################
#
#   FunctionField / function_field_elem
#
###############################################################################

mutable struct FunctionField{T <: FieldElement} <: AbstractAlgebra.Field
   num::Poly{<:PolyElem{T}}
   den::PolyElem{T}
   S::Symbol
   powers::Vector{Poly{<:PolyElem{T}}}
   powers_den::Vector{<:PolyElem{T}}
   traces::Vector{<:PolyElem{T}}
   traces_den::PolyElem{T}
   monic::Bool
   pol::Poly{Rat{T, U}} where U <: PolyElem{T}
   base_ring::RationalFunctionField{T, U} where U <: PolyElem{T}

   function FunctionField{T}(num::Poly{<:PolyElem{T}},
             den::PolyElem{T}, s::Symbol, cached::Bool = true) where
                                                          T <: FieldElement
      return get_cached!(FunctionFieldDict, (num, den, s), cached) do
         new{T}(num, den, s)
      end::FunctionField{T}
   end
end

const FunctionFieldDict = CacheDictType{Tuple{Poly, PolyElem, Symbol}, Field}()

mutable struct FunctionFieldElem{T <: FieldElement} <: AbstractAlgebra.FieldElem
   num::Poly{<:PolyElem{T}}
   den::PolyElem{T}
   parent::FunctionField{T}

   function FunctionFieldElem{T}(R::FunctionField{T}, num::Poly{S}, den::S) where {T <: FieldElement, S <: PolyElem{T}}
      return new{T}(num, den, R)
   end
end

###############################################################################
#
#   MatSpace / Mat
#
###############################################################################

const NCRingElement = Union{NCRingElem, RingElement}

# All MatSpaceElem's and views thereof
abstract type Mat{T} <: MatElem{T} end

# not really a mathematical ring
mutable struct MatSpace{T <: NCRingElement} <: AbstractAlgebra.MatSpace{T}
   nrows::Int
   ncols::Int
   base_ring::NCRing

   function MatSpace{T}(R::NCRing, r::Int, c::Int, cached::Bool = true) where T <: NCRingElement
      return get_cached!(MatDict, (R, r, c), cached) do
         new{T}(r, c, R)
      end::MatSpace{T}
   end
end

const MatDict = CacheDictType{Tuple{NCRing, Int, Int}, MatSpace}()

mutable struct MatSpaceElem{T <: NCRingElement} <: Mat{T}
   entries::Matrix{T}
   base_ring::NCRing

   function MatSpaceElem{T}(A::Matrix{T}) where T <: NCRingElement
      return new{T}(A)
    end

   function MatSpaceElem{T}(A::AbstractMatrix{T}) where T <: NCRingElement
      return new{T}(Array(A))
   end

   function MatSpaceElem{T}(r::Int, c::Int, A::Vector{T}) where T <: NCRingElement
      t = Array{T}(undef, r, c)
      for i = 1:r
         for j = 1:c
            t[i, j] = A[(i - 1) * c + j]
         end
      end
      return new{T}(t)
   end
end

mutable struct MatSpaceView{T <: NCRingElement, V, W} <: Mat{T}
   entries::SubArray{T, 2, Matrix{T}, V, W}
   base_ring::NCRing
end

###############################################################################
#
#   MatAlgebra / MatAlgElem
#
###############################################################################

mutable struct MatAlgebra{T <: NCRingElement} <: AbstractAlgebra.MatAlgebra{T}
   n::Int
   base_ring::NCRing

   function MatAlgebra{T}(R::NCRing, n::Int, cached::Bool = true) where T <: NCRingElement
      return get_cached!(MatAlgDict, (R, n), cached) do
         new{T}(n, R)
      end::MatAlgebra{T}
   end
end

const MatAlgDict = CacheDictType{Tuple{NCRing, Int}, NCRing}()

mutable struct MatAlgElem{T <: NCRingElement} <: AbstractAlgebra.MatAlgElem{T}
   entries::Matrix{T}
   base_ring::NCRing

   function MatAlgElem{T}(A::Matrix{T}) where T <: NCRingElement
      return new{T}(A)
   end

   function MatAlgElem{T}(n::Int, A::Vector{T}) where T <: NCRingElement
      t = Array{T}(undef, n, n)
      for i = 1:n
         for j = 1:n
            t[i, j] = A[(i - 1) * c + j]
         end
      end
      return new{T}(t)
   end
end

###############################################################################
#
#   FreeAssAlgebra / FreeAssAlgElem
#
###############################################################################

mutable struct FreeAssAlgebra{T <: RingElement} <: AbstractAlgebra.FreeAssAlgebra{T}
   base_ring::Ring
   S::Vector{Symbol}

   function FreeAssAlgebra{T}(R::Ring, s::Vector{Symbol}, cached::Bool = true) where T <: RingElement
      return get_cached!(FreeAssAlgID, (R, s), cached) do
         new{T}(R, s)
      end::FreeAssAlgebra{T}
   end
end

const FreeAssAlgID = CacheDictType{Tuple{Ring, Vector{Symbol}}, NCRing}()

# *** Note on length:
# length(.coeffs), and length(.exps) may be greater than the real length .length
# *** Note on current ownership conventions in .exps:
# the object of course owns the vector .exps and can mutate its length.
# However, the object does not necessarily own the entries in the .exps vector
# and should only mutate them when sole ownership is known.
mutable struct FreeAssAlgElem{T <: RingElement} <: AbstractAlgebra.FreeAssAlgElem{T}
   parent::FreeAssAlgebra{T}
   coeffs::Vector{T}
   exps::Vector{Vector{Int}}  # TODO: Int -> UInt8 for nvars < 256, etc
   length::Int
end

# the iterators for coeffs, terms, etc. are shared with MPoly. Just this remains
struct FreeAssAlgExponentWords{T <: AbstractAlgebra.NCRingElem}
   poly::T
end

###############################################################################
#
#   CompositeMap
#
###############################################################################

mutable struct CompositeMap{D, C} <: AbstractAlgebra.Map{D, C, AbstractAlgebra.SetMap, CompositeMap}
   domain::D
   codomain::C
   map1::AbstractAlgebra.Map
   map2::AbstractAlgebra.Map

   function CompositeMap(map1, map2)
     return new{typeof(domain(map1)), typeof(codomain(map2))}(domain(map1), codomain(map2), map1, map2)
   end
end

###############################################################################
#
#   FunctionalMap
#
###############################################################################

mutable struct FunctionalMap{D, C} <: AbstractAlgebra.Map{D, C, AbstractAlgebra.FunctionalMap, FunctionalMap}
    domain::D
    codomain::C
    image_fn::Function
end

###############################################################################
#
#   IdentityMap
#
###############################################################################

struct IdentityMap{D} <: AbstractAlgebra.Map{D, D, AbstractAlgebra.IdentityMap, IdentityMap}
   domain::D
end

###############################################################################
#
#   FunctionalCompositeMap
#
###############################################################################

mutable struct FunctionalCompositeMap{D, C} <: AbstractAlgebra.Map{D, C, AbstractAlgebra.FunctionalMap, FunctionalCompositeMap}
   domain::D
   codomain::C
   map1::AbstractAlgebra.Map
   map2::AbstractAlgebra.Map
   fn_cache::Function

   function FunctionalCompositeMap(map1::Map(AbstractAlgebra.FunctionalMap){D, U}, map2::Map(AbstractAlgebra.FunctionalMap){U, C}) where {D, U, C}
      return new{D, C}(domain(map1), codomain(map2), map1, map2)
   end
end

###############################################################################
#
#   MapWithSection
#
###############################################################################

mutable struct MapWithSection{D, C} <: AbstractAlgebra.Map{D, C, AbstractAlgebra.SetMap, MapWithSection}
   map::AbstractAlgebra.Map
   section::AbstractAlgebra.Map

   function MapWithSection(map::AbstractAlgebra.Map{D, C}, section::AbstractAlgebra.Map{C, D}) where {D, C}
      (domain(map) != codomain(section) || codomain(map) != domain(section)) &&
error("Maps not compatible")
      return new{D, C}(map, section)
   end

   function MapWithSection(map::AbstractAlgebra.Map{D, C}) where {D, C}
      return new{D, C}(map)
   end
end

###############################################################################
#
#   MapWithRetraction
#
###############################################################################

mutable struct MapWithRetraction{D, C} <: AbstractAlgebra.Map{D, C, AbstractAlgebra.SetMap, MapWithRetraction}
   map::AbstractAlgebra.Map
   retraction::AbstractAlgebra.Map

   function MapWithRetraction(map::AbstractAlgebra.Map{D, C}, retraction::AbstractAlgebra.Map{C, D}) where {D, C}
      (domain(map) != codomain(retraction) || codomain(map) != domain(retraction)) &&
error("Maps not compatible")
      return new{D, C}(map, retraction)
   end

   function MapWithRetraction(map::AbstractAlgebra.Map{D, C}) where {D, C}
      return new{D, C}(map)
   end
end

###############################################################################
#
#   MapCache
#
###############################################################################

mutable struct MapCache{D, C, S, T, De, Ce} <: AbstractAlgebra.Map{D, C, S, T}
   map::AbstractAlgebra.Map{D, C}
   limit::Int
   enabled::Bool
   image_cache::Dict{De, Ce}

   function MapCache(f::AbstractAlgebra.Map{D, C, S, T}, limit::Int, enabled::Bool) where {D, C, S, T}
      De = elem_type(D)
      Ce = elem_type(C)
      r = new{D, C, S, T, De, Ce}(f, limit)
      if enabled
         r.image_cache = Dict{De, Ce}()
      end
      r.enabled = enabled
      return r
   end
end

###############################################################################
#
#   FreeModule/FreeModuleElem
#
###############################################################################

@attributes mutable struct FreeModule{T <: Union{RingElement, NCRingElem}} <: AbstractAlgebra.FPModule{T}
   rank::Int
   base_ring::NCRing

   function FreeModule{T}(R::NCRing, rank::Int, cached::Bool = true) where T <: Union{RingElement, NCRingElem}
      return get_cached!(FreeModuleDict, (R, rank), cached) do
         new{T}(rank, R)
      end::FreeModule{T}
   end
end

const FreeModuleDict = CacheDictType{Tuple{NCRing, Int}, FreeModule}()

mutable struct FreeModuleElem{T <: Union{RingElement, NCRingElem}} <: AbstractAlgebra.FPModuleElem{T}
    v::AbstractAlgebra.MatElem{T}
    parent::FreeModule{T}

    function FreeModuleElem{T}(m::AbstractAlgebra.FPModule{T}, v::AbstractAlgebra.MatElem{T}) where T <: Union{RingElement, NCRingElem}
       z = new{T}(v, m)
    end
end

###############################################################################
#
#   ModuleHomomorphism
#
###############################################################################

mutable struct ModuleHomomorphism{T <: RingElement} <: AbstractAlgebra.Map{AbstractAlgebra.FPModule{T}, AbstractAlgebra.FPModule{T}, AbstractAlgebra.FPModuleHomomorphism, ModuleHomomorphism}

   domain::AbstractAlgebra.FPModule{T}
   codomain::AbstractAlgebra.FPModule{T}
   matrix::AbstractAlgebra.MatElem{T}
   image_fn::Function

   function ModuleHomomorphism{T}(D::AbstractAlgebra.FPModule{T}, C::AbstractAlgebra.FPModule{T}, m::AbstractAlgebra.MatElem{T}) where T <: RingElement
      z = new(D, C, m, x::AbstractAlgebra.FPModuleElem{T} -> C(x.v*m))
   end
end

mutable struct ModuleIsomorphism{T <: RingElement} <: AbstractAlgebra.Map{AbstractAlgebra.FPModule{T}, AbstractAlgebra.FPModule{T}, AbstractAlgebra.FPModuleHomomorphism, ModuleIsomorphism}

   domain::AbstractAlgebra.FPModule{T}
   codomain::AbstractAlgebra.FPModule{T}
   matrix::AbstractAlgebra.MatElem{T}
   inverse_matrix::AbstractAlgebra.MatElem{T}
   image_fn::Function
   inverse_image_fn::Function

   function ModuleIsomorphism{T}(D::AbstractAlgebra.FPModule{T}, C::AbstractAlgebra.FPModule{T}, m::AbstractAlgebra.MatElem{T}, minv::AbstractAlgebra.MatElem{T}) where T <: RingElement
      z = new(D, C, m, minv, x::AbstractAlgebra.FPModuleElem{T} -> C(x.v*m), y::AbstractAlgebra.FPModuleElem{T} -> D(y.v*minv))
   end
end

###############################################################################
#
#   Submodule/SubmoduleElem
#
###############################################################################

mutable struct Submodule{T <: RingElement} <: AbstractAlgebra.FPModule{T}
   m::AbstractAlgebra.FPModule{T}
   gens::Vector{<:AbstractAlgebra.FPModuleElem{T}}
   rels::Vector{<:AbstractAlgebra.MatElem{T}}
   gen_cols::Vector{Int}
   pivots::Vector{Int}
   base_ring::Ring
   map::ModuleHomomorphism{T}

   function Submodule{T}(M::AbstractAlgebra.FPModule{T}, gens::Vector{<:AbstractAlgebra.FPModuleElem{T}}, rels::Vector{<:AbstractAlgebra.MatElem{T}}, gen_cols::Vector{Int}, pivots::Vector{Int}) where T <: RingElement
      z = new{T}(M, gens, rels, gen_cols, pivots, base_ring(M))
   end
end

mutable struct SubmoduleElem{T <: RingElement} <: AbstractAlgebra.FPModuleElem{T}
   v::AbstractAlgebra.MatElem{T}
   parent::Submodule{T}

   function SubmoduleElem{T}(m::AbstractAlgebra.FPModule{T}, v::AbstractAlgebra.MatElem{T}) where T <: RingElement
      z = new{T}(v, m)
   end
end

###############################################################################
#
#   QuotientModule/QuotientModuleElem
#
###############################################################################

mutable struct QuotientModule{T <: RingElement} <: AbstractAlgebra.FPModule{T}
   m::AbstractAlgebra.FPModule{T}
   rels::Vector{<:AbstractAlgebra.MatElem{T}}
   gen_cols::Vector{Int} # which original columns correspond to gens of quotient
   pivots::Vector{Int} # pivot column of each culled relation in new rels matrix
   base_ring::Ring
   map::ModuleHomomorphism{T}

   function QuotientModule{T}(M::AbstractAlgebra.FPModule{T}, combined_rels::AbstractAlgebra.MatElem{T}) where T <: RingElement
      # concatenate relations in M and new rels
      R = base_ring(M)
      # remove zero rows and all rows/cols corresponding to unit pivots
      gen_cols, culled, pivots = cull_matrix(combined_rels)
      # put all the culled relations into new relations
      new_rels = [matrix(R, 1, length(gen_cols),
                    [combined_rels[culled[i], gen_cols[j]]
                       for j in 1:length(gen_cols)]) for i = 1:length(culled)]
      # create quotient module
      z = new{T}(M, new_rels, gen_cols, pivots, base_ring(M))
      return z
   end
end

mutable struct QuotientModuleElem{T <: RingElement} <: AbstractAlgebra.FPModuleElem{T}
   v::AbstractAlgebra.MatElem{T}
   parent::QuotientModule{T}

   function QuotientModuleElem{T}(m::AbstractAlgebra.FPModule{T}, v::AbstractAlgebra.MatElem{T}) where T <: RingElement
      z = new{T}(v, m)
   end
end

###############################################################################
#
#   SNFModule/SNFModuleElem
#
###############################################################################

mutable struct SNFModule{T <: RingElement} <: AbstractAlgebra.FPModule{T}
   m::AbstractAlgebra.FPModule{T}
   gens::Vector{<:AbstractAlgebra.FPModuleElem{T}}
   invariant_factors::Vector{T}
   base_ring::Ring
   map::ModuleIsomorphism{T}

   function SNFModule{T}(M::AbstractAlgebra.FPModule{T}, gens::Vector{<:AbstractAlgebra.FPModuleElem{T}}, invariant_factors::Vector{T}) where T <: RingElement
      return new{T}(M, gens, invariant_factors, base_ring(M))
   end
end

mutable struct SNFModuleElem{T <: RingElement} <: AbstractAlgebra.FPModuleElem{T}
   v::AbstractAlgebra.MatElem{T}
   parent::SNFModule{T}

   function SNFModuleElem{T}(m::AbstractAlgebra.FPModule{T}, v::AbstractAlgebra.MatElem{T}) where T <: RingElement
      z = new{T}(v, m)
   end
end

###############################################################################
#
#   DirectSumModule/DirectSumModuleElem
#
###############################################################################

mutable struct DirectSumModule{T <: RingElement} <: AbstractAlgebra.FPModule{T}
   m::Vector{<:AbstractAlgebra.FPModule{T}}
   rels::Vector{<:AbstractAlgebra.MatElem{T}}
   inj::Vector{<:ModuleHomomorphism{T}}
   pro::Vector{<:ModuleHomomorphism{T}}

   function DirectSumModule{T}(m::Vector{<:AbstractAlgebra.FPModule{T}}, rels::Vector{<:AbstractAlgebra.MatElem{T}}) where T <: RingElement
      return new{T}(m, rels)
   end
end

mutable struct DirectSumModuleElem{T <: RingElement} <: AbstractAlgebra.FPModuleElem{T}
   v::AbstractAlgebra.MatElem{T}
   parent::DirectSumModule{T}

   function DirectSumModuleElem{T}(m::AbstractAlgebra.FPModule{T}, v::AbstractAlgebra.MatElem{T}) where T <: RingElement
      z = new{T}(v, m)
   end
end

###############################################################################
#
#   IdealSet/Ideal
#
###############################################################################

mutable struct IdealSet{T <: RingElement} <: AbstractAlgebra.Set
   base_ring::Ring

   function IdealSet{T}(R::Ring, cached::Bool = true) where T <: RingElement
      return get_cached!(IdealSetDict, R, cached) do
         new{T}(R)
      end::IdealSet{T}
   end
end

const IdealSetDict = CacheDictType{Ring, IdealSet}()

mutable struct Ideal{T <: RingElement} <: AbstractAlgebra.Ideal{T}
    gens::Vector{T}
    base_ring::Ring

    function Ideal{T}(R::Ring, gens::Vector{T}) where T <: RingElement
       z = new{T}(gens, R)
    end
end
