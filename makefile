# @Author: eliottvincent
# @Date:   2019-01-08T14:26:40+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-30T12:32:14+01:00
# @License: MIT
# @Copyright: © 2019 ENSSAT. All rights reserved.

HOST_HOME_PATH=C:\Users\bawi-\Desktop\Projet_IA\corpus-denormalizer-master\\
# HOST_HOME_PATH=/Users/eliottvincent/Desktop/
DOCKER_HOME_PATH=/home
CPUS="7"
MEMORY="12288m"

build:
	@docker build \
		--memory=6144m \
		--memory-swap=6144m \
		-t moses \
		.
run:
	@docker run \
		--name moses_1 \
		-v $(HOST_HOME_PATH)training:$(DOCKER_HOME_PATH)/training \
		--cpus=$(CPUS) \
		--memory=$(MEMORY) \
		-d moses
bash:
	@docker exec -it moses_1 /bin/bash
logs:
	@docker logs moses_1 -f
copy-logs:
	@docker logs moses_1 > moses.log 2>&1
clean:
	@docker stop moses_1
	@docker rm moses_1
reload:
	@make clean
	@make build
	@make run
	@make logs
reload-win:
	@nmake clean
	@nmake build
	@nmake run
	@nmake logs


prune:
	@docker system prune -a -f
