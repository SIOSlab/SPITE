function [x0,y0,z0,xdot0,ydot0,zdot0] = OEtoCart(mu,m,a,e,i,omega,RAAN,M0,T,t)
% Convert orbital parameters into cartesian position and velocity
% components

%% Calculate the mean angular motion from mu and semimajor axis

n = (mu/(a^3))^0.5;

%% Calculate the mean anomaly from mean angular motion and time

M = M0 + n*(t-T);

%% Calculate the eccentric anomaly from the mean anomaly and eccentricity

E = M+(e-0.125*(e^3))*sind(M)+0.5*(e^2)*sind(2*M)+0.375*(e^3)*sind(3*M);

%% Calculate the true anomaly from the eccentric anomaly and eccentricity

vtrue = 2*atand((((1+e)/(1-e))^0.5)*tand(E/2));

%% Calculate the radius from the true anomaly, eccentricity, and semimajor axis
r = a*(1-(e^2))/(1+e*cosd(vtrue));

%% Calculate x, y, and z from RAAN, argument of perigee, true anomaly, and radius

x0 = r*(cosd(RAAN)*cosd(omega+vtrue) - sind(RAAN)*sind(omega+vtrue)*cosd(i));
y0 = r*(sind(RAAN)*cosd(omega+vtrue) + cosd(RAAN)*sind(omega+vtrue)*cosd(i));
z0 = r*sind(i)*sind(omega+vtrue);

%% Calculate the radius of perigee from the semimajor axis and eccentricity

rp = a*(1-e);

vorbref = (((mu*a)^0.5)/r).*[-sind(E) cosd(E)*((1-(e^2))^0.5) 0];

%Calculate xdot,ydot, and zdot from RAAN, argument of perigee, true anomaly, and v
xdot0 = vorbref(1)*(cosd(omega)*cosd(RAAN)-sind(omega)*cosd(i)*sind(RAAN))...
    -vorbref(2)*(sind(omega)*cosd(RAAN)+cosd(omega)*cosd(i)*sind(RAAN));
ydot0 = vorbref(1)*(cosd(omega)*sind(RAAN)+sind(omega)*cosd(i)*cosd(RAAN))...
    +vorbref(2)*(cosd(omega)*cosd(RAAN)*cosd(i)-sind(omega)*sind(RAAN));
zdot0 = vorbref(1)*sind(omega)*sind(i)+vorbref(2)*cosd(omega)*sind(i);

end


