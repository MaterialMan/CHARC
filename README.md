# CHARC
MATLAB source code for the CHAracterisation of Reservoir Computers (CHARC) framework.

See wiki for detailed more information and Tutorials.

## Reservoirs to test
- Echo State Networks
- Reservoir of Reservoirs (RoR) architecture
- "Deep"/pipeline reservoirs
- Ensemble of reservoirs
- Extreme Learning Machines (including multi-layer)
- Graph-based reservoirs (including some ensembles)
- Belousov–Zhabotinsky (BZ) reaction reservoir
- DNA (network of coupled deoxyribozyme oscillators) reservoir
- Boolean network reservoir 
- Cellular Automata (implemented with RBN) both 1- and 2-dimensional
- Delay-line Reservoir (single non-linear node with delay line)

....coming soon
* Liquid State Machine (Spiking Networks)
* Wave-based (e.g. bucket of water)
* Memristor Network
* Ising model 
* Nuclear Magnetic Resonance (NMR) reservoir

### All reservoirs work with:
- CHARC Framework
- Evolve reservoir directly to task
- Multi-objective(task) evolution using NSGA-II
- MAP-elites

## Tasks added recently (check out selectDataset.m):
- Pole balancing: inverted pendulum, doube-pole inverted pendulum, swinging pendulum
- Autoencoder
- N-bit adders
- Evolved output layer
- New tasks can be added via switch statement in "selectDataset.m"

## Plots
- behaviourGUI: to visualise parameter-behaviour relationship and structure (in some cases)

## Metrics
- Added a simple metric for Entropy (may need refining) 
- New metrics can be added to "getVirtualMetrics.m" switch statement and included in CHARC via "config.metrics = {'KR','GR','MC','Entropy',...};

## Database methods
- Added particle swarm optimisation (PSO) to search within the database for specific tasks (including multi-task). Instead of evaluating the whole database for a task, you can simply find the best performing reservoir in the database for a task via PSO. This results in far fewer evaluations than evaluating the whole database.

