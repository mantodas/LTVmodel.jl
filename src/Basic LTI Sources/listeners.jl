
#------------------------------
#DEFINE STATIONARY LISTENER w/ OMNIDIRECTIONAL ANTENNA

struct stationaryListenerOmnidirectional
   sourceList::Vector{Source}
   position::Vector{Float64}
end

function (listener::stationaryListenerOmnidirectional)(t₀::Float64)
sourceList = listener.sourceList
𝐩ᵣ = listener.position
   val = 0.0
   for i = 1:length(sourceList)
      val+=sourceList[i](𝐩ᵣ,t₀)
   end
   return val
end


#------------------------------
#DEFINE STATIONARY LISTENER w/ DIRECTIONAL ANTENNA and TIME-INVARIANT BEAM CENTER

struct stationaryListenerDirectional
   sourceList::Vector{Source}
   position::Vector{Float64}
   beamCenter::Vector{Float64}
   antennaGain ::Function
end

function (listener::stationaryListenerDirectional)(t₀::Float64)
   sourceList = listener.sourceList
   𝐩ᵣ = listener.position
   𝐛, G = listener.beamCenter , listener.antennaGain
      val = 0.0
      for i = 1:length(sourceList)
         if isa(sourceList[i],movingSource)
            val+=sourceList[i](𝐩ᵣ,t₀) * G( angleBetween(𝐛, 𝐩ᵣ-sourceList[i].position(t₀)) )
         else
            val+=sourceList[i](𝐩ᵣ,t₀) * G( angleBetween(𝐛, 𝐩ᵣ-sourceList[i].position) )
         end
      end
      return val
end


#------------------------------
#DEFINE MOVING LISTENER w/ OMNIDIRECTIONAL ANTENNA

struct movingListenerOmnidirectional
   sourceList::Vector{Source}
   position::Function
end

function (listener::movingListenerOmnidirectional)(t₀::Float64)
sourceList = listener.sourceList
𝐩ᵣ = listener.position
   val = 0.0
   for i = 1:length(sourceList)
      val+=sourceList[i](𝐩ᵣ(t₀),t₀)
   end
   return val
end

#------------------------------
#DEFINE MOVING LISTENER w/ DIRECTIONAL ANTENNA and TIME-VARYING BEAM CENTER

struct movingListenerDirectional
   sourceList::Vector{Source}
   position::Function
   beamCenter::Function
   antennaGain ::Function
end

function (listener::movingListenerDirectional)(t₀::Float64)
sourceList = listener.sourceList
𝐩ᵣ = listener.position
𝐛, G = listener.beamCenter , listener.antennaGain
   val = 0.0
   for i = 1:length(sourceList)
      if isa(sourceList[i],movingSource)
         val+=sourceList[i](𝐩ᵣ(t₀),t₀) * G( angleBetween(𝐛(t₀), 𝐩ᵣ(t₀)-sourceList[i].position(t₀)) )
      else
         val+=sourceList[i](𝐩ᵣ(t₀),t₀) * G( angleBetween(𝐛(t₀), 𝐩ᵣ(t₀)-sourceList[i].position) )
      end
   end
   return val
end



#------------------------------
#DEFINE GENERAL LISTENER
stationaryListener = Union{   stationaryListenerOmnidirectional,
                              stationaryListenerDirectional,
                              }

movingListener = Union{ movingListenerOmnidirectional,
                        movingListenerDirectional,
                        }

Listener = Union{ stationaryListener,
                  movingListener,
                  }

#multi-thread model evaluation over a time interval
function (z::Listener)(t::Vector{Float64})
   Z = zeros( typeof(z(0.0)), size(t))
   Threads.@threads for i = 1:length(t)
      Z[i] = z(t[i])
   end
   return Z
end
