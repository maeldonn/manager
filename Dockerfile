FROM fedora
ARG TAGS
WORKDIR /usr/local/bin
RUN dnf update -y && dnf install -y git unzip zip make which dnf-plugins-core ansible neovim && dnf autoremove
COPY . .
CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]
