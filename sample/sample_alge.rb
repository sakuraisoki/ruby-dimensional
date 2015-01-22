#!/usr/bin/env ruby

require "ruby-alge"
require "ruby-alge-function"

require "ruby-dimensional"
require "ruby-dimensional-standard"
require "ruby-dimensional-physics"

require "ruby-dimensional-alge"
require "ruby-dimensional-physics-alge"

include Physics

UV.setUnitBasis [:keV, :km, :s, :G, :kb]

######################################################################
# Compton photon index to y-parameter
g = Alge.new(:Gamma)
y = Alge.new(:y)

puts "%f +/- %f" % 
(g === (4.0/y + 9.0/4.0)**(1/2r) -1.0/2.0)
.solve(:y)
.valueWithError({
    :Gamma => [2.1, 0.2]
})
#=> y = 0.9 +/- 0.2
######################################################################



######################################################################
# Eddington temperature at an NS surface
tbb = Alge.new(:Tbb)
rbb = Alge.new(:Rbb)

sigma = Constant::StefanBoltzmannConstant
equation = (4*3.14*sigma*tbb**4*rbb**2 === Formula.EddingtonLuminosity())
puts equation.solve(:Tbb).value({
    :M => 1.4*Constant::SolarMass,
    :Rbb => 10*:km    
})
#=> Tedd ~ 2 keV
######################################################################



######################################################################
# Alfven radius compared with corotation radius (in Vela X-1)
f = Alge.new(:f)

puts (Formula.AlfvenRadius() === f*Formula.NSCorotationRadius())
.solve(:f)
.value({
    :B => 2e12 * :G,
    :P => 280 *:s,
    :Mdot => Formula.NSMdot().value({:L => 5e36*:erg/:s})
})
##=> Ra ~ 0.1 Rco
######################################################################
