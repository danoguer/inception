NAME = inception

SRCS = ./srcs/docker-compose.yml
DATA_PATH = /home/danoguer/data_bonus

GREEN = \033[0;32m
RED = \033[0;31m
RESET = \033[0m

all: up

up:
	@echo "$(GREEN)Building and starting containers...$(RESET)"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@docker compose -f $(SRCS) up -d --build

down:
	@echo "$(RED)Stopping containers...$(RESET)"
	@docker compose -f $(SRCS) down

clean: down
	@echo "$(RED)Cleaning Docker system...$(RESET)"
	@docker system prune -af

fclean: clean
	@echo "$(RED)Deep cleaning (removing data volumes)...$(RESET)"
	@rm -rf $(DATA_PATH)/mariadb/*
	@rm -rf $(DATA_PATH)/wordpress/*
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

.PHONY: all up down clean fclean re