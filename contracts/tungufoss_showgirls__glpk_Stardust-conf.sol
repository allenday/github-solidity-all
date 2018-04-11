Problem:    assignment
Rows:       9
Columns:    16
Non-zeros:  44
Status:     OPTIMAL
Objective:  total_happiness = 41 (MAXimum)

   No.   Row name   St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 total_happiness
                    B             41                             
     2 women_constraint[Bit]
                    NS             1             1             =            21 
     3 women_constraint[Krona]
                    NS             1             1             =            20 
     4 women_constraint[Tann]
                    NS             1             1             =            24 
     5 women_constraint[Gervi]
                    NS             1             1             =            15 
     6 men_constraint[N]
                    NS             1             1             =            -9 
     7 men_constraint[O]
                    NS             1             1             =           -15 
     8 men_constraint[M]
                    B              1             1             = 
     9 men_constraint[I]
                    NS             1             1             =           -15 

   No. Column name  St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 x[Bit,N]     B              1             0               
     2 x[Bit,O]     NL             0             0                       -1006 
     3 x[Bit,M]     NL             0             0                          -6 
     4 x[Bit,I]     NL             0             0                       -1006 
     5 x[Krona,N]   B              0             0               
     6 x[Krona,O]   NL             0             0                          -2 
     7 x[Krona,M]   B              0             0               
     8 x[Krona,I]   B              1             0               
     9 x[Tann,N]    NL             0             0                          -8 
    10 x[Tann,O]    NL             0             0                          -2 
    11 x[Tann,M]    B              1             0               
    12 x[Tann,I]    NL             0             0                          -8 
    13 x[Gervi,N]   NL             0             0                          -6 
    14 x[Gervi,O]   B              1             0               
    15 x[Gervi,M]   NL             0             0                         -15 
    16 x[Gervi,I]   B              0             0               

Karush-Kuhn-Tucker optimality conditions:

KKT.PE: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.PB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.DE: max.abs.err = 0.00e+00 on column 0
        max.rel.err = 0.00e+00 on column 0
        High quality

KKT.DB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

End of output
