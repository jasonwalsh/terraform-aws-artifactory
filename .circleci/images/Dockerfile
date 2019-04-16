FROM circleci/golang:1.12.4
RUN sudo apt-get install python-pip
RUN sudo pip install -q pre-commit
RUN go get golang.org/x/lint/golint github.com/segmentio/terraform-docs
