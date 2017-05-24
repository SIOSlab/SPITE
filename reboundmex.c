/*
 * [T_OUT,Y_OUT,DY_OUT] = reboundtest1(TS_IN, Y_IN, DY_IN, MUS)
 *
 *      TS_IN   3  x 1 : [dt,tmax, dtoutput]
 *      Y_IN    3n x 1 : initial positions (x1,y1,z1,x2,y2,z2...)
 *      DY_IN   3n x 1 : initial velocities (dx1,dy1,dz1,dx2,dy2,dz2...)
 *      MUS     n  x 1 : Gravitational paramters (mu1,mu2,mu3...)
 *
 *
 * Compile call: mex -v -IreboundPath/rebound/src -LreboundPath/rebound/src -lrebound reboundmex.c
 * mex -v -I/Users/ds264/Documents/gitrepos/rebound/src -L/Users/ds264/Documents/gitrepos/rebound/src -lrebound reboundmex.c
 *
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include "rebound.h"
#include "mex.h"

/* Input Arguments */

#define	TS_IN	prhs[0]
#define	Y_IN	prhs[1]
#define	DY_IN	prhs[2]
#define MUS     prhs[3]

/* Output Arguments */
#define	T_OUT	plhs[0]
#define	Y_OUT	plhs[1]
#define	DY_OUT	plhs[2]

void heartbeat(struct reb_simulation* r);
int i, N, counter, nout;
double *ts, *t, *y, *dy;

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray*prhs[] ){
    
    double *y0, *dy0, *mus;
    mwSize sy0_m, sy0_n, sdy0_m, sdy0_n, st, n;
    
    /* Check for proper number of arguments */
    if (nrhs != 4) {
        mexErrMsgTxt("Four input arguments required.");
    } else if (nlhs > 3) {
        mexErrMsgTxt("Too many output arguments.");
    }
    
    /* Check inputs.  y0 and dy0 must be 3*n x 1. t must be 2 x 1*/
    sy0_m = mxGetM(Y_IN);
    sy0_n = mxGetN(Y_IN);
    sdy0_m = mxGetM(Y_IN);
    sdy0_n = mxGetN(Y_IN);
    st = mxGetNumberOfElements(TS_IN);
    n = mxGetNumberOfElements(MUS);
    N = (int) n;
    
    if (!mxIsDouble(Y_IN) || mxIsComplex(Y_IN) ||
            !mxIsDouble(DY_IN) || mxIsComplex(DY_IN) ||
            !mxIsDouble(TS_IN) || mxIsComplex(TS_IN) ||
            !mxIsDouble(MUS) || mxIsComplex(MUS) ||
            (sy0_n != 1) || ( sy0_m/3 != n ) ||
            (sdy0_n != 1) || (sdy0_m != sy0_m) || (st != 3)) {
        mexErrMsgTxt("Y and DY must be 3n x 1 real vectors. TS must be 3 x 1.  MUS must be n x 1.");
    }
    
    /* Assign pointers to the various parameters */
    ts = mxGetPr(TS_IN);
    y0 = mxGetPr(Y_IN);
    dy0 = mxGetPr(DY_IN);
    mus = mxGetPr(MUS);

    if (ts[2] < ts[0]){ts[2] = ts[0];}
    counter = 0;
    double tmp = ts[1]/ts[2];
    if (tmp == ceil(tmp)){
        nout = (int) tmp + 1;
    } else { nout = (int) ceil(tmp); }

    /* Allocate space for return arguments */
    Y_OUT = mxCreateDoubleMatrix(sy0_m, nout, mxREAL);
    DY_OUT = mxCreateDoubleMatrix(sdy0_m, nout, mxREAL);
    T_OUT = mxCreateDoubleMatrix(nout, 1, mxREAL);
    y = mxGetPr(Y_OUT);
    dy = mxGetPr(DY_OUT);
    t = mxGetPr(T_OUT);
    
	struct reb_simulation* r = reb_create_simulation();
	// Setup constants
	r->dt = ts[0];
	r->G = 1.0;
	r->ri_whfast.safe_mode 	= 0;		// Turn off safe mode. Need to call reb_integrator_synchronize() before outputs. 
	r->ri_whfast.corrector 	= 11;		// 11th order symplectic corrector
	//r->integrator		= REB_INTEGRATOR_WHFAST;
    r->integrator		= REB_INTEGRATOR_LEAPFROG;
	r->heartbeat		= heartbeat;
	r->exact_finish_time = 1; // Finish exactly at tmax in reb_integrate(). Default is already 1.
    r->visualization = REB_VISUALIZATION_NONE; //toggle off visualization

	// Initial conditions
	for (i=0;i<N;i++){
		struct reb_particle p = {0};
		p.x  = y0[3*i];     p.y  = y0[3*i+1];	p.z  = y0[3*i+2];
		p.vx = dy0[3*i]; 	p.vy = dy0[3*i+1];	p.vz = dy0[3*i+2];
		p.m  = mus[i];
		reb_add(r, p); 
	}
    
 
	reb_move_to_com(r);
	reb_integrate(r, ts[1]);
}

void heartbeat(struct reb_simulation* r){
	if (reb_output_check(r, ts[2])){
        reb_integrator_synchronize(r);
        t[counter] = (double) r->t;
        struct reb_particle* restrict const particles = r->particles;
        for (i=0;i<N;i++){
            y[counter*N*3 + i*3] = particles[i].x;
            y[counter*N*3 + i*3+1] = particles[i].y;
            y[counter*N*3 + i*3+2] = particles[i].z;
            dy[counter*N*3 + i*3] = particles[i].vx;
            dy[counter*N*3 + i*3+1] = particles[i].vy;
            dy[counter*N*3 + i*3+2] = particles[i].vz;
        }
        counter++;
    }
}

