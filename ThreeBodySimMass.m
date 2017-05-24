function [T_OUT,Y_OUT,DY_OUT,stability] = ThreeBodySimMass(P)
%Currently Configured for Msini only

% Given a known star and one-planet system denoted by "SysNum" where the
% data sheet in reference is "EODData.csv" (taken from the NASA Exoplanet 
% Archive), generate a random second planet and observe whether the orbits
% of the two planets (known and randomly generated) are stable. Trajectory
% plots and animations are included should the user wish to see animations.



% "years" denotes how many years the user would like to simulate the orbits
% for assuming the orbits are stable


%% Pull Data for Single Planet for Test Case

%% Create Inclination (i) using sinusoidaldDistribution

pknown.m = P.mp;    % Currently working for msini systems
pknown.a = P.a;
pknown.e = P.e;
pknown.i = P.i;               
pknown.omega = P.om;
pknown.d = P.d;
pknown.RAAN = 0;            % Exact starting point of orbit doesn't matter
pknown.M0 = 0;              % Exact starting point of orbit doesn't matter
pknown.T = 0;               % Exact starting point of orbit doesn't matter

s.m = P.ms;                   % Star mass

%% Generate Test Case
prand = GenerateTestCase(pknown.d);
prand.i = prand.i + pknown.i;

%% Put into mass object for simulation
G = 2.8245e-07;             % gravitational constant

p.m1 = prand.m;
p.m2 = pknown.m;
p.m3 = s.m;

%% Initial conditions
[Y_IN,DY_IN] = InitialConditions(prand,pknown,s);

MUS = [p.m1*G p.m2*G p.m3*G]';
TS_IN = [30 365e6 (365e6)/4]';

%% Calcs  for stability
RandDistBeg  = norm(Y_IN(1:3) - Y_IN(7:9));
KnownDistBeg = norm(Y_IN(4:6) - Y_IN(7:9));

%% Integrate if the semimajor axis is not 0 which indicates there is no imageable region
if prand.a == 0
    stability = 0;
else
    stability = 1;
end
DaysRun = 0;
YearsGoal = 1e9;
while stability == 1 && DaysRun <= 365*YearsGoal
    [t_OUT,y_OUT,dy_OUT] = reboundmex(TS_IN,Y_IN,DY_IN,MUS);
    Y_IN = y_OUT(:,end);
    DY_IN = dy_OUT(:,end);
    DaysRun = DaysRun + TS_IN(2);     % how many years the integration has been run
    
    %% Stability Checks:
    RandDistEnd = norm([y_OUT(1,end) y_OUT(2,end) y_OUT(3,end)] - ...
        [y_OUT(7,end) y_OUT(8,end) y_OUT(9,end)]);
    KnownDistEnd = norm([y_OUT(4,end) y_OUT(5,end) y_OUT(6,end)] - ...
        [y_OUT(7,end) y_OUT(8,end) y_OUT(9,end)]);
    
    RandV = norm(dy_OUT(1:3,end));
    KnownV = norm(dy_OUT(4:6,end));
    
    RKepEng = (RandV^2)/2 - MUS(3)/RandDistEnd;
    KKepEng = (KnownV^2)/2 - MUS(3)/KnownDistEnd;
    
    % 1) Distance from planet to star growing by 5 and Kepler Energy
    % Violation

    if abs(RandDistEnd/RandDistBeg) > 5 || abs(KnownDistEnd/KnownDistBeg) > 5 || ...
             RKepEng > 0 || KKepEng > 0
        stability = 0;
    end
       
end

T_OUT = 0;
Y_OUT = 0;
DY_OUT = 0;

end