#cython: boundscheck=False
#cython: language_level=3
#cython: wraparound=False
#cython: nonecheck=False
#cython: cdivision=True

import numpy as np
cimport numpy as np
from numpy cimport ndarray

#######################################
# C functions to be used
from libc.math cimport sqrt, abs, log, cos, sin, acos

#######################################
# C implementation of RANDOM
from libc.stdlib cimport rand, RAND_MAX

cdef double UniformRand():
	return ( rand() + 1. )/(RAND_MAX + 1. )


#######################################
# Box muller method for NORMAL distributed random variables
cdef double NormalRand(double mean, double stddev):
	cdef double n2 = 0.0
	cdef int n2_cached = 0
	cdef double x, y, r
	cdef double result,d,n1

	if (not n2_cached):
		while (True):
			x = 2.0*UniformRand() - 1
			y = 2.0*UniformRand() - 1

			r = x*x + y*y

			if (r != 0.0 and r <= 1.0):
				break
		
		
		d = sqrt(-2.0*log(r)/r)
		n1 = x*d
		n2 = y*d
		result = n1*stddev + mean
		n2_cached = 1
		return result
	else:
		n2_cached = 0;
		return n2*stddev + mean

#######################################
# RANDOM FUNCTIONS
#######################################

#******************************
def random_generator(int size, double min, double max):
	cdef ndarray[double,ndim=1] s = np.empty((size))
	for i in range(size):
		s[i] = (max-min)*UniformRand()+min
	return s

#******************************
def random_normal(ndarray[double, ndim=1] x, ndarray[double, ndim=1] sigma):
	cdef int size = x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((size))
	for i in range(size):
		s[i] = NormalRand(x[i], sigma[i])
	return s


#######################################
# FOURVECTOR FUNCTIONS
#######################################

#******************************
def build_fourvec(ndarray[double, ndim=1] E, ndarray[double, ndim=1] p, ndarray[double, ndim=1] cost, ndarray[double, ndim=1] phi):

	cdef int i,m
	m = phi.shape[0]
	cdef ndarray[double,ndim=2] s = np.empty((m,4))

	with nogil:
		for i in range(m):
			s[i,0] = E[i]
			s[i,1] = p[i]*cos(phi[i])*sqrt(1.0-cost[i]*cost[i])
			s[i,2] = p[i]*sin(phi[i])*sqrt(1.0-cost[i]*cost[i])
			s[i,3] = p[i]*cost[i]

	return s

#******************************
def momentum_scalar(ndarray[double] E, double mass):

	cdef int i,m
	m = E.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))

	with nogil:
		for i in range(m):
			s[i] = sqrt(E[i]*E[i] - mass*mass)
	return s

#******************************
def get_theta_3vec(ndarray[double, ndim=2] r):

	cdef int i,m
	m = r.shape[0]
	cdef ndarray[double, ndim=1] s = np.empty((m))

	with nogil:
		for i in range(m):
			s[i] = acos(r[i,3]/sqrt(r[i,1]*r[i,1]+r[i,2]*r[i,2]+r[i,3]*r[i,3]))
	return s

#******************************
def mass(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = sqrt(x[i,0]*x[i,0] - x[i,1]*x[i,1] - x[i,2]*x[i,2] - x[i,3]*x[i,3])
	return  s

#******************************
def inv_mass(ndarray[double, ndim=2] x, ndarray[double, ndim=2] y):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = sqrt(x[i,0]*y[i,0] - x[i,1]*y[i,1] - x[i,2]*y[i,2] - x[i,3]*y[i,3])
	return  s

#******************************
def dot4(ndarray[double, ndim=2] x, ndarray[double, ndim=2] y):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = x[i,0]*y[i,0] - x[i,1]*y[i,1] - x[i,2]*y[i,2] - x[i,3]*y[i,3]
	return  s

#******************************
def dot3(ndarray[double, ndim=2] x, ndarray[double, ndim=2] y):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = x[i,1]*y[i,1] + x[i,2]*y[i,2] + x[i,3]*y[i,3]
	return  s

#******************************
def dotXY(ndarray[double, ndim=2] x, ndarray[double, ndim=2] y):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] =  x[i,1]*y[i,1] + x[i,2]*y[i,2]
	return  s

#******************************
def dotXY_vec(ndarray[double, ndim=2] x, ndarray[double, ndim=2] y):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] =  x[i,0]*y[i,0] + x[i,1]*y[i,1]
	return  s

#******************************
def getXYnorm(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] =  sqrt(x[i,1]*x[i,1] + x[i,2]*x[i,2])
	return  s
#******************************
def getXYnorm_3vec(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double,ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] =  sqrt(x[i,0]*x[i,0] + x[i,1]*x[i,1])
	return  s

