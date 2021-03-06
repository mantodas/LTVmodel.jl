
#------------------------------
#DEFINE STATIONARY LISTENER w/ OMNIDIRECTIONAL ANTENNA

struct stationaryListenerOmnidirectional
   sourceList::Vector{Source}
   position::Vector{Float64}
end

function (listener::stationaryListenerOmnidirectional)(tā::Float64)
sourceList = listener.sourceList
š©įµ£ = listener.position
   val = 0.0
   for i = 1:length(sourceList)
      val+=sourceList[i](š©įµ£,tā)
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

function (listener::stationaryListenerDirectional)(tā::Float64)
   sourceList = listener.sourceList
   š©įµ£ = listener.position
   š, G = listener.beamCenter , listener.antennaGain
      val = 0.0
      for i = 1:length(sourceList)
         if isa(sourceList[i],movingSource)
            val+=sourceList[i](š©įµ£,tā) * G( angleBetween(š, š©įµ£-sourceList[i].position(tā)) )
         else
            val+=sourceList[i](š©įµ£,tā) * G( angleBetween(š, š©įµ£-sourceList[i].position) )
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

function (listener::movingListenerOmnidirectional)(tā::Float64)
sourceList = listener.sourceList
š©įµ£ = listener.position
   val = 0.0
   for i = 1:length(sourceList)
      val+=sourceList[i](š©įµ£(tā),tā)
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

function (listener::movingListenerDirectional)(tā::Float64)
sourceList = listener.sourceList
š©įµ£ = listener.position
š, G = listener.beamCenter , listener.antennaGain
   val = 0.0
   for i = 1:length(sourceList)
      if isa(sourceList[i],movingSource)
         val+=sourceList[i](š©įµ£(tā),tā) * G( angleBetween(š(tā), š©įµ£(tā)-sourceList[i].position(tā)) )
      else
         val+=sourceList[i](š©įµ£(tā),tā) * G( angleBetween(š(tā), š©įµ£(tā)-sourceList[i].position) )
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
