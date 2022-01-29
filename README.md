Study on Adders

Build:
```
mkdir work
cd work
make -f ../scripts/Makefile ripple TOP_MODULE=carryRippleN_h; # Build Netlist
make -f ../scripts/Makefile sta NETLIST=ripple.vg TOP_MODULE=carryRippleN_h
```

STA - Slow corner

```
work/carrySkip.vg.sta:                                 8.2787   data arrival time
work/ripple.vg.sta:                                 9.3145   data arrival time
```
