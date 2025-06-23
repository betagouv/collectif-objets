# Mettre à jour les photos

```
# Installer python 3.9.x (dernière version compatible avec POP-scraper)
brew install python@3.9
brew install pipx
pipx ensurepath
pipx install poetry
source ~/$([ "$SHELL" = "/bin/zsh" ] && echo ".zshrc" || echo ".bashrc")

# Cloner POP-scraper
git clone git@github.com:betagouv/pop-scraper.git
cd pop-scraper

## Installer les dépendances de POP-scraper
poetry env use $(which python3.9)
poetry install

## Lancer le scraping
poetry run scrapy crawl pop_api -a base_pop=palissy # Dure entre 5 et 10 minutes
poetry run scrapy crawl pop_api -a base_pop=merimee # Dure entre 5 et 10 minutes

# Récupérer le code de collectif-objets-datasette
cd ..
git clone git@github.com:betagouv/collectif-objets-datasette.git
cd collectif-objets-datasette

## Installer ce deuxième projet
brew install python@3.11
poetry env use $(which python3.11)
poetry install --no-root

## Copier les données du scraping
cp -r ../collectif-objets-pop-scraper/tmp/ data_scrapped
find data_scrapped -type f -empty -delete

## Transformer les données
make prepare_sqlite

## Déployer les données sur fly.io
flyctl auth login
make deploy # Peut prendre plusieurs minutes
```
