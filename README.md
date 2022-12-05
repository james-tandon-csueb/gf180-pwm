# GF180 PWM/Wishbone core #

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

A basic pulse with modulation core with 8 PWMs controled by a wishbone bus slave interface. The PWMs are 8-bit programmable
with full range of duty cycle control. All PWMS run synchronized to a single counter.

## Detailed documentation ##

A simple pulse width modulator connected to a wishbone
bus. Given an input clock signal, it is capable of dividing
the signal by 2^n where 0 <= n < 24. This allows a 100MHz core
fequency to be stepped down to just under 6 Hz if need be. The
frequency of each PWM is individually controlled by the
*Divider* registers which store the value n\_i for PWM i. The
 *Threshold* register sets the duty cycle for each PWM such
 that its value v\_i has duty cycle (256-v\_i)/256 and valid
 v\_i values are 0 < v\_i <= 255. Note that v\_i=0 turns off
 PWM i.

### Wishbone base address: 0xFEED0000 ###

### Registers: ###
* 0000 Threshold 0
* 0001 Threshold 1
* 0002 Threshold 2
* 0003 Threshold 3
* 0004 Threshold 4
* 0005 Threshold 5
* 0006 Threshold 6
* 0007 Threshold 7
* 0008 Divider 0
* 0009 Divider 1
* 000a Divider 2
* 000b Divider 3
* 000c Divider 4
* 000d Divider 5
* 000e Divider 6
* 000f Divider 7

