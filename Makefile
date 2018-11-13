SHELL=/bin/bash
LOCAL_REGISTRY=10.254.0.50:5000
NAME="pv-test"
TAG=v2
IMAGE=${LOCAL_REGISTRY}/${NAME}:${TAG}
IMAGE1=${IMAGE}
IMAGE2=${IMAGE}
NAMESPACE="default"
NAME1=${NAME}-without
NAME2=${NAME}-with
URL1=gmt.without.me
URL2=gmt.with.me
IMAGE_PULL_POLICY=Always
MANIFEST=./manifest
SCRIPT=./scripts
MOUNT_PATH=/home/pics
PVC_NAME=${NAME}-claim
FROM=/tmp/pics
TO=/home/pics

all: build push deploy

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

cp:
	@find ${MANIFEST} -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name1}}"?"${NAME1}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name2}}"?"${NAME2}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image1}}"?"${IMAGE1}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image2}}"?"${IMAGE2}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.url1}}"?"${URL1}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.url2}}"?"${URL2}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.mount.path}}"?"${MOUNT_PATH}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.pvc.name}}"?"${PVC_NAME}"?g

deploy: export OP=create
deploy: cp sed
	@kubectl ${OP} -f ${MANIFEST}/pvc.yaml
	@kubectl ${OP} -f ${MANIFEST}/statefulset.yaml
	@kubectl ${OP} -f ${MANIFEST}/deployment.yaml
	@kubectl ${OP} -f ${MANIFEST}/service.yaml
	@kubectl ${OP} -f ${MANIFEST}/ingress.yaml

clean: export OP=delete
clean:
	-@kubectl ${OP} -f ${MANIFEST}/statefulset.yaml
	@kubectl ${OP} -f ${MANIFEST}/deployment.yaml
	-@kubectl ${OP} -f ${MANIFEST}/pvc.yaml
	-@kubectl ${OP} -f ${MANIFEST}/service.yaml
	-@kubectl ${OP} -f ${MANIFEST}/ingress.yaml
	-@rm -f ${MANIFEST}/service.yaml
	-@rm -f ${MANIFEST}/ingress.yaml
	-@rm -f ${MANIFEST}/statefulset.yaml
	-@rm -f ${MANIFEST}/pvc.yaml
	-@rm -f ${MANIFEST}/deployment.yaml

mv:
	@${SCRIPT}/mv-file-for-statefulset.sh -p ${NAME2}-0 -s ${NAMESPACE} -f ${FROM} -t ${TO} -c

test:
	@kubectl -n ${NAMESPACE} exec -it ${NAME}-0 -- ls ${TO}

check:
	@kubectl -n ${NAMESPACE} exec -it ${NAME}-0 -- ls ${FROM}
