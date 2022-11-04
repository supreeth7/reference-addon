FROM registry.ci.openshift.org/openshift/release:golang-1.18 AS builder

WORKDIR /workspace

# prevents flakes with 'go mod tidy'
USER root

# main cache optimization
COPY go.mod .
COPY go.sum .
RUN go mod download

# tools cache optimization
COPY tools/ tools/
RUN cd tools && go mod download

# build manager binary
COPY . .
RUN ./mage build:manager

USER default

FROM registry.access.redhat.com/ubi8-micro:latest

COPY --from=builder /workspace/bin/linux_amd64/reference-addon-manager .

USER 65532:65532

ENTRYPOINT [ "/reference-addon-manager" ]
