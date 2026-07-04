%% ========================================================================
% MATLAB Battery Management System (BMS)
% Version 4
% Author : Shubhankar Saha
% ========================================================================

clc
clear
close all

%% ========================= BATTERY PARAMETERS ===========================

capacity = 2.5;                 % Ah
initialSOC = 100;               % %
simulationTime = 7200;          % seconds
dt = 1;                         % seconds

minimumSOC = 30;                % Charging starts
maximumSOC = 90;                % Charging stops

initialTemperature = 25;        % Degree Celsius
ambientTemperature = 25;        % Degree Celsius

SOH = 100;                      % %
batteryEfficiency = 98;         % %

%% ========================= TIME VECTOR =================================

time = 0:dt:simulationTime;

N = length(time);

%% ========================= MEMORY ALLOCATION ===========================

SOC = zeros(1,N);
Voltage = zeros(1,N);
Current = zeros(1,N);
Temperature = zeros(1,N);

SOC(1)=initialSOC;
Temperature(1)=initialTemperature;

%% ========================= SIMULATION ==================================

charging = false;

for k=2:N

    %---------------------- CHARGING LOGIC -----------------------------

    if charging==false

        Current(k)=0.5+1.5*rand;

        SOC(k)=SOC(k-1)-Current(k)*dt/(capacity*3600)*100;

        if SOC(k)<=minimumSOC
            charging=true;
        end

    else

        Current(k)=-(1+rand);

        SOC(k)=SOC(k-1)-Current(k)*dt/(capacity*3600)*100;

        if SOC(k)>=maximumSOC
            charging=false;
        end

    end

    %---------------------- LIMIT SOC -----------------------------

    if SOC(k)>100
        SOC(k)=100;
    end

    if SOC(k)<0
        SOC(k)=0;
    end

    %---------------------- TEMPERATURE MODEL ----------------------

    Temperature(k)=Temperature(k-1)+0.004*abs(Current(k));

    % Natural Cooling

    if Temperature(k)>ambientTemperature

        Temperature(k)=Temperature(k)-0.001;

    end

    %---------------------- VOLTAGE MODEL --------------------------

    Voltage(k)=3+1.2*(SOC(k)/100)-0.002*(Temperature(k)-25);

    %---------------------- SOH DEGRADATION ------------------------

    SOH=SOH-0.000015;

    if SOH<80
        batteryEfficiency=95;
    end

end

%% ========================= REMAINING USEFUL LIFE =======================

RUL=(SOH/100)*1000;

%% ========================= WARNINGS ====================================

LowBattery = min(SOC)<20;

HighTemperature=max(Temperature)>60;

%% ========================= DASHBOARD ===================================

figure('Name','Battery Management System','NumberTitle','off')

subplot(2,2,1)

plot(time,SOC,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('SOC (%)')

title('State of Charge')

subplot(2,2,2)

plot(time,Voltage,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Voltage (V)')

title('Battery Voltage')

subplot(2,2,3)

plot(time,Current,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Current (A)')

title('Battery Current')

subplot(2,2,4)

plot(time,Temperature,'LineWidth',2)

grid on

xlabel('Time (s)')

ylabel('Temperature (°C)')

title('Battery Temperature')

%% ========================= SUMMARY =====================================

fprintf('\n');
fprintf('=====================================================\n');
fprintf('        BATTERY MANAGEMENT SYSTEM SUMMARY\n');
fprintf('=====================================================\n');

fprintf('Initial SOC              : %.2f %%\n',initialSOC);
fprintf('Final SOC                : %.2f %%\n',SOC(end));

fprintf('Maximum Voltage          : %.2f V\n',max(Voltage));
fprintf('Minimum Voltage          : %.2f V\n',min(Voltage));

fprintf('Average Current          : %.2f A\n',mean(Current));

fprintf('Maximum Temperature      : %.2f C\n',max(Temperature));

fprintf('Battery Health (SOH)     : %.2f %%\n',SOH);

fprintf('Battery Efficiency       : %.2f %%\n',batteryEfficiency);

fprintf('Remaining Useful Life    : %.0f Cycles\n',RUL);

fprintf('=====================================================\n');

if LowBattery

    fprintf('WARNING : Low Battery Detected\n');

else

    fprintf('Battery Charge Level Normal\n');

end

if HighTemperature

    fprintf('WARNING : High Temperature Detected\n');

else

    fprintf('Battery Temperature Normal\n');

end

fprintf('=====================================================\n');