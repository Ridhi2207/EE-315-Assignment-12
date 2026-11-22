%% EE315 Assignment 12: Power-Network Fault Classification

% Self-contained MATLAB script (R2016b or later; no toolboxes required).
% Synthetic fundamental-frequency three-phase phasor model, not an EMT
% or physical transmission-line simulation. All results are simulated.
clear; clc; close all;
rng(12,'twister');

fs = 5000;             % samples per second
f0 = 50;               % grid frequency (Hz)
t = (0:1/fs:0.20-1/fs).';
tFault = 0.08;         % fault inception time, seconds
classes = {'Normal','AG','BG','CG','AB','BC','CA','ABG','BCG','CAG','ABC'};
NperClass = 80;        % 80 randomized waveforms per fault class
Nclass = numel(classes);
actual = zeros(NperClass*Nclass,1);
predicted = zeros(NperClass*Nclass,1);
features = zeros(NperClass*Nclass,4); % |dIa|, |dIb|, |dIc|, residual ratio
exampleT = t; exampleI = []; exampleV = [];

k = 0;
for c = 1:Nclass
    for trial = 1:NperClass
        k = k + 1;
        % Vary fault strength and sensor noise to create diverse test cases.
        strength = 0.80 + 0.40*rand();
        noiseStd = 0.015 + 0.020*rand();
        [V,I] = synthesizeCase(t,fs,f0,tFault,c,strength,noiseStd);
        [code,feat] = detectAndClassify(t,I,fs,f0,tFault);
        actual(k) = c; predicted(k) = code; features(k,:) = feat;
        if c == 8 && trial == 1
            exampleI = I; exampleV = V;
        end
    end
end

cm = accumarray([actual predicted],1,[Nclass Nclass]);
accuracy = 100*mean(actual == predicted);
fprintf('EE315 Assignment 12 | MATLAB Fault Classifier\n');
fprintf('Total synthetic cases: %d\n',numel(actual));
fprintf('Classification accuracy: %.2f%%\n\n',accuracy);
fprintf('%-8s %8s %8s %8s\n','Class','Cases','Correct','Recall%');
for c = 1:Nclass
    count = sum(actual==c); right = cm(c,c);
    fprintf('%-8s %8d %8d %8.2f\n',classes{c},count,right,100*right/count);
end

% Plot 1: three-phase current signals for an ABG fault.
figure('Color','w','Name','Three-phase fault waveforms');
plot(exampleT,exampleI(:,1),'LineWidth',1.05); hold on;
plot(exampleT,exampleI(:,2),'LineWidth',1.05);
plot(exampleT,exampleI(:,3),'LineWidth',1.05);
line([tFault tFault],ylim,'Color',[0 0 0],'LineStyle','--');
xlabel('Time (s)'); ylabel('Current (pu)');
title('Simulated ABG fault: three-phase currents');
legend('I_a','I_b','I_c','Fault starts','Location','best'); grid on;
saveas(gcf,'matlab_fault_currents.png');

% Plot 2: three-phase voltages for same ABG fault.
figure('Color','w','Name','Three-phase voltages');
plot(exampleT,exampleV(:,1),'LineWidth',1.05); hold on;
plot(exampleT,exampleV(:,2),'LineWidth',1.05);
plot(exampleT,exampleV(:,3),'LineWidth',1.05);
line([tFault tFault],ylim,'Color',[0 0 0],'LineStyle','--');
xlabel('Time (s)'); ylabel('Voltage (pu)');
title('Simulated ABG fault: three-phase voltages');
legend('V_a','V_b','V_c','Fault starts','Location','best'); grid on;
saveas(gcf,'matlab_fault_voltages.png');

% Plot 3: confusion matrix (rows actual; columns predicted).
figure('Color','w','Name','Fault confusion matrix');
imagesc(cm); axis square; colormap(parula); colorbar;
set(gca,'XTick',1:Nclass,'XTickLabel',classes,...
        'YTick',1:Nclass,'YTickLabel',classes);
xtickangle(45); xlabel('Predicted class'); ylabel('Actual class');
title(sprintf('Synthetic-data confusion matrix | Accuracy %.2f%%',accuracy));
for r = 1:Nclass
    for q = 1:Nclass
        text(q,r,num2str(cm(r,q)),'HorizontalAlignment','center',...
            'Color', 'k','FontSize',8);
    end
