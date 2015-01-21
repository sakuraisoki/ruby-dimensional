# require "ruby-alge"

def rd_dimensionless_check(x, funcname)
    if x.is_a?(UV) then
        if x.nonDimensional? then
            return x.to_f
        else
            p x
            raise "ruby-dimentional-alge: %s should take dimensionless argument" % funcname.to_s
        end
    else
        return x
    end
end

Alge.DefineOperator(:sin){|x| Math.sin( rd_dimensionless_check(x, :sin) )}
Alge.DefineOperator(:asin){|x| Math.asin( rd_dimensionless_check(x, :asin) )}

Alge.DefineOperator(:cos){|x| Math.cos( rd_dimensionless_check(x, :cos) )}
Alge.DefineOperator(:acos){|x| Math.acos( rd_dimensionless_check(x, :acos) )}

Alge.DefineOperator(:exp){|x| Math.exp( rd_dimensionless_check(x, :exp) )}
Alge.DefineOperator(:ln){|x| Math.log( rd_dimensionless_check(x, :ln) )}

class UV
   ["dummy"].each do |opr|
       @@userDefinedMultiply[Alge] = lambda {|uv,alge| return Alge.new("*", [uv, alge])}           
       @@userDefinedDivide[Alge] = lambda {|uv,alge| return Alge.new("/", [uv, alge])}           
       @@userDefinedPlus[Alge] = lambda {|uv,alge| return Alge.new("+", [uv, alge])}           
       @@userDefinedMinus[Alge] = lambda {|uv,alge| return Alge.new("-", [uv, alge])}
       @@userDefinedPower[Alge] = lambda {|uv,alge| return Alge.new("**", [uv, alge])}
   end
end