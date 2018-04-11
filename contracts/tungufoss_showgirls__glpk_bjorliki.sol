Problem:    bjorliki
Rows:       12
Columns:    4
Non-zeros:  22
Status:     OPTIMAL
Objective:  z = 209.8119205 (MINimum)

   No.   Row name   St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 hlutfall     NS             1             1             =       -13.245 
     2 lagmark[pilsner]
                    B       0.923046            -0               
     3 lagmark[vodka]
                    B      0.0269536            -0               
     4 lagmark[brandy]
                    NL          0.02          0.02                        1000 
     5 lagmark[malt]
                    NL          0.03          0.03                     57.7483 
     6 hamark[pilsner]
                    B       0.923046                           1 
     7 hamark[vodka]
                    B      0.0269536                        0.07 
     8 hamark[brandy]
                    B           0.02                           1 
     9 hamark[malt] B           0.03                        0.05 
    10 sterkt       B      0.0469536                         0.1 
    11 styrkur      NS          0.04          0.04             =       5033.11 
    12 z            B        209.812                             

   No. Column name  St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 x[pilsner]   B       0.923046             0               
     2 x[vodka]     B      0.0269536             0               
     3 x[brandy]    B           0.02             0               
     4 x[malt]      B           0.03             0               

Karush-Kuhn-Tucker optimality conditions:

KKT.PE: max.abs.err = 1.11e-16 on row 1
        max.rel.err = 3.70e-17 on row 1
        High quality

KKT.PB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.DE: max.abs.err = 1.42e-14 on column 1
        max.rel.err = 6.25e-17 on column 1
        High quality

KKT.DB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

End of output
