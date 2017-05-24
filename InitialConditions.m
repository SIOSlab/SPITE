function [Y_IN,DY_IN] = InitialConditions(prand,pknown,s)
%Outputs the initial positions and velocities of the 3 bodies (known
%planet, random test planet, and star) from the Keplerian orbital elements
%included in the structs. 
G = 2.8245e-07;             %gravitational constant
t  = 0;

s.mu = G * s.m;             %Calculate the specific gravitational constant for the star

%Convert the orbital elements of the random test planet to their cartesian
%coordinates in a star-centered reference frame
[xr0,yr0,zr0,xdotr0,ydotr0,zdotr0] = OEtoCart(s.mu,prand.m,prand.a,prand.e,...
                       prand.i,prand.omega,prand.RAAN, prand.M0,prand.T,t);

%Convert the orbital elements of the known planet to their cartesian
%coordinates in a star-centered reference frame
[xp0,yp0,zp0,xdotp0,ydotp0,zdotp0] = OEtoCart(s.mu,pknown.m,pknown.a,pknown.e,...
               pknown.i,pknown.omega,pknown.RAAN,pknown.M0,pknown.T,t);
                       
%Calculate the total mass of the system
mtot = prand.m+pknown.m+s.m;

%Calculate the center of mass of the system
xs0 = (prand.m*xr0+pknown.m*xp0)/mtot;     
ys0 = (prand.m*yr0+pknown.m*yp0)/mtot;
zs0 = (prand.m*zr0+pknown.m*zp0)/mtot;

%Calculate the initial velocity of the star by assuming the center of
%mass of the system has 0 velocity for simplicity
xdots0 = (prand.m*xdotr0+pknown.m*xdotp0)/mtot;
ydots0 = (prand.m*ydotr0+pknown.m*ydotp0)/mtot;
zdots0 = (prand.m*zdotr0+pknown.m*zdotp0)/mtot;

%Convert the positions and velocities of the random test planet from star
%centric coordinates to center of mass centric coordinates
xr0 = xr0+xs0;
yr0 = yr0+ys0;
zr0 = zr0+zs0;
xdotr0 = xdotr0+xdots0;
ydotr0 = ydotr0+ydots0;
zdotr0 = zdotr0+zdots0;

%Convert the positions and velocities of the known planet from star
%centric coordinates to center of mass centric coordinates
xp0 = xp0+xs0;
yp0 = yp0+ys0;
zp0 = zp0+zs0;
xdotp0 = xdotp0+xdots0;
ydotp0 = ydotp0+ydots0;
zdotp0 = zdotp0+zdots0;

%Arrange results into correct format for rebound function
Y_IN  = [xr0 yr0 zr0 xp0 yp0 zp0 xs0 ys0 zs0]';
DY_IN = [xdotr0 ydotr0 zdotr0 xdotp0 ydotp0 zdotp0 xdots0 ydots0 zdots0]';

end

