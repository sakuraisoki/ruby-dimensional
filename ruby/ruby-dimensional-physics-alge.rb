require "ruby-dimensional-physics"
require "ruby-alge"
require "ruby-alge-function"

module Physics
   module Formula
      def KleinNishina()
         e = Alge.new(:E)
         th = Alge.new(:theta)
         
         cos = Alge.new(:cos, [th])
         re = Constant::ClassicalElectronRadius
         p = 1.0/( 1.0 + e/(511.0*:keV)*(1.0-cos) )
         return 0.5*(re**2)*(p**2)*(p+1.0/p + cos**2 -1)
      end
      module_function :KleinNishina


      def ComptonScatterEnergy()
         e = Alge.new(:E)
         th = Alge.new(:theta)
         
         cos = Alge.new(:cos, [th])
         return e/(1.0 + e/(511.0*:keV)*(1.0-cos))
      end
      module_function :ComptonScatterEnergy


      def EddingtonLuminosity()
         # for solar abundance
         m = Alge.new(:M)         
         return (1.5e+38* :erg/:s) * (m / Constant::Msun)
      end
      module_function :EddingtonLuminosity

      def NSEddingtonLuminosity()
         return (1.5e+38* :erg/:s) * 1.4
      end
      module_function :NSEddingtonLuminosity
      class << self
         alias_method :NSLedd, :NSEddingtonLuminosity
      end

      def AlfvenRadius()
         mdot = Alge.new(:Mdot)
         b = Alge.new(:B)
         return (6.8e+3*:km)*(mdot / (1e-10*:Msun/:yr))**(-2/7r)*(b / (1e12*:G))**(4/7r)
      end
      module_function :AlfvenRadius

      def CorotationRadius()
         p = Alge.new(:P)
         m = Alge.new(:M)
         return (Constant::G*m/(4.0*Math::PI**2))**(1/3r) * p**(2/3r)
      end
      module_function :CorotationRadius

      def NSCorotationRadius()
         p = Alge.new(:P)
         return (Constant::G*1.4*Constant::Msun/(4.0*Math::PI**2))**(1/3r) * p**(2/3r)
      end
      module_function :NSCorotationRadius

      def NSMassAccretionRate()
         l = Alge.new(:L)
         return l*(10*:km/(Constant::G*1.4*Constant::Msun))
      end
      module_function :NSMassAccretionRate
      class << self
         alias_method :NSMdot, :NSMassAccretionRate         
      end

      def SchwarzschildRadius()
         m = Alge.new(:M)
         return 2*Physics::Constant::G*m/(Physics::Constant::LightSpeed**2)
      end
      module_function :SchwarzschildRadius

      def PlasmaFrequency()
         n = Alge.new(:n)
         e = Physics::Constant::ElementaryCharge
         me = Physics::Constant::ElectronMass
         eps0 = Physics::Constant::Epsilon0
         return (n*e**2/(me*eps0))**(1/2r)
      end
      module_function :PlasmaFrequency
   end
end