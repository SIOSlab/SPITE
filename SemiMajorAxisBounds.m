function [amin,amax,imageableflag] = SemiMajorAxisBounds(m,e,inc,omega,RAAN,amingeom,amaxgeom)
%Function that calculates the absolute minimum and maximum bounds for
%semimajor axis based on geometric and photometric constraints. It takes in
%the mass, eccentricity, inclination, argument of periastron, RAAN, minimum
%semimajor axis and maximum semimajor axis from geometric constraints.

    n = 100;        %Number of positions in the orbit to calculate contrast
    avect = linspace(amingeom,amaxgeom,n);  %Creates a vector within the geometric bounds of semimajor axis
    minflag = 0;            %Flag for calculation of the minimum semimajor axis from photometric constraints
    maxflag = 0;            %Flag for calculation of the maximum semimajor axis from photometric constraints
    imageableflag = 1;      %Flag that indicates there is an imageable region of overlap between photometric and geometric constraints
    amax = amaxgeom;        %Initialize the maximum
    for i = 1:n
        %Calculate the percentage of each semimajor axis's orbit where the planet
        %will be imageable
        contper = Contrast(m,avect(i),e,inc,omega,RAAN);
         if minflag == 0
             if contper > 0
                 %If a sufficient portion of the orbit is imageable and the
                 %minimum from photometric constraints has not yet been set
                 %then log this value as the absolute minimum bound for
                 %semimajor axis
                 amin = avect(i);
                 minflag = 1;
             end
         end
         if minflag == 1
             if maxflag == 0
                 if contper == 0
                 %If a sufficient portion of the orbit is imageable, the minimum bound has been calculated,
                 %and the maximum from photometric constraints has not yet been set
                 %then log this value as the absolute maximum bound for semimajor axis
                     amax = avect(i);
                     maxflag = 1;
                 end
             end
         end
    end 
    if minflag == 0;
        %If the exoplanet is not imageable due to photometric constraints
        %over the region where it is imageable due to geometric constraints
        %then set the values to 0 and trip the imageable flag to 0
        amin = 0;
        amax = 0;
        imageableflag = 0;
    end
end

