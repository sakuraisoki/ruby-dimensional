class Alge
    @@Basicoperators = {
        "+" => lambda {|x,y| x+y},
        "-" => lambda {|x,y| x-y},
        "*" => lambda {|x,y| x*y},
        "/" => lambda {|x,y| x/y},
        "**" => lambda {|x,y| x**y},
        "+@" => lambda {|x| x},
        "-@" => lambda {|x| -x},
        "===" => lambda {|x,y| Alge.new("=",[x,y])},
    }
    @@BasicoperatorsInverse = {
        "+" => lambda {|x, y| Alge.new("-",[x,y])},
        "-" => lambda {|x, y| Alge.new("+",[x,y])},
        "*" => lambda {|x, y| Alge.new("/",[x,y])},
        "/" => lambda {|x, y| Alge.new("*",[x,y])},
        "**" => lambda {|x,y| Alge.new("**", [x,Alge.new("/",[1r,y])])},
        "+@" => lambda {|y| y},
        "-@" => lambda {|y| Alge.new("-@",y)},
        "===" => lambda {|y| y},
    }
    @@BasicoperatorsDifferential = {
        "+" => lambda {|x, y, z| Alge.new("+",[x.differential(z),y.differential(z)])},
        "-" => lambda {|x, y, z| Alge.new("-",[x.differential(z),y.differential(z)])},
        "*" => lambda {|x, y, z| Alge.new("+",[ x.differential(z)*y, x*y.differential(z)])},
        "/" => lambda {|x, y, z|
        if not y.includeVariable?(z) then
        return Alge.new("/",[ x.differential(z),y])
        else
        return Alge.new("/",[ x.differential(z)*y - x*y.differential(z), y*y])
        end
        },
        "**" => lambda {|x, y, z| (x**y)*(y.differential(z)*Alge.new(:ln, x) + y*x.differential(z)/x) },
        "+@" => lambda {|y,z| y.differential(z)},
        "-@" => lambda {|y, z| Alge.new("-@",y.differential(z))},
        "===" => lambda {|y| raise "'===' is not defined for  differentiation"},
    }
    @@operators = @@Basicoperators
    @@operatorsInverse = @@BasicoperatorsInverse
    @@operatorsDifferential = @@BasicoperatorsDifferential

    # def self.destructor
    #     lambda {puts "died"}
    # end

    def initialize(v=nil, childs=[])
        if v.is_a?(String) or v.is_a?(Symbol) then
            s = v.to_s
            if @@operators.include?(s) then
                @type = :Alge_Operation
                @value = s
                if childs.is_a?(Array) then
                    @children = childs.map{|v| v.is_a?(Alge)? v : Alge.new(v)}
                else
                    @children = [childs.is_a?(Alge)? childs : Alge.new(childs)]
                end
            else
                @type = :Alge_Variable
                @value = s
            end
        else
            @type = :Alge_Literal
            @value = v
        end
        # ObjectSpace.define_finalizer(self, self.class.destructor)
    end

    def child(index)
        return @children[index]
    end

    def Alge.DefineOperator(name, invopr=nil, diffopr=nil, &block)
        @@operators[name.to_s] = lambda(&block)
        if invopr then
            @@operatorsInverse[name.to_s] = invopr
        end
        if diffopr then
            @@operatorsDifferential[name.to_s] = diffopr
        end
    end
    @@Basicoperators.each do |name, opr|
        define_method(name){|x|
            Alge.new(name, [self,x].compact)
        }
    end

    def isSingleTerm?
        if @type==:Alge_Operation and ["+","-","-@"].include? @value then
            return false
        else
            return true
        end
    end

    def isSingle?
        return (@type==:Alge_Literal or @type==:Alge_Variable)
    end

    def value(substitute={})
        if @type==:Alge_Literal then
            return @value
        elsif @type==:Alge_Variable then
            if substitute.include?(@value) then
                return substitute[@value]
            elsif substitute.include?(@value.to_sym) then
                return substitute[@value.to_sym]
            else
                return self
            end
        elsif @type==:Alge_Operation then
            sol = @children.map{|v| v.value(substitute)}
            allSolved = true
            sol.each{|v| allSolved=(not v.is_a?(Alge))}
            if allSolved then
                return @@operators[@value].call(*sol)
            else
                return Alge.new(@value, sol)
            end
        end
    end

    def valueWithError(substitute={})
        vs = {}
        substitute.each{|n,v| vs[n] = v[0]}
        val = self.value(vs)
        error = nil
        substitute.each{|z, e|
            if error==nil then
                error = ( self.differential(z).value(vs) * e[1]  )**2
            else
                error = error + ( self.differential(z).value(vs) * e[1]  )**2
            end
        }
        error = (error**(1/2r))
        return [val, error]
    end

    def to_s
        if @type==:Alge_Literal then
            return @value.to_s
        elsif @type==:Alge_Variable then
            return @value.to_s
        elsif @type==:Alge_Operation then
            strs = @children.map{|v| v.to_s}
            if ["*","/"].include? @value then
                str = ""
                str += if @children[0].isSingleTerm? then strs[0] else "("+strs[0]+")" end
                str += @value
                str += if @children[1].isSingle? then strs[1] else "("+strs[1]+")" end
                return str
            elsif @value=="**" then
                str = ""
                str += if @children[0].isSingle? then strs[0] else "("+strs[0]+")" end
                str += @value
                str += if @children[1].isSingle? then strs[1] else "("+strs[1]+")" end
                return str
            elsif ["+","-"].include? @value then
                return strs[0]+@value+strs[1]
            elsif @value=="+@" then
                return strs[0]
            elsif @value=="-@" then
                return "-"+strs[0]
            else
                return @value+"("+strs[0]+")"
            end
        end
    end

    def includeVariable?(name)
        v = name.to_s
        if @type==:Alge_Literal then
            return false
        elsif @type==:Alge_Variable then
            return @value==v
        elsif @type==:Alge_Operation then
            return ((@children[0].includeVariable?(v)) or (@children[1]? @children[1].includeVariable?(v) : false))
        end
    end

    def is_literal?()
        return @type==:Alge_Literal
    end

    def is_variable?()
        return @type==:Alge_Variable
    end

    def is_operation?()
        return @type==:Alge_Operation
    end

    def switch
        if @type==:Alge_Operation then
            if @value=="*" then
                return Alge.new(:*, [@children[1],@children[0]])
            elsif @value=="/" then
                return Alge.new(:*, [Alge.new( "**", [ @children[1] , Alge.new(-1r) ] )  , @children[0] ] )
            elsif ["+","-"].include? @value then
                return Alge.new(@value, [@children[1],@children[0]])
            else
                return Alge.new(@value, [@children[1],@children[0]].compact)
            end
        else
            return self.clone
        end
    end

    def solve(var)
        v = var.to_s
        if @type==:Alge_Operation and @value=="===" then
            lhs = @children[0]
            rhs = @children[1]
            if lhs.includeVariable?(v) and rhs.includeVariable?(v) then
                raise "Alge: difficult to solve: "+"both hand side have "+v
            elsif (not lhs.includeVariable?(v)) and (not rhs.includeVariable?(v)) then
                raise "Alge: unable to solve: "+"neither hand side has "+v
            else
                if rhs.includeVariable?(v) then
                    buf = rhs
                    rhs = lhs
                    lhs = buf
                end
                while true
                    rest, operation, operand = lhs.solve(v)
                    if rest.class==String and rest==v then
                        break
                    else
                        if operand==nil then
                            rhs = operation.call(rhs)
                        else
                            rhs = operation.call(rhs,operand)
                        end
                    end
                    lhs = rest
                end
                return rhs
            end
        else
            if @type==:Alge_Literal then
                raise "Alge: unexpected error!"
            elsif @type==:Alge_Variable then
                return [@value, nil, nil]
            elsif @type==:Alge_Operation then
                if @children.length == 1 then
                    return [@children[0], @@operatorsInverse[@value], nil]
                elsif @children.length == 2 then
                    if @children[0].includeVariable?(v) and @children[1].includeVariable?(v) then
                        raise "Alge: difficult to solve:"+"multiple "+v
                    elsif (not @children[0].includeVariable?(v)) and (not @children[1].includeVariable?(v)) then
                        # return [self,nil,nil]
                        raise "Alge: unexpected error!"
                    else
                        if @children[1].includeVariable?(v) then
                            return self.switch.solve(v)
                        else
                            return [@children[0], @@operatorsInverse[@value], @children[1]]
                        end
                    end
                end
            end
        end
    end

    def reduce()
        return self.value()
    end

    def differential(z)
        v = z.to_s
        if @type==:Alge_Literal then
            return Alge.new("/",[Alge.new(0*@value),Alge.new(z)])
        elsif @type==:Alge_Variable then
            return (v==@value? (Alge.new(1)):(Alge.new(0)*Alge.new("/", [self, Alge.new(z)])))
        elsif @type==:Alge_Operation then
            if @@operatorsDifferential.include?(@value) then
                return @@operatorsDifferential[@value][*(@children+[z])]
            else
                raise "Alge: differentiation not defined for operation"+@value
            end
        end
    end
