.ONESHELL:

# Définition de variables pour la réutilisabilité
PROJECT_NAME=scribshark
PYTHON=python3
DJANGO_DIR=app
MANAGE_PY=cd $(DJANGO_DIR) && $(PYTHON) manage.py
SRC=cd $(DJANGO_DIR)

env:
	@echo "Activating virtual environment..."
	. venv/bin/activate

makemigrations:
	$(MANAGE_PY) makemigrations

migrate: makemigrations
	$(MANAGE_PY) migrate

init_local: env
	pip install -r $(DJANGO_DIR)/requirements/local.txt
	docker compose up -d
	sleep 10
	$(MANAGE_PY) migrate
	$(MANAGE_PY) runserver

run:
	$(MANAGE_PY) runserver

# _______________________ APP COMMANDS _______________________ #
# Créer une application Django
createapp:
	@echo "Entrez le nom de l'application que vous souhaitez créer : "
	@read app
	@echo "Dans quel dossier souhaitez-vous créer l'application ?"
	@read folder
	@echo "Création de l'application $$app ..."
	$(MANAGE_PY) startapp $$app

deleteapp:
	@echo "Entrez le nom de l'application que vous souhaitez supprimer : "
	@read app
	@echo "Suppression de l'application $$app ..."
	rm -rf $(DJANGO_DIR)/$$app

createapi:
	@echo "Entrez le nom de l'application ou vous souhaitez créer l'api : "
	@read app
	@echo "Entrez le nom de l'api que vous souhaitez créer : "
	@read api
	@echo "Création de l'api $$api dans l'application $$app..."
	$(SRC) / $$app
	mkdir -p $$app/api
	touch $$app/api/__init__.py
	touch $$app/api/urls.py
	touch $$app/api/views.py
	touch $$app/api/serializers.py
	touch $$app/api/tests.py
	echo "from django.urls import path" >> $$app/api/urls.py
	echo "from . import views" >> $$app/api/urls.py
	echo "urlpatterns = [" >> $$app/api/urls.py
	echo "    # path('url', views.view, name='name')," >> $$app/api/urls.py
	echo "]" >> $$app/api/urls.py
	echo "from rest_framework import serializers" >> $$app/api/serializers.py
	echo "from rest_framework import viewsets" >> $$app/api/views.py
	echo "from .models import Model" >> $$app/api/views.py
	



# Commande pour nettoyer les fichiers bytecode Python
clean:
	@echo "Nettoyage des fichiers .pyc et des dossiers __pycache__..."
	@find . -type f -name "*.pyc" -exec rm -f {} \;
	@find . -type d -name "__pycache__" -exec rm -rf {} \;
	@echo "Nettoyage des fichiers .pyc et des dossiers __pycache__ terminé."

# Commande pour voir ce Makefile comme aide
help:
	@echo "Makefile pour gérer le projet $(PROJECT_NAME) dans le dossier $(DJANGO_DIR)"
	@echo "Les commandes disponibles sont:"
	@grep '^[^#[:space:]].*:' Makefile