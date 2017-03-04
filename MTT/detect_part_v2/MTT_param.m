%% MTT: Multiple Target Tracing algorithms
%% PARAMETERS FILE
%% 
%%
%%
%% This programme is compatible with Matlab and Octave software
%%
%%
%% ALGORITHM AUTHORS:
%%
%% N. BERTAUX, A. SERGE
%%
%%
%% RESEARCH AUTHORS:
%% 
%% Copyright A. SERGE(1,2,3), N. BERTAUX(4,5,6), H. RIGNEAULT(4,5), D. MARGUET(1,2,3)
%%
%%
%% AFFILIATIONS :
%%
%% (1) CIML, University of Marseille, F13009, FRANCE
%%
%% (2) INSERM, UMR 631, Marseille, F13009, FRANCE
%%
%% (3) CNRS, UMR 6102, Marseille, F13009, FRANCE
%%
%% (4) Fresnel Institut - PhyTI Team - MARSEILLE - F13397 - FRANCE
%%
%% (5) CNRS, UMR 6133, Marseille, F13397, FRANCE
%% 
%% (6) Ecole Centrale de Marseille - France
%%
%%
%% last modifications 03/12/07



%% =============================================
%% add in path utils_SPT/ subroutines repertoire
%% =============================================


%% =====================================================
%% =====================================================
%% FILE PARAMETERS
%% =====================================================
%% =====================================================

%% version program
%% comment corresponding ligne
%%VERSION = 'OCTAVE' ;
VERSION = 'MATLAB' ;


%% =============================================
%% DISPLAY PARAMETERS
%% =============================================

%% output as images, format ppm
AFFICHAGE = 0 ; 

%% output file extension (ppm, jpg, gif, etc.)
FORMAT_IM = 'jpg' ;

%% Display particles number
AFF_NUM_TRAJ = 1 ; %% 0/1 

SHOW = 0 ; %% 0/1 inline dislay output images

%% image size output option
%%imwrite_option = ''; 
imwrite_option = '-resize 320x240' ;

%% display of the tracking of a limited number of particles
%%
%% all particules
liste_part = 0 ; 
%%
%% only particle number (>0)
%% liste_part = [1 3 8 9 12 13 15 16 17] ;
%%
%% all without particle number (<0)
%% liste_part = -[18 19 5 20 21 34] ;



%% ===============================================
%% DATA INPUT
%% ===============================================

%% directory
repertoire = '' ;

%% filename
stack = 'EGFR-Qd605-frames1to50.stk' ; % 'Simul_Free_Conf_Blink.stk' ; % 

%% number of images
Nb_STK = 50 ; % 100 ; % 

%% limitation of the zone of interest
CROP = 0 ; %% boolean 0/1
IRANGE = 180 + (1:120) ; 
JRANGE = 15  + (1:80) ; 


%% ===============================================
%% OUTPUT
%% ===============================================
output_dir = '../data/output22' ;

if ~isdir(output_dir), mkdir(output_dir), end


%% ===============================================
%% Tracking parameters
%% ===============================================

%% ====================
%% detection parameters
%% ====================

%% Pre-Detection threshold
seuil_premiere_detec = 24 ; %% 10^-6

%% Final detection threshold
seuil_detec_1vue = 28 ;  %% 10^-7

%% Size Windows en pixel (Ws)
wn = 7 ;

%% Gaussian radius in pixel (r0)
r0 = 1.1 ; 


%% =======================
%% Reconnection parameters
%% =======================

%% temporal sliding window (Wt)
T = 5 ; %% taille fenetre glissante temporelle

%% number of deflation loop
nb_defl = 1 ;

%% disappearance prob of blinking (tau_off)
T_off = -15 ;

%% Maximum diffusion coef Dmax
sig_free = 0.7 ; %% in pixel

%% Reference diametre for research set particles/trajectories
%% diameter = Boule_free*sig_free 
Boule_free = 3.5 ;
 
%% Limitation of combinations number 
%% Nb_combi define maximum number of particle/trajectories
%% becarefull the complexity change as fact(Nb_combi) (4!=24 , 5!=120)
Nb_combi = 4 ;

%% validation of pre-detected particles
%% & new ones
seuil_alpha = 4000 ; %% environ 20 dB

%% weight of likeliood of alpha
%% between uniform and gaussian law
Poids_melange_aplha = 0.5 ;

%% weight of likelihood between
%% maximum and local diffusion
Poids_melange_diff = 0.9 ;


%% =====================================================
%% =====================================================
%% END PARAMETERS FILE
%% =====================================================
%% =====================================================


