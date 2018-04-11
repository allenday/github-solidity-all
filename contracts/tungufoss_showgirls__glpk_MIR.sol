Problem:    assignment
Rows:       9
Columns:    16
Non-zeros:  48
Status:     OPTIMAL
Objective:  total_happiness = 30 (MAXimum)

   No.   Row name   St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 total_happiness
                    B             30                             
     2 women_constraint[Anastasiya]
                    NS             1             1             =             7 
     3 women_constraint[Borislava]
                    NS             1             1             =             8 
     4 women_constraint[Dunya]
                    NS             1             1             =             7 
     5 women_constraint[Elena]
                    NS             1             1             =             5 
     6 men_constraint[Fannar]
                    NS             1             1             =         < eps
     7 men_constraint[Gunnar]
                    B              1             1             = 
     8 men_constraint[Hilmar]
                    NS             1             1             =             1 
     9 men_constraint[Ingi]
                    NS             1             1             =             2 

   No. Column name  St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 x[Anastasiya,Fannar]
                    B              0             0               
     2 x[Anastasiya,Gunnar]
                    NL             0             0                          -2 
     3 x[Anastasiya,Hilmar]
                    B              1             0               
     4 x[Anastasiya,Ingi]
                    NL             0             0                          -7 
     5 x[Borislava,Fannar]
                    NL             0             0                          -1 
     6 x[Borislava,Gunnar]
                    B              1             0               
     7 x[Borislava,Hilmar]
                    B              0             0               
     8 x[Borislava,Ingi]
                    NL             0             0                          -6 
     9 x[Dunya,Fannar]
                    NL             0             0                          -4 
    10 x[Dunya,Gunnar]
                    NL             0             0                          -2 
    11 x[Dunya,Hilmar]
                    NL             0             0                          -1 
    12 x[Dunya,Ingi]
                    B              1             0               
    13 x[Elena,Fannar]
                    B              1             0               
    14 x[Elena,Gunnar]
                    NL             0             0                       < eps
    15 x[Elena,Hilmar]
                    NL             0             0                       < eps
    16 x[Elena,Ingi]
                    B              0             0               

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