end


class Float
    @@userDefinedMultiply = {} if not class_variable_defined?(:@@userDefinedMultiply)
    @@userDefinedDivide = {} if not class_variable_defined?(:@@userDefinedDivide)
    @@userDefinedPlus = {} if not class_variable_defined?(:@@userDefinedPlus)
    @@userDefinedMinus = {} if not class_variable_defined?(:@@userDefinedMinus)
    ["dummy"].each do |opr|
        @@userDefinedMultiply[Alge] = lambda {|fn,alge| return Alge.new("*",[fn, alge])}
        if not method_defined?(:multiplyUser)
            alias_method :dummymultiply, :*
            define_method("multiplyUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummymultiply(operand)
                else
                    if @@userDefinedMultiply.include?(operand.class) then
                        return @@userDefinedMultiply[operand.class][self, operand]
                    else
                        raise "Float: * operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :*, :multiplyUser
        end

        @@userDefinedDivide[Alge] = lambda {|fn,alge| return Alge.new("/", [fn, alge])}
        if not method_defined?("divideUser") then
            alias_method :dummydivide, :/
            define_method("divideUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummydivide(operand)
                else
                    if @@userDefinedDivide.include?(operand.class) then
                        return @@userDefinedDivide[operand.class][self, operand]
                    else
                        raise "Float: / operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :/, :divideUser
        end
        
        @@userDefinedPlus[Alge] = lambda {|fn,alge| return Alge.new("+",[fn, alge])}
        if not method_defined?(:plusUser)
            alias_method :dummyplus, :+
            define_method("plusUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummyplus(operand)
                else
                    if @@userDefinedPlus.include?(operand.class) then
                        return @@userDefinedPlus[operand.class][self, operand]
                    else
                        raise "Float: + operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :+, :plusUser
        end

        @@userDefinedMinus[Alge] = lambda {|fn,alge| return Alge.new("-",[fn, alge])}
        if not method_defined?(:minusUser)
            alias_method :dummyminus, :-
            define_method("minusUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummyminus(operand)
                else
                    if @@userDefinedMinus.include?(operand.class) then
                        return @@userDefinedMinus[operand.class][self, operand]
                    else
                        raise "Float: - operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :-, :minusUser
        end
    end
    #   alias_method :dummymultiply, :*
    #   alias_method :*, :multiplyUser
    #   alias_method :dummydivide, :/
    #   alias_method :/, :divideUser
end


class Fixnum
    @@userDefinedMultiply = {} if not class_variable_defined?(:@@userDefinedMultiply)
    @@userDefinedDivide = {} if not class_variable_defined?(:@@userDefinedDivide)
    @@userDefinedPlus = {} if not class_variable_defined?(:@@userDefinedPlus)
    @@userDefinedMinus = {} if not class_variable_defined?(:@@userDefinedMinus)
    ["dummy"].each do |opr|
        @@userDefinedMultiply[Alge] = lambda {|fn,alge| return Alge.new("*",[fn, alge])}
        if not method_defined?(:multiplyUser)
            alias_method :dummymultiply, :*
            define_method("multiplyUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummymultiply(operand)
                else
                    if @@userDefinedMultiply.include?(operand.class) then
                        return @@userDefinedMultiply[operand.class][self, operand]
                    else
                        raise "Fixnum: * operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :*, :multiplyUser
        end

        @@userDefinedDivide[Alge] = lambda {|fn,alge| return Alge.new("/", [fn, alge])}
        if not method_defined?("divideUser") then
            alias_method :dummydivide, :/
            define_method("divideUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummydivide(operand)
                else
                    if @@userDefinedDivide.include?(operand.class) then
                        return @@userDefinedDivide[operand.class][self, operand]
                    else
                        raise "Fixnum: / operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :/, :divideUser
        end

        @@userDefinedPlus[Alge] = lambda {|fn,alge| return Alge.new("+",[fn, alge])}
        if not method_defined?(:plusUser)
            alias_method :dummyplus, :+
            define_method("plusUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummyplus(operand)
                else
                    if @@userDefinedPlus.include?(operand.class) then
                        return @@userDefinedPlus[operand.class][self, operand]
                    else
                        raise "Fixnum: + operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :+, :plusUser
        end
        
        @@userDefinedMinus[Alge] = lambda {|fn,alge| return Alge.new("-",[fn, alge])}
        if not method_defined?(:minusUser)
            alias_method :dummyminus, :-
            define_method("minusUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummyminus(operand)
                else
                    if @@userDefinedMinus.include?(operand.class) then
                        return @@userDefinedMinus[operand.class][self, operand]
                    else
                        raise "Fixnum: - operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :-, :minusUser
        end
    end
    #   alias_method :dummymultiply, :*
    #   alias_method :*, :multiplyUser
    #   alias_method :dummydivide, :/
    #   alias_method :/, :divideUser
end


class Rational
    @@userDefinedMultiply = {} if not class_variable_defined?(:@@userDefinedMultiply)
    @@userDefinedDivide = {} if not class_variable_defined?(:@@userDefinedDivide)
    @@userDefinedPlus = {} if not class_variable_defined?(:@@userDefinedPlus)
    @@userDefinedMinus = {} if not class_variable_defined?(:@@userDefinedMinus)
    ["dummy"].each do |opr|
        @@userDefinedMultiply[Alge] = lambda {|r,alge| return Alge.new("*",[r, alge])}
        if not method_defined?(:multiplyUser)
            alias_method :dummymultiply, :*
            define_method("multiplyUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummymultiply(operand)
                else
                    if @@userDefinedMultiply.include?(operand.class) then
                        return @@userDefinedMultiply[operand.class][self, operand]
                    else
                        raise "Rational: * operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :*, :multiplyUser
        end

        @@userDefinedDivide[Alge] = lambda {|r,alge| return Alge.new("/", [r, alge])}
        if not method_defined?("divideUser") then
            alias_method :dummydivide, :/
            define_method("divideUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummydivide(operand)
                else
                    if @@userDefinedDivide.include?(operand.class) then
                        return @@userDefinedDivide[operand.class][self, operand]
                    else
                        raise "Rational: / operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :/, :divideUser
        end

        @@userDefinedPlus[Alge] = lambda {|fn,alge| return Alge.new("+",[fn, alge])}
        if not method_defined?(:plusUser)
            alias_method :dummyplus, :+
            define_method("plusUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummyplus(operand)
                else
                    if @@userDefinedPlus.include?(operand.class) then
                        return @@userDefinedPlus[operand.class][self, operand]
                    else
                        raise "Rational: + operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :+, :plusUser
        end
        
        @@userDefinedMinus[Alge] = lambda {|fn,alge| return Alge.new("-",[fn, alge])}
        if not method_defined?(:minusUser)
            alias_method :dummyminus, :-
            define_method("minusUser") do |operand|
                if operand.is_a?(Numeric)
                    return dummyminus(operand)
                else
                    if @@userDefinedMinus.include?(operand.class) then
                        return @@userDefinedMinus[operand.class][self, operand]
                    else
                        raise "Rational: - operation not defined for "+operand.class.to_s
                    end
                end
            end
            alias_method :-, :minusUser
        end        
    end
end


# x = Alge.new(:x)
# y = Alge.new(:y)
# z = Alge.new(:z)
# ex = Alge.new(:ln,x/z)
# puts (ex*z/y + y===z).solve(:x)
