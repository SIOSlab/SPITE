function rando = GenerateTestCase(d)
% This function generates the mass, semimajor axis (a), eccentricity (e),
% inclination (i), argument of perigee (omega), and Right Accension of the
% Ascending Node (RAAN)

%% Create mass (m) using SampleDist

% Jupiter masses between of 0.5 to 12 Jupiter masses.
% Bounded at 15 Jupiter masses

rando.m = sampleDist(@(m) m.^(-1.31),1,[0.5 12],34);

%% Create eccentricity (e) using Rayleigh random

rando.e = raylrnd(0.21);

%% Create Inclination (i) using sinusoidaldDistribution

rando.i = asin((pi/9)*rand-pi/18);

%% Create Omega using a uniform random distribution

rando.omega = 2*pi*rand;

%% create RAAN using a uniform random distribution

rando.RAAN = 2*pi*rand;

rando.M0 = 0;
rando.T = 0;

%% Create semi-major axis (a) using SampleDist and the geometric and optical
%%bounds on the semimajor axis

IWA = 0.1;          %Inner Working Angle (arcseconds)
OWA = 0.5;          %Outer Working Angle (arcseconds)
amin = IWA*d;       %Geometric Minimum Semimajor Axis
amax = OWA*d;       %Geometric Maximum Semimajor Axis
%Generate Bounds with the Contrast Threshold Function through Semimajor
%Axis Bounds
[amin,amax,imageableflag] = SemiMajorAxisBounds(rando.m,rando.e,rando.i,rando.omega,rando.RAAN,amin,amax);

if imageableflag == 1
    %If there is an imageable region for the star
    rando.a = sampleDist(@(a) a.^(-0.62).*exp(-2*a./(30)),1,[amin amax],35);
else
    %If there is no imageable region for the star
    rando.a = 0;
end
end