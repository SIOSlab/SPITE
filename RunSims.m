%Master program for operating the ranking system for imaging of exoplanets
%based on the stability of orbits within the imageable region for known
%exoplanetary systems. This program allows the user to set the number of 
%cores for parallel computing purposes. The planets to be compared are
%selected by entering the corresponding number to their indices in the
%structs PwMass and PwMsini. The number of test cases for each system to be
%simulated is also controllable. The saved tables StabilityMsini and
%StabilityMass contain the indice of the system, the total number of stable
%orbits simulated in a given run for each system, and the percentage of
%test cases which were stable for each system.

%Select the number of test cases to be generated and simulated for each
%known exoplanetary system
nsimsgoal = 50;

%Initialize the worker pool for parallel computing. The values ncores
%selects how many cores will be used at a given time for simulation
ncores = 16;
parpool(ncores)

%Load the values for the known exoplanets
PwMsini = importdata('PwMsini.mat');
PwMass  = importdata('PwMass.mat');

%Select which systems to rank by entering their corresponding indices in
%PwMsini and PwMass. If no systems are to be simulated for one of these
%sets then enter a 0 into the corresponding vector.
Msinivect = [4 5 15 16 20 21 48 49 53 79];
Massvect  = [0];

%Initialize the Stability Vectors
nMsini = length(Msinivect);
nMmass = length(Massvect);
StabilityMsini = zeros(2,nMsini);
StabilityMass = zeros(2,nMass);

%Simulate
for k = 1:(nMsini)
    StabilityVect = [];         %Initialize the current stability vector
    P = PwMsini(k);             %Pull the parameters for the known exoplanet
    
    parfor (i = 1:nsimsgoal,ncores)
        [T_OUT,Y_OUT,DY_OUT,stability] = ThreeBodySimMsini(P); %Simulate 1 test case
        StabilityVect = [StabilityVect stability];          %Add the result             
    end
    nstable = sum(StabilityVect);               %Calculate the total number of stable orbits found for the system
    percentstable = nstable/nsimsgoal;          %Calculate the percent of test cases which were stable
    StabilityMsini(1,k) = percentstable;        %Log the percent of test cases which were stable
    StabilityMsini(2,k) = nstable;              %Log the total number of stable orbits found for the system
    c = clock             %Print out the time of completion for each system
    save('StabilityMsini','StabilityMsini')     %Save the result
end

for k = 1:(nMass)
    StabilityVect = [];         %Initialize the current stability vector
    P = PwMass(k);              %Pull the parameters for the known exoplanet
    parfor i = 1:nsimsgoal
        [T_OUT,Y_OUT,DY_OUT,stability] = ThreeBodySimMass(P); %Simulate 1 test case
        StabilityVect = [StabilityVect stability];          %Add the result             
    end
    nstable = sum(StabilityVect);               %Calculate the total number of stable orbits found for the system
    percentstable = nstable/nsimsgoal;          %Calculate the percent of test cases which were stable
    StabilityMass(1,k) = percentstable;        %Log the percent of test cases which were stable
    StabilityMass(2,k) = nstable;              %Log the total number of stable orbits found for the system
    c = clock             %Print out the time of completion for each system
    save('StabilityMass','StabilityMass')       %Save the result
end
