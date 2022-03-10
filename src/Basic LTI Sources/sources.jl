
#------------------------------
#DEFINE STATIONARY SOURCE w/ OMNIDIRECTIONAL ANTENNA
# LTIsource [𝚽] i.e 𝚽 = LTISource(𝐩ₛ,p)

struct LTISource
  position::Vector{Float64}
  transmission ::Function
end


# Method
function (𝚽::LTISource)(𝛏₀::Vector{Float64}, t₀::Float64)
   𝐩ₛ, p = 𝚽.position, 𝚽.transmission
   delay = distBetween(𝐩ₛ,𝛏₀)/lightSpeed
   return A(delay) * p(t₀-delay)
end

#-----------------------------------------------------------

struct Target
   coefficient::Vector{Float64}
   position::Vector{Vector{Float64}}
end


function(T::Target)(t₀::Float64)
αₖ = T.coefficient
𝛏ₖ = T.position
# how to define length of these vectors should be same
for i = 1:length(𝛏ₖ)
    r = αₖ[i].*𝚽(𝛏ₖ[i],t₀)
end
end
