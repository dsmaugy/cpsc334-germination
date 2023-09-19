# cpsc334-module-revised
This repository contains the final production code for Module 1 of CPSC334 taken in the Fall of 2023.
Due to technical issues, Tasks 1&2 of module 1 had to be modified. This repository contains the work done for the revised module.

This repository is also added as a submodule of my parent [CPSC334 repo](https://github.com/dsmaugy/cpsc334).

## Generative Art Piece: _Germination_
_Germination_ is a generative art piece created in the Processing framework. 
<p align="center">
    <img src="resources/final_demo_gif.gif">
</p>

Inspired by the growth pattern of [slime mold networks](https://www.wired.com/2010/01/slime-mold-grows-network-just-like-tokyo-rail-system/), _Germination_ uses Perlin noise and a modified breadth-first-search algorithm to visualize the lifecycle of networks of points that grow and die in a constantly changing noise field.

## Installation
_Germination_ can be run on any device that has a monitor output and supports the [Processing](https://processing.org/) framework. When the Processing sketch, `germination.pde`, is run, the art piece appears in fullscreen on whatever is the default display of the host device. Pressing the `Esc` key should exit the program and full screen mode. 

### Running on the Raspberry Pi
To facilitate installation and running on an embedded system, a `germination.desktop` file was created 