#******************************
def get_vec_norm(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = sqrt(x[i,0]*x[i,0] + x[i,1]*x[i,1] + x[i,2]*x[i,2])
	return s

#******************************
def get_3vec_norm(ndarray[double,ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = sqrt(x[i,1]*x[i,1]+x[i,2]*x[i,2]+x[i,3]*x[i,3])
	return s

#******************************
def get_3norm_vec(ndarray[double,ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = sqrt(x[i,0]*x[i,0]+x[i,1]*x[i,1]+x[i,2]*x[i,2])
	return s

#******************************
def get_3direction_3vec(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=2] s = np.empty((m,3))
	with nogil:
		for i in range(m):
			s[i,0] = x[i,0]/sqrt(x[i,0]*x[i,0]+x[i,1]*x[i,1]+x[i,2]*x[i,2])
			s[i,1] = x[i,1]/sqrt(x[i,0]*x[i,0]+x[i,1]*x[i,1]+x[i,2]*x[i,2])
			s[i,2] = x[i,2]/sqrt(x[i,0]*x[i,0]+x[i,1]*x[i,1]+x[i,2]*x[i,2])
	return s

#******************************
def get_cosTheta(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = x[i,3]/sqrt(x[i,1]*x[i,1] + x[i,2]*x[i,2] + x[i,3]*x[i,3])
	return s

#******************************
def get_cos_opening_angle(ndarray[double, ndim=2] x, ndarray[double, ndim=2] y):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=1] s = np.empty((m))
	with nogil:
		for i in range(m):
			s[i] = (x[i,1]*y[i,1] + x[i,2]*y[i,2] + x[i,3]*y[i,3])/sqrt(x[i,1]*x[i,1] + x[i,2]*x[i,2] + x[i,3]*x[i,3])/sqrt(y[i,1]*y[i,1] + y[i,2]*y[i,2] + y[i,3]*y[i,3])
	return s

#******************************
def get_3direction(ndarray[double, ndim=2] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=2] s = np.empty((m,3))
	with nogil:
		for i in range(m):
			s[i,0] = x[i,1]/sqrt(x[i,1]*x[i,1]+x[i,2]*x[i,2]+x[i,3]*x[i,3])
			s[i,1] = x[i,2]/sqrt(x[i,1]*x[i,1]+x[i,2]*x[i,2]+x[i,3]*x[i,3])
			s[i,2] = x[i,3]/sqrt(x[i,1]*x[i,1]+x[i,2]*x[i,2]+x[i,3]*x[i,3])
	return s

#******************************
def put_in_z_axis(ndarray[double, ndim=1] x):
	cdef int i,m
	m= x.shape[0]
	cdef ndarray[double, ndim=2] s = np.empty((m,3))
	with nogil:
		for i in range(m):
			s[i,0] = 0.0
			s[i,1] = 0.0
			s[i,2] = x[i]
	return s

#******************************
def rotationx(ndarray[double, ndim=2] v4, ndarray[double] theta):

	cdef int i, m;

	m = v4.shape[0]

	cdef ndarray[double, ndim=2] res = np.empty((m,4))
	cdef ndarray[double, ndim=3] R = np.empty((m,4,4))

	with nogil:
		for i in range(m):
			R[i,0,0] = 1.0
			R[i,0,1] = 0.0
			R[i,0,2] = 0.0
			R[i,0,3] = 0.0

			R[i,1,0] = 0.0
			R[i,1,1] = 1.0
			R[i,1,2] = 0.0
			R[i,1,3] = 0.0

			R[i,2,0] = 0.0
			R[i,2,1] = 0.0
			R[i,2,2] = cos(theta[i])
			R[i,2,3] = -sin(theta[i])

			R[i,3,0] = 0.0
			R[i,3,1] = 0.0
			R[i,3,2] = sin(theta[i])
			R[i,3,3] = cos(theta[i])

			res[i,0] = R[i,0,0]*v4[i,0] + R[i,0,1]*v4[i,1] + R[i,0,2]*v4[i,2] + R[i,0,3]*v4[i,3]
			res[i,1] = R[i,1,0]*v4[i,0] + R[i,1,1]*v4[i,1] + R[i,1,2]*v4[i,2] + R[i,1,3]*v4[i,3]
			res[i,2] = R[i,2,0]*v4[i,0] + R[i,2,1]*v4[i,1] + R[i,2,2]*v4[i,2] + R[i,2,3]*v4[i,3]
			res[i,3] = R[i,3,0]*v4[i,0] + R[i,3,1]*v4[i,1] + R[i,3,2]*v4[i,2] + R[i,3,3]*v4[i,3]
		    
	return res

#******************************
def rotationy(ndarray[double, ndim=2] v4, ndarray[double] theta):

	cdef int i, m;
	m = v4.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))

	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = cos(theta[i])*v4[i,1] - sin(theta[i])*v4[i,3]
			res[i,2] = v4[i,2]
			res[i,3] = sin(theta[i])*v4[i,1] + cos(theta[i])*v4[i,3]
		    
	return res
#******************************
def rotationy_sin(ndarray[double, ndim=2] v4, ndarray[double] stheta):

	cdef int i, m;
	m = v4.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))

	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = sqrt(1.0-stheta[i]*stheta[i])*v4[i,1] - stheta[i]*v4[i,3]
			res[i,2] = v4[i,2]
			res[i,3] = stheta[i]*v4[i,1] + sqrt(1.0-stheta[i]*stheta[i])*v4[i,3]
		    
	return res
#******************************
def rotationy_cos(ndarray[double, ndim=2] v4, ndarray[double] ctheta, int sign=1):

	cdef int i, m;
	m = v4.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))

	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = ctheta[i]*v4[i,1] - sign*sqrt(1.0-ctheta[i]*ctheta[i])*v4[i,3]
			res[i,2] = v4[i,2]
			res[i,3] = sign*sqrt(1.0-ctheta[i]*ctheta[i])*v4[i,1] + ctheta[i]*v4[i,3]
		    
	return res

