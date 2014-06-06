require "ruby-dimensional"

module Physics
   module Constant
      GravitationalConstant = 6.67384e-11*(:m**3/:kg/:s**2)
      G = GravitationalConstant
      LightSpeed = 299792458.0*(:m/:s)
      SolarMass = 1.988e+30*:kg
      Msun = SolarMass
      ElectronMass = 9.11e-28*:g
      ClassicalElectronRadius = 2.8179403267e-15*:m
      StandardGraviry = 9.80665*(:m/:s**2)
   end

   UV.DefineUserUnit :Msun,   Constant::Msun

   module Formula
      def KleinNishina(photonEnergy,theta)
         energy = photonEnergy
         e = 0.0
         th = 0.0
         if energy.is_a?(UV)
            e = energy.in(:keV)
         else
            e = energy
         end
         if theta.is_a?(UV) then
            if theta.nonDimensional? then
               th = theta.sifactor
            else
               raise "Physical:Formula:KleinNishina: theta must be dimensionless"
            end
         else
            th = theta
         end
         
         cos = Math.cos(th)
         re = Physics::Constant::ClassicalElectronRadius
         p = 1.0/( 1.0 + e/511.0*(1.0-cos) )
         return 0.5*(re**2)*(p**2)*(p+1.0/p + cos**2 -1)
      end
      module_function :KleinNishina

      def SchwarzschildRadius(mass)
         return 2*Physics::Constant::G*mass/(Physics::Constant::LightSpeed**2)
      end
      module_function :SchwarzschildRadius
   end
end