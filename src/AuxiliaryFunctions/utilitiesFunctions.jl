#unit step function
function u(t::Float64)::Float64 #unit step function
    return ifelse( t < 0, zero(t), one(t) )
end

#unnormalized Gaussian function
function 𝒩ᵤ(x::Float64; μ::Float64, σ::Float64)::Float64
    return exp(-0.5 * ((x - μ) / σ)^2)
end

#normalized Gaussian function
function 𝒩(x::Float64; μ::Float64, σ::Float64)::Float64
    return 1 / (σ * sqrt(2 * π)) * exp(-0.5 * ((x - μ) / σ)^2)
end

#Dirac delta (Gaussian approximation) amplitude normalized
function δn(t::Float64,σ::Float64=1.0e-11)::Float64
   return 𝒩ᵤ(t, μ=0.0, σ=σ)
end

#Dirac delta (Gaussian approximation) unit area
function δ(t::Float64,σ::Float64=1.0e-10)::Float64
   return 𝒩(t, μ=0.0, σ=σ)
end
