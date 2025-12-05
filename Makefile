.PHONY: help setup test test-unit test-integration test-e2e test-coverage deploy stop restart status logs backup restore update clean

PYTHON := python3
VENV := .venv
QUADLET_DIR := $(HOME)/.config/containers/systemd
SERVICE ?= all

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

setup: ## Initial setup - create venv, install deps, create directories
	@echo "🔧 Setting up project..."
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements-dev.txt
	mkdir -p configs/{homeassistant,frigate,mosquitto,zigbee2mqtt,nginx-proxy,adguard}
	mkdir -p data/{homeassistant,frigate,mosquitto,zigbee2mqtt,nginx-proxy,adguard}
	mkdir -p data/media/frigate
	mkdir -p backups
	@echo "✅ Setup complete!"

test: ## Run all tests
	@echo "🧪 Running all tests..."
	$(VENV)/bin/pytest tests/ -v

test-unit: ## Run unit tests only
	@echo "🧪 Running unit tests..."
	$(VENV)/bin/pytest tests/unit/ -v

test-integration: ## Run integration tests only
	@echo "🧪 Running integration tests..."
	$(VENV)/bin/pytest tests/integration/ -v

test-e2e: ## Run end-to-end tests only
	@echo "🧪 Running end-to-end tests..."
	$(VENV)/bin/pytest tests/e2e/ -v

test-coverage: ## Run tests with coverage report
	@echo "🧪 Running tests with coverage..."
	$(VENV)/bin/pytest tests/ --cov=. --cov-report=html --cov-report=term

deploy: ## Deploy all quadlets to systemd
	@echo "🚀 Deploying quadlets..."
	./scripts/deploy.sh
	@echo "✅ Deployment complete!"

stop: ## Stop all services
	@echo "🛑 Stopping services..."
	./scripts/stop.sh
	@echo "✅ Services stopped!"

restart: ## Restart services
	@echo "🔄 Restarting services..."
	./scripts/restart.sh $(SERVICE)
	@echo "✅ Services restarted!"

status: ## Check status of all services
	@echo "📊 Service Status:"
	@systemctl --user list-units 'homeserver-*' --all

logs: ## View logs for a service (use SERVICE=name)
	@if [ "$(SERVICE)" = "all" ]; then \
		journalctl --user -u 'homeserver-*' -f; \
	else \
		journalctl --user -u homeserver-$(SERVICE) -f; \
	fi

backup: ## Create backup of all configs and data
	@echo "💾 Creating backup..."
	./scripts/backup.sh
	@echo "✅ Backup complete!"

restore: ## Restore from backup (use BACKUP_FILE=path)
	@echo "📥 Restoring from backup..."
	./scripts/restore.sh $(BACKUP_FILE)
	@echo "✅ Restore complete!"

update: ## Update all container images
	@echo "⬆️  Updating containers..."
	./scripts/update.sh
	@echo "✅ Update complete!"

validate: ## Validate quadlet files
	@echo "✅ Validating quadlet files..."
	$(VENV)/bin/python scripts/validate_quadlets.py

clean: ## Clean up generated files and containers
	@echo "🧹 Cleaning up..."
	rm -rf $(VENV)
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Cleanup complete!"

init-configs: ## Initialize default configuration files
	@echo "📝 Initializing configurations..."
	$(VENV)/bin/python scripts/init_configs.py
	@echo "✅ Configurations initialized!"


