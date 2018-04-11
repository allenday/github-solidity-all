Creator "igraph version 0.7.1 StreamixC"
Version 1
graph
[
  directed 1
  node
  [
    id 0
    label "Logger"
    func "f_log"
    static 0
    pure 0
  ]
  node
  [
    id 1
    label "ComFront"
    func "f_com"
    static 0
    pure 0
  ]
  node
  [
    id 2
    label "smx_cp"
    func "smx_cp"
    static 0
    pure 0
  ]
  node
  [
    id 3
    label "ComRear"
    func "f_com"
    static 0
    pure 0
  ]
  node
  [
    id 4
    label "RevolutionSensor"
    func "f_rs"
    static 0
    pure 0
  ]
  node
  [
    id 5
    label "Break"
    func "fb"
    static 0
    pure 0
  ]
  node
  [
    id 6
    label "ManualBreak"
    func "f_mb"
    static 0
    pure 0
  ]
  node
  [
    id 7
    label "ABS"
    func "f_abs"
    static 0
    pure 0
  ]
  node
  [
    id 8
    label "CarPlatooning"
    func "f_cpa"
    static 0
    pure 0
  ]
  node
  [
    id 9
    label "DistanceControl"
    func "f_dc"
    static 0
    pure 0
  ]
  node
  [
    id 10
    label "DistanceSensor"
    func "f_ds"
    static 0
    pure 0
  ]
  node
  [
    id 11
    label "smx_cp"
    func "smx_cp"
    static 0
    pure 0
  ]
  edge
  [
    source 1
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 3
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 2
    target 0
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 5
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 4
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 6
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 6
    target 7
    label "break_cmd"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 4
    target 7
    label "speed"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 7
    target 5
    label "break_abs"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 7
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 8
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 9
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 10
    target 11
    label "dist"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 11
    target 9
    label "dist_dc"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 10
    target 2
    label "log"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 1
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 9
    target 7
    label "dc_abs"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 9
    target 8
    label "dc_cpa"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 11
    target 8
    label "dist_cpa"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 7
    target 9
    label "abs"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 8
    target 9
    label "cpa"
    nsrc "smx_null"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 3
    target 8
    label "com_rear_rcv"
    nsrc "com_rcv"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 8
    target 3
    label "com_rear_send"
    nsrc "smx_null"
    ndst "com_send"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 1
    target 8
    label "com_front_rcv"
    nsrc "com_rcv"
    ndst "smx_null"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
  edge
  [
    source 8
    target 1
    label "com_front_send"
    nsrc "smx_null"
    ndst "com_send"
    dsrc 0
    ddst 0
    len 1
    dts 0
    dtns 0
    sts 0
    stns 0
    type 0
  ]
]
