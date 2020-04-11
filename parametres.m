% Taille des messages (Ms, Md)
M = 9;

% Nature des messages (sequence imposee, sequence generee aleatoirement, ...) 

% Nombre de modules sur le reseau (K) 
K = 3;

% Nombre de ressources physiques disponibles (N) 
N = 4;

% Debit binaire ou duree d�un bit (R = 1/Tb) 
Tb = 0.001;
R = 1 / Tb;

% Facteur de surechantillonnage du FIR ? 
Beta = 64;          % ( >= 4N-2)

% parametres du FIR: ?, L, nb 
Alpha = 0.4;

% Puissance transmise sur le cable Pt, impedance caracteristique du cable Zc 

% Facteur de sur echantillonnage pour les signaux continus (?) 
Gamma = 100;

% Rapport Eb/N0 souhaite au recepteur 

% parametres des ?ltres analogiques: nature, ordre, oscillation dans la bande passante (�ripple�), attenuation dans la bande stoppante. 

% Seuil V pour le recepteur simpli?e
% NB : Le choix du seuil V doit etre fait judicieusement par rapport a la dynamique du signal recu.
