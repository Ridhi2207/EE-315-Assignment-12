# EE315 – Power Systems
## Project / Assignment 12
### Fault Classification in Power Networks Using MATLAB Simulation

**Group:** 04  

---

## 1. Project Overview

This project presents a MATLAB-based fault classification technique for three-phase power networks. The objective is to identify different types of electrical faults by analyzing changes in three-phase voltage and current signals.

A rule-based classification algorithm is developed using fundamental current phasors, current variations, and residual current analysis. The technique is verified using synthetically generated fault conditions with randomized fault magnitudes and measurement noise.

The implementation is self-contained and does not require Simulink or additional MATLAB toolboxes.

## 2. Faults Considered

The simulation identifies **11 operating conditions**, comprising one healthy condition and ten fault categories.

| Fault | Description |
|---|---|
| Normal | Healthy three-phase operation |
| AG, BG, CG | Single line-to-ground faults |
| AB, BC, CA | Line-to-line faults |
| ABG, BCG, CAG | Double line-to-ground faults |
| ABC | Balanced three-phase fault |

Here, A, B, and C represent the three phases, while G denotes ground.

## 3. Simulation Methodology

The classification technique follows five main stages:

**Stage 1 – Signal Generation**

Three-phase sinusoidal voltage and current waveforms are generated under normal operating conditions. Faults are introduced at a predefined instant by modifying the voltage and current amplitudes of the affected phases.

**Stage 2 – Fault Simulation**

Different fault scenarios are produced by varying fault magnitudes and introducing white measurement noise. This provides multiple simulated cases for evaluating the classification technique.

**Stage 3 – Fundamental Phasor Estimation**

Fundamental current phasors are estimated before and after fault occurrence. The changes in these phasors are calculated as:

\[
\Delta I_k=I_{k,\mathrm{post}}-I_{k,\mathrm{pre}}
\]

where \(k\in\{a,b,c\}\).

**Stage 4 – Fault Identification**

The algorithm compares current variations against predefined thresholds to identify the affected phases.

For faults involving two phases, residual current is used to distinguish line-to-line faults from double line-to-ground faults:

\[
I_{\mathrm{res}}=I_a+I_b+I_c=3I_0
\]

A significant residual current indicates a possible ground connection.

**Stage 5 – Classification and Evaluation**

Each simulated operating condition is assigned a predicted fault category. Predictions are compared against the actual labels to calculate classification accuracy and generate a confusion matrix.

## 4. How to Run the MATLAB Simulation

1. Open **MATLAB R2016b or newer**.
2. Extract the project files into a folder.
3. Set the MATLAB Current Folder to the directory containing `assignment12_fault_classification.m`.
4. Execute the following command:

   `assignment12_fault_classification`

5. Examine the classification summary displayed in the Command Window.
6. Inspect the generated current waveform, voltage waveform, and confusion matrix.

The program saves the following output files automatically:

| File | Description |
|---|---|
| `matlab_fault_currents.png` | Three-phase current waveforms during an ABG fault |
| `matlab_fault_voltages.png` | Three-phase voltage waveforms during an ABG fault |
| `matlab_confusion_matrix.png` | Classification confusion matrix |
| `matlab_predictions.csv` | Actual and predicted fault categories |
| `matlab_results.mat` | MATLAB simulation results |

## 5. Simulation Results

The classification algorithm was evaluated using **880 synthetic test cases**, with 80 cases generated for each operating condition.

| Performance Metric | Result |
|---|---|
| Total operating classes | 11 |
| Cases per class | 80 |
| Total simulated cases | 880 |
| Correct classifications | 880 |
| Overall classification accuracy | 100% |
| Recall for each class | 100% |

The ABG fault waveforms demonstrate increased currents in phases A and B, accompanied by significant voltage reductions in the corresponding phases. Phase C remains comparatively unaffected.

The confusion matrix shows that all 80 samples in each class were correctly identified, with no observed misclassifications.

The classification accuracy is calculated using:

\[
\text{Accuracy}=\frac{\text{Correct Predictions}}{\text{Total Predictions}}\times100
\]

\[
=\frac{880}{880}\times100=\boxed{100\%}
\]

These results demonstrate that the proposed threshold-based classification technique successfully identifies all modeled fault conditions within the selected synthetic simulation environment.

## 6. Model Scope and Limitations

The simulation uses a simplified synthetic waveform model rather than a detailed physical power network.

It does not explicitly model transmission-line impedances, source impedance, sequence-network dynamics, fault arc resistance, DC offsets, protection relay operation, or circuit-breaker behavior.

Furthermore, both the simulated data and classification rules are based on predefined fault characteristics. Consequently, the observed 100% accuracy should not be interpreted as guaranteed performance under real-world operating conditions.

Further validation using detailed Simulink/Simscape Electrical models or actual power-system measurements would be necessary to evaluate practical applicability.

## 7. Conclusion

A MATLAB-based fault classification technique was successfully implemented and tested using simulated three-phase voltage and current signals.

The proposed method uses fundamental current phasor variations and residual current analysis to distinguish between healthy operation, single line-to-ground, line-to-line, double line-to-ground, and three-phase faults.

The simulation achieved **100% classification accuracy across 880 synthetic test cases** covering all 11 operating conditions.

The project demonstrates the fundamental principles of automatic fault identification and provides a foundation for developing more advanced power-system protection and monitoring algorithms.
