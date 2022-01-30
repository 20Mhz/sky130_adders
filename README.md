Study on Adders

Build:
```
mkdir work
cd work
make -f ../scripts/Makefile ripple TOP_MODULE=carryRippleN_h; # Build Netlist
make -f ../scripts/Makefile sta NETLIST=ripple.vg TOP_MODULE=carryRippleN_h
```

STA - Slow corner (ss_100C_1v60)

```
Design,Arrival
carryRippleN_h,9.3145
carrySkip,8.2787
carryLookAhead,4.1217
```

