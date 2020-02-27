# CHARC (and more!)

This repository initially began as place for MATLAB source code for the CHAracterisation of Reservoir Computers (CHARC) framework. However, it has now grown into a larger ecosystem with some basic standardisation to allow quick and easy intergation of ideas and methods.

The CHARC framework, which is still central, can be applied to lots of computing "substrates", from digital dynamical systems to physical material substrates. Using the basic statndardised function structure for CHARC, it is now simple to write your own substrate functions and apply them directly to CHARC and other scripts, such as MAP-elites, the microbial GA (evolve directly to a task), etc.

Thanks to this new update, it is now easier than before to add new tasks, behaviour measures, optimisation methods, etc., making it a useful playground for experimentation and research.

For more details on how to use the general ecosystem, go to the [Wiki](https://github.com/MaterialMan/CHARC/wiki) for some basic tutorials. *After the recent update some variables in the tutorials may have changed names.

***Disclaimer: Some reservoirs are still in the exploratory phase and may still be under development. For example, parameters and input-output mechanisms are currently lines of research, therefore feel free to play with/change/improve any implementations.

### What's in this repository:

## Reservoirs to test:
- Echo State Networks (ESN)
- Reservoir of Reservoirs (RoR): multi-reservoir architectures
- "Deep"/pipeline ESNs/reservoirs (DeepESN)
- Ensemble of ESNs/reservoirs
- Extreme Learning Machines - including multi-layer (ELM)
- Graph-structured reservoirs (including some ensembles)
- Belousov–Zhabotinsky (BZ) reaction reservoir
- DNA (network of coupled deoxyribozyme oscillators) reservoir
- Boolean network reservoir 
- Cellular Automata (implemented with RBN) both 1- and 2-dimensional
- Delay-line Reservoir (single non-linear node with delay line)
- Wave-based reservoir(e.g. bucket of water)
- Carbon nanotube-based reservoir (in materio)

.... future additions potentially in the pipeline:
- Magnetic films
- Liquid State Machine (Spiking Networks)
- Ising model 
- Nuclear Magnetic Resonance (NMR) reservoir

## All reservoirs work with:
- CHARC Framework
- Evolving reservoir directly to a task
- Multi-objective(task) evolution using NSGA-II
- MAP-elites

## Tasks added recently (check selectDataset.m):
- Pole balancing: inverted pendulum, doube-pole inverted pendulum, swinging pendulum
- N-bit adders
- Basic robot simualtion
- Autoencoder
- New tasks can be added via switch statement in "selectDataset.m"

## Plots
- behaviourGUI: can be used to visualise parameter-behaviour relationships and structure (in some cases)

## Metrics
- Added a simple metric for Entropy (needs refining) 
- New metrics can be added to "getMetrics.m" switch statement and included in CHARC via "config.metrics = {'KR','GR','MC','Entropy',...};

## Database methods
- Added particle swarm optimisation (PSO) to search within the database for specific tasks (including multi-task). Instead of evaluating the whole database for a task, you can simply find the best performing reservoir in the database for a task via PSO. This results in far fewer evaluations than evaluating the whole database.

