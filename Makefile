all:
	@echo ' __  __    _    _   _    _    ____ _____ ____  '
	@echo '|  \/  |  / \  | \ | |  / \  / ___| ____|  _ \ '
	@echo '| |\/| | / _ \ |  \| | / _ \| |  _|  _| | |_) |'
	@echo '| |  | |/ ___ \| |\  |/ ___ \ |_| | |___|  _ < '
	@echo '|_|  |_/_/   \_\_| \_/_/   \_\____|_____|_| \_\'
	@echo ''
	@echo 'options:'
	@echo '    - init:    Install requirements'
	@echo '    - install: Start configuration'
	@echo '    - test:    Test configuration'

init:
	@sudo dnf install ansible

install:
	@ansible-playbook -K --ask-vault-pass run.yml

test:
	@docker build . -t new-computer
	@docker run --rm -it new-computer bash
