#!/usr/bin/env ruby

require "ruby-dimensional"
require "ruby-dimensional-standard"
require "ruby-dimensional-physics"

include Physics

         
UV.DefineUserUnit :Msun, Constant::Msun
UV.DefineUserUnit :c, Constant::LightSpeed

UV.setUnitBasis [:keV, :c, :s, :A, :K]

c = Constant::LightSpeed   
Me = Constant::ElectronMass
Mns = 1.4*Constant::Msun
Rns = 10.0*:km
E = (Constant::G*Mns*Me)/Rns

#non-relativistic
vnr = (2*E/Me)**(1/2r)
puts vnr

#relativistic
theta = E/(Me*c**2)
beta = (theta**2 /(theta**2 + 1.0) )**(1/2r) 
puts beta
