
#------------------------------
#DEFINE STATIONARY SOURCE w/ OMNIDIRECTIONAL ANTENNA
# LTIsource [𝚽] i.e 𝚽 = LTISource(𝐩ₛ,p)

struct LTISource
  position::Vector{Float64}
  transmission ::Function
end

# This function returns q(ξ,t) = 𝚽(ξ,t)

function (source::LTISource)(𝛏₀::Vector{Float64}, t₀::Float64)
   𝐩ₛ, p, = source.position, source.transmission
   delay = distBetween(𝐩ₛ,𝛏₀)/lightSpeed
   return A(delay) * p(t₀-delay)
end


#------------------------------
#DEFINE STATIONARY SOURCE w/ DIRECTIONAL ANTENNA and TIME-INVARIANT BEAM CENTER

struct stationarySourceDirectionalTI
  position::Vector{Float64}
  transmission ::Function
  beamCenter::Vector{Float64}
  antennaGain ::Function
end

function (source::stationarySourceDirectionalTI)(𝛏₀::Vector{Float64}, t₀::Float64)
   𝐩ₛ, p, = source.position, source.transmission
   𝐛, G = source.beamCenter , source.antennaGain
   delay = distBetween(𝐩ₛ,𝛏₀)/lightSpeed
   return A(delay) * p(t₀-delay) * G( angleBetween(𝐛, 𝛏₀-𝐩ₛ) )
end


#------------------------------
#DEFINE STATIONARY SOURCE w/ DIRECTIONAL ANTENNA and TIME-VARYING BEAM CENTER

struct stationarySourceDirectional
  position::Vector{Float64}
  transmission ::Function
  beamCenter::Function
  antennaGain ::Function
end

function (source::stationarySourceDirectional)(𝛏₀::Vector{Float64}, t₀::Float64)
   𝐩ₛ, p, = source.position, source.transmission
   𝐛, G = source.beamCenter , source.antennaGain
   delay = distBetween(𝐩ₛ,𝛏₀)/lightSpeed
   return A(delay) * p(t₀-delay) * G( angleBetween(𝐛(t₀-delay), 𝛏₀-𝐩ₛ) )
end


#------------------------------
#DEFINE MOVING SOURCE w/ OMNIDIRECTIONAL ANTENNA

struct movingSourceOmnidirectional
  position::Function
  transmission ::Function
end

function (source::movingSourceOmnidirectional)(𝛏₀::Vector{Float64}, t₀::Float64)
   𝐩ₛ, p, = source.position, source.transmission
   TXₜ = RXₜ2TXₜ(𝛏₀, t₀, 𝐩ₛ)
   return A(t₀-TXₜ) * p(TXₜ)
end

#------------------------------
#DEFINE MOVING SOURCE w/ DIRECTIONAL ANTENNA and TIME-VARYING BEAM CENTER

struct movingSourceDirectional
  position::Function
  transmission ::Function
  beamCenter::Function
  antennaGain ::Function
end

function (source::movingSourceDirectional)(𝛏₀::Vector{Float64}, t₀::Float64)
   𝐩ₛ, p, = source.position, source.transmission
   𝐛, G = source.beamCenter , source.antennaGain
   TXₜ = RXₜ2TXₜ(𝛏₀, t₀, 𝐩ₛ)
   return A(t₀-TXₜ) * p(TXₜ) * G( angleBetween(𝐛(TXₜ), 𝛏₀-𝐩ₛ(TXₜ)) )
end

#------------------------------
#DEFINE GENERAL SOURCE AND METHODS

stationarySource = Union{  stationarySourceOmnidirectional,
                           stationarySourceDirectionalTI,
                           stationarySourceDirectional,
                           }

movingSource = Union{   movingSourceOmnidirectional,
                        movingSourceDirectional,
                        }

Source = Union{stationarySource,
               movingSource,
               }

#multi-thread model evaluation over a 2D/3D space
function (q::Source)(𝛏::Array{Array{Float64,1}}, t₀::Float64)
   Q = zeros( typeof(q(𝛏[1], t₀)), size(𝛏))
   Threads.@threads for i =1:length(𝛏)
      Q[i] = q(𝛏[i], t₀)
   end
   return Q
end

#multi-thread model evaluation over a time interval
function (q::Source)(𝛏₀::Vector{Float64}, t::Vector{Float64})
   Q = zeros( typeof(q(𝛏₀, 0.0)), size(𝛏))
   Threads.@threads for i =1:length(t)
      Q[i] = q(𝛏₀, t[i])
   end
   return Q
end
