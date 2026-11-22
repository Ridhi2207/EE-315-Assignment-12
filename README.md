# EE-315-Assignment-12
EE315 Project / Assignment 12 — MATLAB Simulation
Group 04 | Group Leader: Ridhi Shakkar (240002069)

HOW TO RUN
1. Open MATLAB R2016b or newer.
2. Set Current Folder to the folder containing assignment12_fault_classification.m.
3. In Command Window enter: assignment12_fault_classification
4. Inspect the console summary and 3 figures.
5. Outputs saved in the same folder:
   matlab_fault_currents.png
   matlab_fault_voltages.png
   matlab_confusion_matrix.png
   matlab_predictions.csv
   matlab_results.mat

11 CLASSES
Normal, AG, BG, CG, AB, BC, CA, ABG, BCG, CAG, ABC.
G denotes ground. ABC represents a balanced three-phase fault.

MODEL SCOPE
This is a self-contained, simplified synthetic phasor waveform simulation.
It demonstrates the classification logic using simulated voltage/current signals
with randomized fault magnitudes and white measurement noise. It is NOT a
Simulink physical network model, and does not account for source impedance,
sequence networks, arc resistance, DC offsets or breaker behavior.

METHOD
Estimate pre/post fundamental current phasors; compute their differences;
count fault-active phases; distinguish grounded vs ungrounded two-phase faults
using residual (zero-sequence) current. Plot a confusion matrix.

The classifier is threshold based; no machine-learning toolbox is required.
Simulation accuracy reflects performance on this synthetic generator only.
