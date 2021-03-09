.PHONY: all build images deploy clean test manifests remove lint

export CC := gcc -std=gnu99 -Wno-error=implicit-function-declaration

lint: 
	golangci-lint run --enable=golint,bodyclose,gosec,whitespace --skip-files=".*_test.go"

all:    format lint build images deploy clean

test:
	        go test ./... -v *_test.go

format:
	        gofmt -w -s .

build:
	go build -ldflags "-s -w" -buildmode=pie -o build/_output/bin/intel-rmd-deviceplugin cmd/deviceplugin/main.go
	        go build -ldflags "-s -w" -buildmode=pie -o build/_output/bin/intel-rmd-node-agent cmd/nodeagent/main.go
		        go build -ldflags "-s -w" -buildmode=pie -o build/_output/bin/intel-rmd-operator cmd/manager/main.go

images:
	        docker build -t intel-rmd-node-agent -f build/nodeagent.Dockerfile .
		        docker build -t intel-rmd-operator -f build/Dockerfile .
				docker build -t intel-rmd-deviceplugin -f build/deviceplugin.Dockerfile . 

deploy:		
		kubectl apply -f deploy/rbac.yaml
			kubectl apply -f deploy/crds/intel.com_rmdnodestates_crd.yaml
				kubectl apply -f deploy/crds/intel.com_rmdworkloads_crd.yaml
					kubectl apply -f deploy/crds/intel.com_rmdconfigs_crd.yaml
						kubectl apply -f deploy/operator.yaml
							kubectl apply -f deploy/rmdconfig.yaml 
			

clean:
	        rm -rf ./build/_output/bin/*

remove:
		kubectl delete -f deploy/rmdconfig.yaml	
			kubectl delete -f deploy/operator.yaml
				kubectl delete -f deploy/crds/intel.com_rmdconfigs_crd.yaml
					kubectl delete -f deploy/crds/intel.com_rmdworkloads_crd.yaml
						kubectl delete -f deploy/crds/intel.com_rmdnodestates_crd.yaml
							kubectl delete -f deploy/rbac.yaml
