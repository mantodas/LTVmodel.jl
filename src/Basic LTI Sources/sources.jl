
#------------------------------
#DEFINE STATIONARY SOURCE w/ OMNIDIRECTIONAL ANTENNA

struct LTISource
  position::Vector{Float64}
  transmission ::Function
end


# Method
function (ğ½::LTISource)(ğâ::Vector{Float64}, tâ::Float64)
   ğ©â, p = ğ½.position, ğ½.transmission
   delay = distBetween(ğ©â,ğâ)/lightSpeed
   return A(delay) * p(tâ-delay)
end

#-----------------------------------------------------------

struct Target
   coefficient::Vector{Float64}
   position::Vector{Vector{Float64}}
end

function(T::Target)(tâ::Float64)
Î±â = T.coefficient
ğâ = T.position

for i = 1:length(ğâ)
    r = Î±â[i].*ğ½(ğâ[i],tâ)  # transmission
end
end
