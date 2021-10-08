# Commands for managing Arrowhead Core services installation.
#
# Usage: See make help

MYSQL_ROOT_PASSWORD=R2TuCgTRYMQH

ifeq ($(CURDIR:%/core-java-spring/docker=%),$(CURDIR))

# Execute the real targets in core-java-spring/docker directory
default $(filter-out help,$(MAKECMDGOALS)):
	@$(MAKE) -C core-java-spring/docker -f $(CURDIR)/Makefile TOPDIR=$(CURDIR) $(MAKECMDGOALS)

.PHONY: help
help:
	$(info $(help))
	@:

define help
Commands for managing Arrowhead Core Services installation.
Usage:
  make          # Initialize and start the services.
  make <target> # Run the target from this file.
                # Available targets: down, clean, mysql, etc.
endef


else

#####################################################
# Targets to be executed in core-java-spring/docker #
#####################################################

default: up

init_mysql:
	docker volume create --name=mysql
	sed -E -e "s|wget https://raw.githubusercontent.com/eclipse-arrowhead/core-java-spring/master/(.*)|cp '$(TOPDIR)/core-java-spring/\1' .|" initSQL.sh > initSQL-local.sh
	bash -x -e initSQL-local.sh
	cp ../scripts/timemanager_privileges.sql sql/privileges
	sed -e 's/THIS_WILL_BE_YOUR_CONTAINERS_ROOT_PW/$(MYSQL_ROOT_PASSWORD)/' docker-compose-4-3-0-amd64.yml > docker-compose.yml

up: init_mysql
	docker-compose up --build

down:
	docker-compose down

clean: down
	docker volume rm mysql

pull:
	docker-compose pull

# Run MySQL CLI client on the Arrowhead database
mysql:
	mysql --protocol=TCP --host=localhost --port=3306 --user=root --password=$(MYSQL_ROOT_PASSWORD) arrowhead

endif
