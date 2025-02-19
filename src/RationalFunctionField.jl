###############################################################################
#
#   RationalFunctionField.jl : Rational function fields
#
###############################################################################

export RationalFunctionField, norm

###############################################################################
#
#   RationalFunctionField constructor
#
###############################################################################

function RationalFunctionField(k::Field, s::Symbol; cached=true)
   return Generic.RationalFunctionField(k, s; cached=cached)
end

function RationalFunctionField(k::Field, s::Char; cached=true)
   return Generic.RationalFunctionField(k, Symbol(s); cached=cached)
end

function RationalFunctionField(k::Field, s::AbstractString; cached=true)
   return Generic.RationalFunctionField(k, Symbol(s); cached=cached)
end

function RationalFunctionField(k::Field, s::Vector{Symbol}; cached=true)
   return Generic.RationalFunctionField(k, s; cached=cached)
end

function RationalFunctionField(k::Field, s::Vector{Char}; cached=true)
   return Generic.RationalFunctionField(k, [Symbol(si) for si in s]; cached=cached)
end

function RationalFunctionField(k::Field, s::Vector{String}; cached=true)
   return Generic.RationalFunctionField(k, [Symbol(si) for si in s]; cached=cached)
end



