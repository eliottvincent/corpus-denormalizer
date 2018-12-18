corpus-denormalizer

# Docker
## Build image
    docker build --memory=6144m --memory-swap=6144m -t moses .
## Run image
    docker run --name moses_1 -d moses
## Launch Moses
    docker exec -it moses_1 /bin/bash
