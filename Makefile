OWNER := fabianlee
PROJECT := tiny-tools-with-swaks
VERSION := 3.12
OPV := $(OWNER)/$(PROJECT):$(VERSION)

# you may need to change to "sudo docker" if not a member of 'docker' group
# add user to docker group: sudo usermod -aG docker $USER
DOCKERCMD := "docker"

BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
# unique id from last git commit
MY_GITREF := $(shell git rev-parse --short HEAD)


## builds docker image
docker-build:
	@echo MY_GITREF is $(MY_GITREF)
	$(DOCKERCMD) build -f Dockerfile -t $(OPV) .

## cleans docker image
clean:
	$(DOCKERCMD) image rm $(OPV) | true

## runs container in foreground, testing a couple of override values
docker-run-fg: docker-ntp-port-clear
	$(DOCKERCMD) run -it --rm $(OPV)

## runs container in foreground, override entrypoint to use use shell
docker-debug:
	$(DOCKERCMD) run -it --rm --entrypoint "/bin/sh" $(OPV)

## run container in background, override /etc/chrony/chrony.conf using volume (not mandatory)
docker-run-bg: docker-ntp-port-clear
	$(DOCKERCMD) run -d --network host $(CAPS) -p $(EXPOSEDPORT) $(VOL_FLAG) --rm --name $(PROJECT) $(OPV)

## get into console of container running in background
docker-cli-bg:
	$(DOCKERCMD) exec -it $(PROJECT) /bin/sh

## tails $(DOCKERCMD)logs
docker-logs:
	$(DOCKERCMD) logs -f $(PROJECT)

## stops container running in background
docker-stop:
	$(DOCKERCMD) stop $(PROJECT)

## pushes to $(DOCKERCMD)hub
docker-push:
	$(DOCKERCMD) push $(OPV)

test:
	./chrony_test.sh

## pushes to kubernetes cluster
k8s-apply:
	cat k8s-tiny-tools-with-swaks.yaml | kubectl apply -f -
	@echo ""
	@echo "tiny-tools-with-swaks pod created in default ns has swaks utility"

k8s-delete:
	kubectl delete -f k8s-tiny-tools-with-swaks.yaml

