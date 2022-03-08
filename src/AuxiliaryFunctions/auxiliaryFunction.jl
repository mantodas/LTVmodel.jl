#DECLARE PHYSICAL CONSTANTS AND FUNCTIONS

const lightSpeed = 299_792_458.0
const μ₀ = 1.25663706212e-6
const Z₀ = μ₀*lightSpeed

#amplitude-scale due to divergence
function A(t₀::Float64)::Float64
   return sqrt(Z₀)/(sqrt(4π)*lightSpeed*t₀)
end

#---------------------------------------------
#DECLARE SPECIAL FUNCTIONS

function NaNnormalize(𝛏₀::Vector{Float64})::Vector{Float64}
   return ifelse( norm(𝛏₀)==0, zero(𝛏₀), normalize(𝛏₀) )
end

function angleBetween(𝛏₀::Vector{Float64},𝛏₁::Vector{Float64})::Float64
   return acos(dot(NaNnormalize(𝛏₁),NaNnormalize(𝛏₀)))
end

function distBetween(𝛏₀::Vector{Float64}, 𝛏₁::Vector{Float64})::Float64
   return norm(𝛏₀ - 𝛏₁)
end

function TXₜ2RXₜ(𝛏₀::Vector{Float64}, t₀::Float64, 𝐩ₛ::Function)::Float64
   return t₀ + distBetween(𝛏₀, 𝐩ₛ(t₀))/lightSpeed
end

function RXₜ2TXₜ(𝛏₀::Vector{Float64}, t₀::Float64, 𝐩ₛ::Function)::Float64
   return find_zero(t -> (TXₜ2RXₜ(𝛏₀, t, 𝐩ₛ) - t₀), t₀ + distBetween(𝛏₀, 𝐩ₛ(t₀)))
end
