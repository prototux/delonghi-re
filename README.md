# DeLonghi's automatic espresso machine reverse engineering

## Intro

This project is an effort to reverse engineer the DeLonghi's automatic espresso machines to ideally make a open hardware and open source controller board that enable easy modding and experimentation using the coffee machines.

## Why?

Because there shall be no device at home that isn't reverse engineered, that's why. Also, implementing HTCPCP and fucking-coffee.sh is fun.

## What machines?

Currently, most of the work is done on the `ECAM 23.266` and it's sibling, the `ECAM 23.450` machine (aka. Magnifica Capuccino Smart or something).
There's also some work done on the widely available `ECAM 22.110`, but it's possibilities seems limited compared to the `23.266`.


## The goal?

It could be fun to add a (or even replace the front panel with) wifi/bluetooth enabled MCU to send statistics to a time-series server (eg. display it with Grafana) and enable remote control of the machine. Ideally, it would also enable custom recipes or backporting artificially segmented recipes (from the `ECAM 26.455 "PrimaDonna S De Luxe"`)

## Current status

* Got some schematics and firmwares to analyze, the `ECAM 23.226` seems to use UART
* Still need to make a little isolation board to MITM the serial connection (because the link is using negative voltages (!!) to the main power board)
* Working on reverse engineering the Display Board firmware

## Generalities

* DeLonghi seems to reuse a lot (and i mean A LOT) it's components, to the point where most of the machines are purely artificial market segmentation (there's even machines with the milk system that doesn't have a way to simply dispense milk!). The mechanics seems largely similar across their models, and the electronics seems to be shared pretty much all over the place.
* They use a power board + display/ui board, with a single 8 wire link between them (!THEY DON'T CARRY THE SAME THING ACROSS ALL MODELS!)
* They seems to use different models ("generations"?) or power board shared across models, most of them with a PIC18F on it, with two that seems the most common (found on the `ECAM 22.110` and `ECAM 23.450` models)
* They also seems to use different display/ui board, also shared across models, with different boards seemingly here to adapt to the shape of the machines. Some of the boards are "multiple use" (only one PCB can create different models depending on what components are implemented)
* They seems to use 2 differents names in a very confusing way, as their "marketing name" doesn't mean much (Magnifica, Maetosa, Dinamica, PrimaDonna, Eletta) as the same name reference many products, with even no clear segmentation between low/mid/high end models (some Magnifica models are more expensive or feature-complete than some Dinamica or even PrimaDonna models)
* * The "technical" naming scheme isn't much clearer either, they use `ECAM`, `FEB`, `EPAM`, `ESAM`... and many other names, often with no clear difference between two machines that are mostly the same (like `ECAM 350.75` vs `FEB 3535` which are both the same dinamica machine, only one doesn't have the milk container included, every other item on the spec sheet is the same, except a $300 price difference)
* * The only part that's logical and understood is that the final letters (eg. `.T`, `.S`, `.B` and the like) are for the colors (`B` for Black, `W` for White, `T` for Titanium, `G` for Grey, `S` for Silver, `MB` for Metal Black, `GB` for Grey Black... don't be fooled though, they're all just painted plastic. For some reason, the non-black models seems to be more expensive)
* Some models seems widely used/available (`ECAM 22.110`, `ECAM 23.450`, `ECAM 26.455`), while some models seems on the contrary very rare (`ECAM 23.217`, `ECAM 23.226`). The latter seems to be derivative of the former (often with one or two additional options, such as the milk container)

## Assumptions

* Given the components sharing practice, there's a high chance that most of the segmentation is done through software, and some clues seem to indicate only superficial switches to enable or disable features (identical PCBs with the same components and the same software version still have different hardware reference because they're fitted in different models)
* With some models being ridiculously similar (the differences between an `ECAM 23.260` and `ECAM 23.450` are two white LEDs that illuminate the coffee being made, a buzzer, and replacing the LEDs with a 16x2 LCD along with an eeprom (to store the strings and some parameters such as the language), it's pretty sure that it's possible to backport recipes from a model to another
* It's highly possible that the UART connection carries "simple" orders such as "heat up the water", "pump the water" and the like, thus enabling custom recipes if one manage to inject custom commands on the UART link
* It should be possible ot make a open hardware and open source controller board, and a open power board doesn't seems far fetched either (but isn't the main focus now), that could enable easy tweaking and modding of these coffee machines.

## Contributions welcome

Currently, we're a small team of friends working on these machine for our own fun, but contributions are welcome! Feel free to open an issue/pull request to add informations or files to this repository, or simply to ask questions about the project and it's current status.

## Thanks

* All the contributors from the https://saeco-support-forum.de's forum, who provided a lot of files to work with
* * Especially WolleP for his amazing PCB reverse engineering work and providing the schematics of some machines
* * Also Ano and bikermaex who organized sharing the firmware files that enabled a lot of the reverse engineering work
