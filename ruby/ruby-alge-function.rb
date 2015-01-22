# require "ruby-alge"

Alge.DefineOperator(:sin, lambda {|y| Alge.new(:asin, y)}, lambda{|x,z| x.differential(z)*Alge.new(:cos, x)} ){|x| Math.sin(x)}
Alge.DefineOperator(:asin, lambda {|y| Alge.new(:sin, y)}, lambda{|x,z| x.differential(z)/Alge.new(:cos, Alge.new(:sin, x))} ){|x| Math.asin(x)}

Alge.DefineOperator(:cos, lambda {|y| Alge.new(:acos, y)}, lambda{|x,z| -x.differential(z)*Alge.new(:sin, x)} ){|x| Math.cos(x)}
Alge.DefineOperator(:acos, lambda {|y| Alge.new(:cos, y)}, lambda{|x,z| -x.differential(z)/Alge.new(:sin, Alge.new(:cos, x))} ){|x| Math.acos(x)}

Alge.DefineOperator(:exp, lambda {|y| Alge.new(:ln, y)}, lambda{|x,z| x.differential(z)*Alge.new(:exp, x) } ){|x| Math.exp(x)}
Alge.DefineOperator(:ln, lambda {|y| Alge.new(:exp, y)}, lambda{|x,z| x.differential(z)/x} ){|x| Math.log(x)}

Alge.DefineOperator(:inv, lambda {|y| Alge.new(:inv, y)}, lambda{|x,z| x.differential(z)/(x*x) } ){|x| 1.0/x}
