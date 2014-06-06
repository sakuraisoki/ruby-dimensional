#!/usr/bin/env ruby

require "ruby-dimensional"
require "ruby-dimensional-standard"
require "ruby-dimensional-physics"

include Physics
         
#UV.showAllUnits

UV.DefineUserUnit :b, 1e-28*(:m**2)
E = 10.0*:MeV 
Nstep = 128
thetas = (1..Nstep).to_a.map{|x| 2.0*Math::PI*x/Nstep}
thetas.each{|theta|
   crosssection = Formula.KleinNishina(E, theta)
   puts "%f %f" % [theta, crosssection.in(:b)]
}
