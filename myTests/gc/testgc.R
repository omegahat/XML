dyn.load("testgc.so")
x1 = .Call("R_getA")
x2 = .Call("R_getA")

.Call("R_getACount")
