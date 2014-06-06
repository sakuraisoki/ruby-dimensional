require "ruby-dimensional"

#length
UV.DefineUserUnit :Angstrom,  1e-10*:m
UV.DefineUserUnit :Angstroem,  :Angstrom
UV.DefineUserUnit :Ang, :Angstrom
UV.DefineUserUnit :parsec,  3.08567758e16*:m 
UV.DefineUserUnit :pc,  3.08567758e16*:m #parsec
UV.DefineUserUnit :AU,  149597871*:km
UV.DefineUserUnit :in,  25.4*:mm
UV.DefineUserUnit :inch,  :in
UV.DefineUserUnit :yd,  0.9144*:m
UV.DefineUserUnit :yard,  :yd
UV.DefineUserUnit :shaku,  10.0/33.0*:m
UV.DefineUserUnit :sun,  0.1*:shaku

#time
UV.DefineUserUnit :Hz,  (:s**-1)

#energy
UV.DefineUserUnit :eV, 1.60217657e-19*:J
UV.DefineUserUnit :erg,  1e-7*:J

#EM
UV.DefineUserUnit :C,   :A*:s
UV.DefineUserUnit :e,   1.60217657e-19*:C
UV.DefineUserUnit :V,   :J/:C
UV.DefineUserUnit :Ohm, :V/:A
UV.DefineUserUnit :F,   :C/:V
UV.DefineUserUnit :Wb,  :V/:s
UV.DefineUserUnit :T,   :Wb/(:m**2)
UV.DefineUserUnit :G,   1e-4*:T
UV.DefineUserUnit :H,   :Wb/:A
