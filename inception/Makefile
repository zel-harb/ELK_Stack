COMPOSE_FILE	= ./srcs/docker-compose.yml

DATA_DIR		= /home/zel-harb/data
WP_DATA_DIR		= $(DATA_DIR)/wordpress
DB_DATA_DIR		= $(DATA_DIR)/mariadb

GREEN			= \033[0;32m
RED				= \033[0;31m
YELLOW			= \033[0;33m
BLUE			= \033[0;34m
RESET			= \033[0m


all: create-dirs build up 
	@echo "$(GREEN)✓ Inception is running!$(RESET)"

build: create-dirs
	@docker compose -f $(COMPOSE_FILE) build

up: create-dirs	
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@docker compose -f $(COMPOSE_FILE) down



clean: down	
	@docker compose -f $(COMPOSE_FILE) down -v

fclean: clean remove-dirs
	@if [ -n "$$(docker images -q)" ]; then \
		docker rmi -f $$(docker images -q);\
	fi

re: fclean all	


create-dirs:
	@if [ ! -d "$(WP_DATA_DIR)" ]; then \
		mkdir -p $(WP_DATA_DIR); \
	fi
	@if [ ! -d "$(DB_DATA_DIR)" ]; then \
		mkdir -p $(DB_DATA_DIR); \
	fi

remove-dirs:					
	@echo "$(RED)Removing data directories...$(RESET)"
	@if [ -d "$(WP_DATA_DIR)" ]; then \
		sudo rm -rf $(WP_DATA_DIR); \
	fi
	@if [ -d "$(DB_DATA_DIR)" ]; then \
		sudo rm -rf $(DB_DATA_DIR); \
	fi


logs:
	@docker compose -f $(COMPOSE_FILE) logs

ps:								
	@docker compose -f $(COMPOSE_FILE) ps

.PHONY: all build up down clean fclean re \
		logs ps create-dirs remove-dirs