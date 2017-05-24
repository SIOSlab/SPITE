function contper = Contrast(m,a,e,i,omega,RAAN)
%Function that calculates the percentage of an orbit over which an
%exoplanet with the given orbital parameters will be imageable

    mincont = 10^-9;                    %Contrast Threshold for Detection
    rjup = 0.000477894503;              %Radius of Jupiter (Au)
    Voljup = (4/3)*pi*(rjup^3);         %Volume of Jupiter (Au^3)
    rhojup = 1/Voljup;                  %Density of Jupiter (Jupiter Masses/(Au^3))
    P  = 0.5;                           %Geometric Albedo
    rp = ((3*m)/(4*pi*rhojup))^(1/3);   %Radius of the Planet (Au)
    
    n = 100;       %Number of Positions in the Orbit to Check if Contrast Exceeds Minimum Threshold
    Mvect = linspace(0,2*pi(),n); %Create a Vector of Mean Anomalies to Calculate Orbital Positions
    ncont = 0;     %Initialize the Counter for Number of Positions that Exceed the Minimum Threshold
    
for k = 1:n
    M = Mvect(k);  %Pull a Value for Mean Anomaly from the Vector
    %Calculate the eccentric anomaly from the mean anomaly and eccentricity
    E = M+(e-0.125*(e^3))*sind(M)+0.5*(e^2)*sind(2*M)+0.375*(e^3)*sind(3*M);

    %Calculate the true anomaly from the eccentric anomaly and eccentricity
    vtrue = 2*atand((((1+e)/(1-e))^0.5)*tand(E/2));

    %Calculate the radius from the true anomaly, eccentricity, and semimajor axis
    r = a*(1-(e^2))/(1+e*cosd(vtrue));

    %Calculate x, y, and z from RAAN, argument of perigee, true anomaly, and
    %radius

    x0 = r*(cosd(RAAN)*cosd(omega+vtrue) - sind(RAAN)*sind(omega+vtrue)*cosd(i));
    y0 = r*(sind(RAAN)*cosd(omega+vtrue) + cosd(RAAN)*sind(omega+vtrue)*cosd(i));
    z0 = r*sind(i)*sind(omega+vtrue);

   
    norm1 = (x0^2+y0^2)^0.5; %Calculate the Distance of the Planet from the Star on the Horizontal Plane
    norm2 = (x0^2+y0^2+z0^2)^0.5; %Calculate the Distance of the Planet from the Star

    beta = asin(norm1/norm2);                       %Calculate the Phase Angle
    phase = (sin(beta)+(pi()-beta)*cos(beta))/pi(); %Calculate the Phase Function
    cont = ((rp/r)^2)*P*phase;                      %Calculate the Contrast

    if cont >= mincont      %Check if the Contrast is Above the Minimum Threshold
        ncont = ncont + 1;  %Increase the Counter for Number of Positions that Exceed the Minimum Threshold
    end

end

contper = ncont/n;    %Calculate the Percentage of the Orbital Positions that are Detectable

end