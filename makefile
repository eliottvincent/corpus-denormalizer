# @Author: eliottvincent
# @Date:   2019-01-08T14:26:40+01:00
# @Email:  evincent@enssat.fr
# @Last modified by:   eliottvincent
# @Last modified time: 2019-01-08T14:51:27+01:00
# @License: MIT
# @Copyright: © 2018 Productmates. All rights reserved.

build:
	@docker build \
		--memory=6144m \
		--memory-swap=6144m \
		-t moses \
		.
run:
	@docker run \
		--name moses_1 \
		-d moses
bash:
	@docker exec -it moses_1 /bin/bash
logs:
	@docker logs moses_1 -f
clean:
	@docker stop moses_1
	@docker rm moses_1
reload:
	@make clean
	@make build
	@make run
	@make logs


prune:
	@docker system prune -a -f