#******************************
def rotationz(ndarray[double, ndim=2] v4, ndarray[double] theta):

	cdef int i, m;
	m = v4.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))
	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = cos(theta[i])*v4[i,1] - sin(theta[i])*v4[i,2] 
			res[i,2] = sin(theta[i])*v4[i,1] + cos(theta[i])*v4[i,2] 
			res[i,3] = v4[i,3]
		    
	return res
#******************************
def rotationz_sin(ndarray[double, ndim=2] v4, ndarray[double] stheta):

	cdef int i, m;
	m = v4.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))
	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = sqrt(1.0-stheta[i]*stheta[i])*v4[i,1] - stheta[i]*v4[i,2] 
			res[i,2] = stheta[i]*v4[i,1] + sqrt(1.0-stheta[i]*stheta[i])*v4[i,2] 
			res[i,3] = v4[i,3]
		    
	return res
#******************************
def rotationz_cos(ndarray[double, ndim=2] v4, ndarray[double] ctheta, int sign = 1):

	cdef int i, m;
	m = v4.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))
	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = ctheta[i]*v4[i,1] - sign*sqrt(1.0-ctheta[i]*ctheta[i])*v4[i,2] 
			res[i,2] = sign*sqrt(1.0-ctheta[i]*ctheta[i])*v4[i,1] + ctheta[i]*v4[i,2] 
			res[i,3] = v4[i,3]
		    
	return res

#******************************
def L(ndarray[double, ndim=2] v4, ndarray[double] beta):
	cdef int i, m;
	m = beta.shape[0]
	cdef ndarray[double, ndim=2] res = np.empty((m,4))
	with nogil:
		for i in range(m):
			res[i,0] = 1.0/sqrt(1.0 - beta[i]*beta[i])*v4[i,0] - beta[i]/sqrt(1.0 - beta[i]*beta[i])*v4[i,3]
			res[i,1] = v4[i,1] 
			res[i,2] = v4[i,2] 
			res[i,3] = -beta[i]/sqrt(1.0 - beta[i]*beta[i])*v4[i,0] + 1.0/sqrt(1.0 - beta[i]*beta[i])*v4[i,3]
		    
	return res

#******************************
def T(ndarray[double, ndim=2] v4, ndarray[double] beta, ndarray[double] theta, ndarray[double] phi):
	return L( rotationy( rotationz(v4,-phi), theta), -beta)

#******************************
def Tinv(ndarray[double, ndim=2] v4, ndarray[double] beta, ndarray[double] ctheta, ndarray[double] phi):
	return rotationz( rotationy_cos( L(v4, beta), ctheta, sign=-1), phi)


