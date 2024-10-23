# Biological and Non-Biological Movement Perception Experiment

This repository contains the MATLAB code for an experiment that involves distinguishing between biological and non-biological movements. Participants will identify whether movements are directed towards or away from them.

## Set-Up Instructions

1. **Install Psychtoolbox in MATLAB**:  
   Psychtoolbox is required for running this experiment. You can install it by following the [official installation guide here](http://psychtoolbox.org/download).
   
2. **Download Movement Videos**:  
   The videos for both non-biological and biological movements can be downloaded from the following Google Drive link:  
   [Download Movement Videos](https://drive.google.com/drive/folders/1EN1D8gGAtNeg5u9Luz-Piw5ZrrWeEHa7)

## Running the Experiment

### Part 1: Biological Movement Identification

1. Run the `main_biological.m` script in MATLAB. 
2. You will be presented with a visual of a biological walker. Your task is to identify the direction of movement:
   - Press the **up-arrow key** if the walker is moving **away from you** (backward).
   - Press the **down-arrow key** if the walker is moving **toward you** (forward).
3. After completing this part, take a **10-minute break** before proceeding to the next phase.

### Part 2: Non-Biological Movement Identification

1. Run the `main_nonbiological.m` script.  
2. You will see dots forming a circular shape. Your task is to determine if the majority of the dots are:
   - Press the **up-arrow key** if the dots are moving **away from you** (backward).
   - Press the **down-arrow key** if the dots are moving **toward you** (forward).

### Part 3: Data Analysis

1. After completing both phases, you can analyze your results using the `analyze.m` script. This script will generate the corresponding plots based on your performance.
2. You should set the `number_of_subject` variable equal to the number you entered at the first of running main files.
3. The `Data` folder contains the results of **8 subjects** that you can use for further analysis or comparison.

## Additional Notes

- For best results, run the experiment in a **dark room** to minimize visual distractions.
- Ensure you take a break(10 minutes) between phases to avoid fatigue affecting the results.
- Enter a similar number/name at the beginning of both phases.

### Requirements
- MATLAB with Psychtoolbox installed.
