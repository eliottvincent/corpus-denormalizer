corpus-denormalizer

# Configuration
Avant de commencer, il faut modifier la variable HOST_HOME_PATH dans le fichier *makefile* pour indiquer le chemin vers le dossier du projet. Ensuite, toutes les actions de build/run/reload du container sont gérées par le makefile.

Pour les machines utilisant un système Windows, il faut installer *nmake* afin de pouvoir utiliser le makefile.

Il est également possible de modifier le nombre de CPU et de mémoire vive utilisé via les variables CPUS et MEMORY présentes dans le *makefile*. Cependant, les valeurs par défaut représentent un minimum afin d'avoir une performance "acceptable" et éviter les erreurs d'exécution.

# Docker
## Build image
    make build
## Run image
    make run
## Reload (after changes)
    make reload