#******************************
def hepevt_printer(ndarray[double, ndim=3] np_events):
	cdef int i, m;
	m = np_events.shape[0]
	// cdef ndarray[double, ndim=2] res = np.empty((m,4))
	
	# pre-computing some variables
	mass_projectile = Cfv.mass(np_events[:,0:4])
	mass_target = Cfv.mass(df_gen['P_target'].to_numpy())
	mass_decay_N_parent = Cfv.mass(df_gen['P_decay_N_parent'].to_numpy())
	mass_recoil = Cfv.mass(df_gen['P_recoil'].to_numpy())
	mass_decay_N_daughter = Cfv.mass(df_gen['P_decay_N_daughter'].to_numpy())

	pvec_projectile = df_gen['P_projectile'][['1','2','3']].to_numpy()
	pvec_target = df_gen['P_target'][['1','2','3']].to_numpy()
	pvec_decay_N_parent = df_gen['P_decay_N_parent'][['1','2','3']].to_numpy()
	pvec_recoil = df_gen['P_recoil'][['1','2','3']].to_numpy()
	pvec_decay_N_daughter = df_gen['P_decay_N_daughter'][['1','2','3']].to_numpy()
	pvec_decay_ell_minus = df_gen['P_decay_ell_minus'][['1','2','3']].to_numpy()
	pvec_decay_ell_plus = df_gen['P_decay_ell_plus'][['1','2','3']].to_numpy()


	pvec_pos_decay = df_gen['pos_decay'][['1','2','3']].to_numpy()
	pvec_pos_scatt = df_gen['pos_scatt'][['1','2','3']].to_numpy()

	
	
	with nogil:
		for i in range(m):
			res[i,0] = v4[i,0]
			res[i,1] = ctheta[i]*v4[i,1] - sign*sqrt(1.0-ctheta[i]*ctheta[i])*v4[i,2] 
			res[i,2] = sign*sqrt(1.0-ctheta[i]*ctheta[i])*v4[i,1] + ctheta[i]*v4[i,2] 
			res[i,3] = v4[i,3]
		    
	n_events = df_gen.index[-1]
	with nogil:
	# loop over events
	for i in range(n_events):
		
		# no particles & event id
		if unweigh:
			lines.append(f"{i} 7\n")
		else:
			lines.append(f"{i} 7 {df_gen['w_event_rate'][i]:.8g}\n")

		# scattering inital states
		lines.append((	# Projectile
					f"0 "
					f" {int(lp.nu_mu.pdgid)}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_projectile[i])}"
					f" {df_gen['P_projectile','0'][i]:.8g}"
					f" {mass_projectile[i]:.8g}"
					f" {print_in_order(pvec_pos_scatt[i])}"
					f" {df_gen['pos_scatt','0'][i]:.8g}"
					"\n"
					))
					
		lines.append((	# Target
					f"0 "
					f" {int(df_gen['target_pdgid'][i])}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_target[i])}"
					f" {df_gen['P_recoil','0'][i]:.8g}"
					f" {mass_target[i]:.8g}"
					f" {print_in_order(pvec_pos_scatt[i])}"
					f" {df_gen['pos_scatt','0'][i]:.8g}"
					"\n"
					))

		# scatter final products
		lines.append((	# HNL produced
					f"0 "
					f" {int(pdg.neutrino5.pdgid)}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_decay_N_parent[i])}"
					f" {df_gen['P_decay_N_parent','0'][i]:.8g}"
					f" {mass_decay_N_parent[i]:.8g}"
					f" {print_in_order(pvec_pos_scatt[i])}"
					f" {df_gen['pos_scatt','0'][i]:.8g}"
					"\n"
					))

		lines.append((	# recoiled target
					f"0 "
					f" {int(df_gen['target_pdgid'][i])}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_recoil[i])}"
					f" {df_gen['P_recoil','0'][i]:.8g}"
					f" {mass_recoil[i]:.8g}"
					f" {print_in_order(pvec_pos_scatt[i])}"
					f" {df_gen['pos_scatt','0'][i]:.8g}"
					'\n'
					))

		# decay final products
		lines.append((	# daughter neutrino/HNL
					f"0 "
					f" {int(pdg.nulight.pdgid)}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_decay_N_daughter[i])}"
					f" {df_gen['P_decay_N_daughter','0'][i]:.8g}"
					f" {mass_decay_N_daughter[i]:.8g}"
					f" {print_in_order(pvec_pos_decay[i])}"
					f" {df_gen['pos_decay','0'][i]:.8g}"
					'\n'
					))

		lines.append((	# electron
					f"1 "
					f" {int(lp.e_minus.pdgid)}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_decay_ell_minus[i])}"
					f" {df_gen['P_decay_ell_minus','0'][i]:.8g}"
					f" {const.m_e:.8g}"
					f" {print_in_order(pvec_pos_decay[i])}"
					f" {df_gen['pos_decay','0'][i]:.8g}"
					"\n"
					))

		lines.append((	# positron
					f"1 "
					f" {int(lp.e_plus.pdgid)}"
					f" 0 0 0 0"
					f" {print_in_order(pvec_decay_ell_plus[i])}"
					f" {df_gen['P_decay_ell_plus','0'][i]:.8g}"
					f" {const.m_e:.8g}"
					f" {print_in_order(pvec_pos_decay[i])}"
					f" {df_gen['pos_decay','0'][i]:.8g}"
					"\n"
					))

		


	return res
