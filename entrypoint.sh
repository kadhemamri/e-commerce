#!/bin/sh

# Attendre que la base de données soit disponible
echo "Waiting for database connection..."
while ! nc -z db 3306; do
  sleep 1
done

# Générer la clé de l'application
php artisan key:generate

# Migrer la base de données
php artisan migrate --force

# Démarrer le serveur Laravel
php artisan serve --host=0.0.0.0 --port=9000
