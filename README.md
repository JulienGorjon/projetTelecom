# Numerical transmission chain simulation with matlab
Telecommunications project at ECAM Brussels, MA1
## TO DO : 
1.  Déﬁnition des parametres principaux:
    * Taille des messages (Ms, Md)
    * Nature des messages (sequence imposee, sequence generee aleatoirement, ...) 
    * Nombre de modules sur le reseau (K) 
    * Nombre de ressources physiques disponibles (N) 
    * D´ebit binaire ou dur´ee d’un bit (R = 1/Tb) 
    * Facteur de surechantillonnage du FIR β 
    * parametres du FIR: α, L, nb 
    * Puissance transmise sur le cable Pt, impedance caracteristique du cable Zc 
    * Facteur de sur echantillonnage pour les signaux continus (γ) 
    * parametres du canal: gains αn, delais τn 
    * Rapport Eb/N0 souhaite au recepteur 
    * parametres des ﬁltres analogiques: nature, ordre, oscillation dans la bande passante (’ripple’), attenuation dans la bande stoppante. 
    * Seuil V pour le recepteur simpliﬁe



2.  Calcul de variables utiles d´ependant de ces parametres:
    * Duree d’echantillon numerique Tn = Tb/β, dur´ee d’echantillon analogique Ta = Tn/γ 
    * Vecteur de fr´equences f = [0,···, 0.5 Ta ] 
    * Frequences centrales fn
    * etc.

3.  Génération des N messages binaires de longueur M.
        rand.m, round.m

4.  Codage des bits en symboles selon le schema de codage choisi.

5.  Calcul des coeﬃcients des N FIR. Normaliser ces coeﬃcients pour que le signal à la sortie du DAC soit de variance unite.
        rcosfir.m

6.  Calcul des sequences produites a la sortie des ﬁltres numeriques.

1.  Calcul des signaux analogiques à la sortie des DAC (a` consid´erer ici comme des interpolateurs id´eaux): passage à la cadence 1/Ta.
        interpft.m

8.  Réglage du niveau des signaux ´emis (en volts) pour obtenir une puissance de transmission Pt sur un caˆble d’imp´edance caract´eristique Zc à la sortie 
  de chaque emetteur.

9.  Calcul des signaux att´enu´es et retard´es par le canal de transmission s′n(t) = αnsn(t−τn). On supposera un facteur d’aﬀaiblissement αn identique pour tous les
   canaux, et des d´elai τn choisis al´eatoirement dans l’intervalle [0,Tb]. Ces d´elais reﬂ`etent le fait que les diﬀ´erents ´emetteurs ne transmettent pas leur 
   trame de donn´ees de mani`ere synchrone: ces trames arrivent en ordre dispers´e au niveau du r´ecepteur.

10. Génération du bruit filtré nf(t) correspondant au bruit blanc n(t) passé dans un ﬁltre passe-bas id´eal de bande 2N/Tb. La variance σ2 n des echantillons 
  de bruit générés ici devra permettre d’obtenir le rapport Eb/N0 souhaité.
        randn.m


11. Calcul du signal total se pr´esentant à l’entr´ee du r´ecepteur: r(t) =Ps′n(t) + nf(t). 

12. Calcul des reponses impulsionnelles fn(t) des N ﬁltres analogiques:
    * Calcul des coeﬃcients ai, bi des polynomes des fonctions de transfert Fn(f) en fonction des caractéristiques souhait´ees des ﬁltres:
            butter.m, cheby1.m, cheby2.m, ellip.m, besself.m
    * Calcul des fonctions de transfert Fn(f):
            freqs.m
    * Calcul des reponses impulsionnelles fn(t) par transform´ee de Fourier inverse (a eﬀectuer avec precaution!). Tronquer ces reponses 
      impulsionnelles (conserver par exemple 99 % de leur energie).
            fft.m, ifft.m

13. Filtrage du signal re¸cu par convolution: rn(t) = r(t) ⊗ fn(t).
            conv.m

14. Mise à l’´echelle des signaux (controle automatique de gain) pour correspondre à la dynamique de l’ADC.

15. Echantillonnage: retour à la cadence 1/Tn.

16. Quantiﬁcation des signaux sur nb bits.
        quantiz.m

17. Recepteur adapté:
    * Passage dans un ﬁltre adapté numerique 
    * Synchronisation par corr´elation avec la sequence pilote 
    * Calcul des M × N symboles estimés an(k) 
    * Prise de décision

18. Recepteur simpliﬁé:
    * Quantiﬁcation sur 3 niveaux 
    * Synchronisation par observation des ﬂancs montants et descendants et comparaisonavec la sequence pilote 
    * Calcul des M × N symboles estimés an(k) 
    * Prise de décision

19. Calcul du taux d’erreur obtenu sur chaque canal fréquentiel.
        xor.m

20. Aﬃchage graphique des résultats.
        plot.m, grid, hold, zoom, axis.m, xlabel.m, ylabel.m, legend.m, title.m, gtext.m, stem.m, subplot.m