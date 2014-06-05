require "matrix"

class UV
   @@unitBasisSI = []
   @@unitBasis = []
   @@unitBasisInverse = nil
   @@userUnitDefs = {}
   @@prefixDefs = {""=>1, "T"=>1e12, "G"=>1e9, "M"=>1e6, "k"=>1e3, "c"=>1e-2, "m"=>1e-3, "u"=>1e-6, "n"=>1e-9, "p"=>1e-12, "f"=>1e-15}
   def initialize(f=1.0, dim=Vector[0r, 0r, 0r, 0r, 0r], uvname="")
      @name = uvname.to_s
      @value = f
      @dimension = dim
   end
   
   def UV.showAllUnits
      @@userUnitDefs.each{|n,u|
         val = u.sifactor
         dims = u.dimension
         ustr = ""
         dims.size.times{|i|
            if dims[i] ==0 then
            elsif dims[i]==1 then
               ustr += @@unitBasis[i].name + " "
            else
               ustr += @@unitBasis[i].name + "**"+(dims[i].denominator==1? dims[i].numerator.to_s : dims[i].to_s)+" "
            end
         }
         puts n+" = "+(val.to_s)+" "+ustr.strip
      }
   end
   
   def UV.DefineUserUnit(uname, u)
      unitname = uname.to_s
      if u.is_a?(UV) then
         u.rename(unitname)
         @@userUnitDefs[unitname] = u
      elsif u.is_a?(Symbol) then
         definedunit = UV.findUnit(u.to_s).clone
         definedunit.rename(unitname)
         @@userUnitDefs[unitname] = definedunit
      else
         raise "UV: cannot define via "+u.class.to_s
      end
   end

   def UV.isUnitDefined?(unitname)
      n = unitname.to_s
      return @@userUnitDefs.include?(n)
   end
   
   def UV.dividePrefix(ustr)
      if @@userUnitDefs.include?(ustr)  then
         return ["",ustr]
      else
         @@prefixDefs.each_key{|p|
            if p!= "" then
               if ustr.start_with?(p) then
                  u = ustr.sub(p,"")
                  return [p,u] if @@userUnitDefs.include?(u)
               end
            end
         }
         raise "UV: no such unit "+ustr
      end
   end

   def UV.findUnit(unitname)
      pref, n = dividePrefix(unitname)
      if pref=="" then
         return @@userUnitDefs[n]
      else
         un = @@userUnitDefs[n]
         return UV.new(@@prefixDefs[pref]*un.sifactor, un.dimension, unitname)
      end
   end
   
   def UV.setUnitBasis(units)
      if units.length != 5 then
         raise "UV: unit basis must be 5-dimensional"
      else
         ds = units.map{|u| 
         if u.is_a?(UV) then
            u.dimension
         else
            u.toUV.dimension
         end
         }
         m = Matrix[ds[0],ds[1],ds[2],ds[3],ds[4]]
         if m.regular? then
            @@unitBasis.clear
            units.map{|u| u.toUV}.each{|u|
               @@unitBasis.push(u)
            }
            @@unitBasisInverse = m.inverse.transpose
         else
            raise "UV: unit basis must be 5-dimensional"
         end
      end
   end

   def name
      return @name
   end
   def rename(n)
      @name = n.to_s
   end
   
   def sifactor
      return @value
   end

   def dimension
      return @dimension
   end
   
   def nonDimensional?
      return @dimension==Vector[0r,0r,0r,0r,0r]
   end

   def *(u)
      if u.is_a?(UV)
         return UV.new(@value*u.sifactor, @dimension+u.dimension, @name+" "+u.name)
      elsif u.is_a?(Symbol) then
         un = UV.findUnit(u.to_s)
         return UV.new(@value*un.sifactor, @dimension+un.dimension, @name+"*"+un.to_s)          
      else
         return UV.new(@value*u, @dimension, u.to_s+"*"+@name)
      end
   end

   def /(u)
      sep = "/"
      if u.is_a?(UV)
         return UV.new(@value/u.sifactor, @dimension-u.dimension, @name+sep+u.name)
      elsif u.is_a?(Symbol) then
         un = UV.findUnit(u.to_s)
         return UV.new(@value/un.sifactor, @dimension-un.dimension, @name+sep+un.to_s)          
      else
         return UV.new(@value/u, @dimension, @name+sep+u.to_s)
      end
   end
         
   def +(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         UV.new(@value+un.sifactor, @dimension, @name)
      else
         p self
         raise "UV: cannot be added with "+un.dimension.to_s
      end
   end
   def add(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         @value += un.sifactor
      else
         p self
         raise "UV: cannot be added with "+un.dimension.to_s
      end
   end

   def -(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         UV.new(@value-un.sifactor, @dimension, @name)
      else
         p self
         raise "UV: cannot be subtracted by "+un.dimension.to_s
      end
   end
   def sub(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         @value -= un.sifactor
      else
         p self
         raise "UV: cannot be subtracted by "+un.dimension.to_s
      end
   end
   def -@
      UV.new(-@value, @dimension, "-"+@name)
   end


   def <(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         return @value < un.sifactor
      else
         p self
         raise "UV: cannot compare with "+un.dimension.to_s
      end
   end
   def <=(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         return @value <= un.sifactor
      else
         p self
         raise "UV: cannot compare with "+un.dimension.to_s
      end
   end

   def >(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         return @value > un.sifactor
      else
         p self
         raise "UV: cannot compare with "+un.dimension.to_s
      end
   end
   def >=(u)
      un = u.is_a?(UV)? u : u.toUV
      if @dimension==un.dimension then
         return @value >= un.sifactor
      else
         p self
         raise "UV: cannot compare with "+un.dimension.to_s
      end
   end
      
   def **(d)
      r = 0.0
      if d.is_a?(Numeric) then
         r = d.rationalize
      elsif d.is_a?(UV) then
         if d.nonDimensional? then
            r = d.sifactor.rationalize
         else
            raise "UV: cannot be powered to UV with unit "+d.dimension.to_s
         end
      else
         raise "UV: cannot be powered to "+r.class.to_s
      end
      
      if r==1 then
         return UV.new(@value, @dimension, @name)
      elsif r==0 then
         return UV.new()
      elsif r.denominator==1 then
         return UV.new(@value**r, @dimension*r, @name+"**"+r.numerator.to_s+"")
      else
         return UV.new(@value**r, @dimension*r, @name+"**("+r.to_s+")")
      end
   end

   def toUV
      return self
   end

   def in(u)
      unit = u.toUV
      if @dimension==unit.dimension then
         f = unit.sifactor
         return @value / f
      else
         raise "UV: cannot convert "+@dimension.to_s+" to "+unit.dimension.to_s
      end
   end
   
   def value(u=nil)
      if u!=nil then
      else
         return self.getValueAndDimension()[0]
      end
   end

   def getValueAndDimension()
      f = 1.0
      v = @@unitBasisInverse * @dimension
      v.size.times{|i|
         if v[i]!=0 then
            f *= (@@unitBasis[i].sifactor ** v[i] )
         end
      }
      return [@value / f, v]
   end
      
   def to_s(format="%.3e", u=nil)
      if u!=nil then
         return (format % self.in(u))+" "+u.name
      else
         val, dims = self.getValueAndDimension()
         ustr = ""
         dims.size.times{|i|
            if dims[i] ==0 then
            elsif dims[i]==1 then
               ustr += @@unitBasis[i].name + " "
            else
               ustr += @@unitBasis[i].name + "**"+(dims[i].denominator==1? dims[i].numerator.to_s : dims[i].to_s)+" "
            end
         }
         return (format % val)+" "+ustr.strip
      end
   end
end


class Symbol
   def toUV
      name = self.to_s
      return UV.findUnit(name)
   end

   def *(s)
      if s.is_a?(UV) then
         return self.toUV()*s
      else
         return self.toUV()*s
      end
   end

   def /(s)
      if s.is_a?(UV) then
         return self.toUV()/s
      else
         return self.toUV()/s
      end
   end

   def **(d)
      return self.toUV()**d
   end
end
         



class Float
   ["dummy"].each do |opr|
      define_method("multiplyWithUV") do |operand|
         if operand.is_a?(UV) then
            return operand*self
         elsif operand.is_a?(Symbol) then
            return operand.toUV()*self
         else
            return dummymultiply(operand)
         end
      end
      define_method("divideByUV") do |operand|
         if operand.is_a?(UV) then
            return UV.new(self, Vector[0r,0r,0r,0r,0r], self.to_s)/operand
         elsif operand.is_a?(Symbol) then
            return UV.new(self, Vector[0r,0r,0r,0r,0r], self.to_s)/operand.toUV()
         else
            return dummydivide(operand)
         end
      end
   end
   def toUV
      UV.new(self, Vector[0r,0r,0r,0r,0r], "1")
   end
   alias_method :dummymultiply, :*
   alias_method :*, :multiplyWithUV
   alias_method :dummydivide, :/
   alias_method :/, :divideByUV
end

class Fixnum
   ["dummy"].each do |opr|
      define_method("multiplyWithUV") do |operand|
         if operand.is_a?(UV) then
            return operand*self
         elsif operand.is_a?(Symbol) then
            return operand.toUV()*self
         else
            return dummymultiply(operand)
         end
      end
      define_method("divideByUV") do |operand|
         if operand.is_a?(UV) then
            return UV.new(self, Vector[0r,0r,0r,0r,0r], self.to_s)/operand
         elsif operand.is_a?(Symbol) then
            return UV.new(self, Vector[0r,0r,0r,0r,0r], self.to_s)/operand.toUV()
         else
            return dummydivide(operand)
         end
      end
   end
   def toUV
      UV.new(self, Vector[0r,0r,0r,0r,0r], "1")
   end
   alias_method :dummymultiply, :*
   alias_method :*, :multiplyWithUV
   alias_method :dummydivide, :/
   alias_method :/, :divideByUV
end


UV.DefineUserUnit :g, UV.new(1e-3, Vector[1r,0r,0r,0r,0r])
UV.DefineUserUnit :m, UV.new(1.00, Vector[0r,1r,0r,0r,0r])
UV.DefineUserUnit :s, UV.new(1.00, Vector[0r,0r,1r,0r,0r])
UV.DefineUserUnit :A, UV.new(1.00, Vector[0r,0r,0r,1r,0r])
UV.DefineUserUnit :K, UV.new(1.00, Vector[0r,0r,0r,0r,1r])
UV.setUnitBasis [:kg, :m, :s, :A, :K]

UV.DefineUserUnit :N,  :kg*:m/:s**2
UV.DefineUserUnit :J,  :N*:m
UV.DefineUserUnit :W,  :J/:s
UV.DefineUserUnit :eV, 1.60217657e-19*:J
UV.DefineUserUnit :erg,  1e-7*:J
UV.DefineUserUnit :min, 60.0*:s
UV.DefineUserUnit :hr, 60.0*:min
UV.DefineUserUnit :day, 24.0*:hr
UV.DefineUserUnit :yr, 365*:day
UV.DefineUserUnit :Hz,  (:s**-1)

   
module Physical
   module Constant
      G = 6.67384e-11*(:m**3/:kg/:s**2)
      LightSpeed = 299792458.0*(:m/:s)
      Msun = 1.988e+30*:kg
      ElectronMass = 9.11e-28*:g
      ClassicalElectronRadius = 2.8179403267e-15*:m
      StandardGraviry = 9.80665*(:m/:s**2)
   end
   module Formula
      def KleinNishina(energy,theta)
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
               raise "Physical:Formula:KleinNishina: theta has dimension"
            end
         else
            th = theta
         end
         
         cos = Math.cos(th)
         re = Physical::Constant::ClassicalElectronRadius
         p = 1.0/( 1.0 + e/511.0*(1.0-cos) )
         return 0.5*(re**2)*(p**2)*(p+1.0/p + cos**2 -1)
      end
      module_function :KleinNishina
   end
end

class UnitBasis
   @@test = UV.new(1)
end