<div align="center">

# Laravel Auto Deploy

Deploy Laravel Application to Server via SSH by RSync

## Default Artisan Commands
```
php artisan cache:clear
php artisan config:clear 
php artisan route:clear 
php artisan view:clear 
php artisan config:cache 
php artisan route:cache 
php artisan view:cache 
composer dump-autoload
```
All commands above are executed in the default order.

## Custom Artisan Commands
 Custom commands can be executed after default artisan command. Custom commands could be added in the `.github/workflows/deploy.yml` file.


## Config example:

.github/workflows/deploy.yml

```
name: Deploy to production
on:
  push:
    branches: [ "develop" ]

jobs:
  build:
    name: Buid & Deploy
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@master
      - name: Setup Environment
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
      - name: Install Composer Packages
        run: composer install --no-dev
      - name: Setup Node.js
        uses: actions/setup-node@v2-beta
        with:
          node-version: '16'
          check-latest: true
      - name: Install NPM dependencies

        run: npm install

      - name: Compile assets for production

        run: npm run production

      - name: Deploy To production
        uses: hypertech-lda/laravel-auto-deploy@1.1
        with:
          user: ${{ secrets.SERVER_USER }}
          host: ${{ secrets.SERVER_HOST }}
          path: ${{ secrets.SERVER_PATH }}
          owner: www
          commands: "# Customer commands"
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}

```