end
saveas(gcf,'matlab_confusion_matrix.png');

% Save numerical results for reproducibility and inclusion in the report.
results = [(1:numel(actual)).' actual predicted features];
csvwrite('matlab_predictions.csv',results);
save('matlab_results.mat','cm','accuracy','actual','predicted',...
     'features','classes','fs','f0','tFault');
fprintf('\nSaved PNG plots, matlab_predictions.csv and matlab_results.mat.\n');
fprintf('NOTE: Synthetic phasor-injection demonstration, not a validated grid model.\n');

%% Local functions
function [V,I] = synthesizeCase(t,fs,f0,tFault,idx,s,noiseStd)
% Balanced pre-fault RMS phasors. Fault injections start at tFault.
baseI = exp(1i*[0 -2*pi/3 2*pi/3]);
baseV = exp(1i*[0 -2*pi/3 2*pi/3]);
inj = zeros(1,3);
voltageScale = ones(1,3);
F = 5*s;
G = 3*s;
switch idx
    case 1 % Normal
    case 2, inj(1)=F; voltageScale(1)=0.30;       % AG
    case 3, inj(2)=F; voltageScale(2)=0.30;       % BG
    case 4, inj(3)=F; voltageScale(3)=0.30;       % CG
    case 5, inj([1 2])=[F -F]; voltageScale([1 2])=0.45; % AB
    case 6, inj([2 3])=[F -F]; voltageScale([2 3])=0.45; % BC
    case 7, inj([3 1])=[F -F]; voltageScale([3 1])=0.45; % CA
    case 8, inj([1 2])=[F+1i*G -F+1i*G]; voltageScale([1 2])=0.25; % ABG
    case 9, inj([2 3])=[F+1i*G -F+1i*G]; voltageScale([2 3])=0.25; % BCG
    case 10,inj([3 1])=[F+1i*G -F+1i*G]; voltageScale([3 1])=0.25; % CAG
    case 11,inj=4*s*baseI; voltageScale(:)=0.20; % ABC
end
omega = 2*pi*f0;
rot = exp(1i*omega*t);
faultMask = double(t>=tFault);
I = sqrt(2)*real(rot*baseI + (faultMask.*rot)*inj);
V = sqrt(2)*real(rot*baseV + (faultMask.*rot)*(baseV.*(voltageScale-1)));
I = I + noiseStd*randn(size(I));
V = V + noiseStd*randn(size(V));
end

function [code,feat] = detectAndClassify(t,I,fs,f0,tFault)
% Compare 2 full 50-Hz cycles before and after the fault transition.
% Difference phasors remove the balanced load current baseline.
pre = t>=tFault-0.05 & t<tFault-0.01;  % 2 cycles: 0.03..0.07
post = t>=tFault+0.03 & t<tFault+0.07; % 2 cycles: 0.11..0.15
ipre = estimatePhasor(I(pre,:),t(pre),f0);
ipost = estimatePhasor(I(post,:),t(post),f0);
d = ipost - ipre;
mag = abs(d);
maxMag = max(mag);
residualRatio = abs(sum(d))/max(maxMag,1e-12);
feat = [mag residualRatio];
if maxMag<1.5
    code=1; return;
end
active = mag>0.40*maxMag;
nActive = sum(active);
if nActive==3
    code=11; return;
elseif nActive==1
    code=find(active)+1; return; % AG/BG/CG
elseif nActive==2
    if active(1) && active(2), pair=1;
    elseif active(2) && active(3), pair=2;
    else, pair=3; end
    if residualRatio>0.30
        code=7+pair; % ABG/BCG/CAG (8..10)
    else
        code=4+pair; % AB/BC/CA (5..7)
    end
else
    code=1; % no active differences
end
end

function ph = estimatePhasor(x,t,f0)
% RMS complex phasor of a sinusoid: x(t)=sqrt(2)*Re{X exp(j wt)}
weights = exp(-1i*2*pi*f0*t);
ph = (sqrt(2)/numel(t))*(weights.'*x);
end
