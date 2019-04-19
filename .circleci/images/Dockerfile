FROM circleci/golang:1.12.4
RUN sudo apt-get install python-pip
RUN sudo pip install -q pre-commit
RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip \
        && sudo unzip terraform.zip -d /usr/local/bin \
        && rm terraform.zip
RUN go get golang.org/x/lint/golint github.com/segmentio/terraform-docs
