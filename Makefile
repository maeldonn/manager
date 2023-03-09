all:

install:
	@ansible-playbook -K --ask-vault-pass run.yml

test:
	@docker build . -t new-computer
	@docker run --rm -it new-computer bash
