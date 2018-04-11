Problem:    transport
Rows:       6
Columns:    6
Non-zeros:  18
Status:     OPTIMAL
Objective:  cost = 153.675 (MINimum)

   No.   Row name   St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 cost         B        153.675                             
     2 supply[Seattle]
                    B            300                         350 
     3 supply[San-Diego]
                    NU           600                         600         < eps
     4 demand[New-York]
                    NL           325           325                       0.225 
     5 demand[Chicago]
                    NL           300           300                       0.153 
     6 demand[Topeka]
                    NL           275           275                       0.126 

   No. Column name  St   Activity     Lower bound   Upper bound    Marginal
------ ------------ -- ------------- ------------- ------------- -------------
     1 x[Seattle,New-York]
                    B              0             0               
     2 x[Seattle,Chicago]
                    B            300             0               
     3 x[Seattle,Topeka]
                    NL             0             0                       0.036 
     4 x[San-Diego,New-York]
                    B            325             0               
     5 x[San-Diego,Chicago]
                    NL             0             0                       0.009 
     6 x[San-Diego,Topeka]
                    B            275             0               

Karush-Kuhn-Tucker optimality conditions:

KKT.PE: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.PB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

KKT.DE: max.abs.err = 2.78e-17 on column 1
        max.rel.err = 1.91e-17 on column 1
        High quality

KKT.DB: max.abs.err = 0.00e+00 on row 0
        max.rel.err = 0.00e+00 on row 0
        High quality

End of output
