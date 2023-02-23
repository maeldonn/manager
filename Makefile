all:

install:
	@ansible-playbook run.yml

test:
	@docker build . -t new-computer
	@docker run --rm -it new-computer bash
