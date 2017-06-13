NAME:=dragoman
MAINPACKAGE:=github.com/autopilothq/${NAME}
REALPKGDIR:=${GOPATH}/src/${MAINPACKAGE}
EASYJSON:=${GOPATH}/bin/easyjson
GINKGO_OPTS=-keepGoing -r -randomizeAllSpecs -randomizeSuites
SRCDIRS:=$(shell ls -d */ | grep -v vendor/)

protocol:
	java -Xmx500M org.antlr.v4.Tool -Dlanguage=Go -visitor -listener ./parser/Convey.g4


#
# Linting
#
lint: protocol
	gometalinter.v1 --disable-all \
		-E gofmt -E vetshadow -E dupl -E goconst \
		--tests \
		--vendor --skip="protocol" --deadline=10m  ./...
	go list ./... | grep -v /vendor/ | xargs -L1 golint

#
# Vetting
# lostcancel is disabled as it seems to trigger some false
# positives in Ginkgo tests. lostcancel is:
#   check for failure to call cancelation function returned by context.WithCancel
#
vet: protocol
	cd "${REALPKGDIR}" && go tool vet -lostcancel=false ${SRCDIRS}



#
# Testing
#
test: ensure_test_env glide.lock protocol vet
	cd "${REALPKGDIR}" && ginkgo ${GINKGO_OPTS} -noisyPendings=false -race ${SRCDIRS}

#
# Test environment dependencies
#
ensure_test_env:
	go get \
		github.com/fzipp/gocyclo \
		github.com/onsi/ginkgo/ginkgo/... \
		github.com/onsi/ginkgo/extensions/table \
		github.com/onsi/gomega

update_test_env:
	go get -u \
		github.com/fzipp/gocyclo \
		github.com/onsi/ginkgo/ginkgo/... \
		github.com/onsi/ginkgo/extensions/table \
		github.com/onsi/gomega


#
# Test environment dependencies
#
ensure_test_env:
	go get \
		github.com/fzipp/gocyclo \
		github.com/onsi/ginkgo/ginkgo/... \
		github.com/onsi/ginkgo/extensions/table \
		github.com/onsi/gomega

update_test_env:
	go get -u \
		github.com/fzipp/gocyclo \
		github.com/onsi/ginkgo/ginkgo/... \
		github.com/onsi/ginkgo/extensions/table \
		github.com/onsi/gomega


#
# Vendor dependencies
#
glide.lock:
	cd "${REALPKGDIR}" && glide --quiet install




#
# Cleaning
#
clean:
	go clean -i



.PHONY: protocol lint vet test ensure_test_env update_test_env
.SUBLIME_TARGETS: test
