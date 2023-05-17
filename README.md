# Collectif Objets

![CI](https://github.com/adipasquale/collectif-objets/actions/workflows/ci.yml/badge.svg)

[![](https://img.shields.io/badge/Ouvrir%20avec-Gitpod-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/betagouv/collectif-objets/tree/feature/gitpod)

Collectif Objets est un site web permettant aux communes françaises de recenser leur patrimoine mobilier monument 
historiques et aux conservateurs d'analyser ces recensements.

{% note %}

**Note:** Ce README est volontairement un long fichier unique pour être découvrable facilement.

{% endnote %}

## Types d’usagers captures d'écran 

Le site expose trois interfaces pour trois types d'usagers différents, toutes accessibles depuis un 
site commun unique : https://collectif-objets.beta.gouv.fr

1. **Interface communes**
 
permet aux agents municipaux des communes de réaliser les recensements d'objets ;

| | |
| - | - |
| ![](doc/interface-communes1.webp) | ![](doc/interface-communes2.webp) |

2. **Interface conservateurs**

permet aux conservateurs d'analyser les recensements réalisés ;

| | |
| - | - |
| ![](doc/interface-conservateurs1.webp) | ![](doc/interface-conservateurs2.webp) |


3. **Interface administrateurs**

permet à l'équipe technique de faire le support

![](doc/interface-admin1.webp)


## Frameworks et dépendances

Les 3 interfaces sont servies par une seule et unique application Ruby On Rails 7.

Les gems principales dont dépend cette application Rails sont :

- `devise` : Authentification des usagers. Il y a trois modèles Devise `User` (Communes), `Conservateur` et `Admin`.
- `pundit` : droits et règles d'accès selon les profils
- `sidekiq` : Gestion des tâches asynchrones via Redis
- `vite_rails` : Compilation des assets JS et images
- `turbo_rails` : Interactions JS simplifiées
- `mjml-rails` : Templates de mails en MJML
- `AASM` : Machines à états finis pour les statuts des modèles
- `haml-rails`, `kramdown` et `view_component` pour les modèles de vues
- `ransack` : recherches et filtres dans l'admin principalement

Côté Javascript les principaux packages utilisés sont :

- `@gouvfr/dsfr` : Design Système de l'État Français
- `@rails/activestorage` : Gestion des uploads de photos
- `@hotwired/stimulus` : Simplifie le lien entre HTML et JS
- `maplibre-gl` : permet d'afficher une carte des objets en France
- `frappe-charts` : diagrammes SVG
- `spotlight.js` : galeries de photos d'objets

## Infrastructure, environnements, écosystème et services externes

![](doc/infrastructure.drawio.svg)

*Schéma d’infrastructure simplifié* · [éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Finfrastructure-simple.drawio.svg)

3 environnements :

- production : [collectif-objets.beta.gouv.fr](https://collectif-objets.beta.gouv.fr/)
- staging : [staging.collectifobjets.org](https://staging.collectifobjets.org/) - aussi appelé recette ou 
  bac à sable - Il n'y a pas de données sensibles sur cette base de données et elle peut être réinitialisée à tout moment. 
- local : [localhost:3000](http://localhost:3000) - héberge le site et [localhost:8025](http://localhost:8025) héberge
  MailHog pour voir les emails simulés
  
Outils & services externes

- [Metabase](https://metabase.collectifobjets.org) - Stats et visualisations
- [Dashboard Scalingo](https://dashboard.scalingo.com/)
- [Sentry de beta.gouv.fr](https://sentry.incubateur.net)
- [SendinBlue](https://my.sendinblue.com/) - Campagnes et mails transactionnel
- [Scaleway - buckets S3](https://console.scaleway.com/)
- [Webmail Gandi](https://webmail.gandi.net) - pour les mails en collectifobjets.org
- [Netlify CMS](https://collectif-objets-cms.netlify.app) - pour les fiches et les articles de presse

## Style du code, principes suivis et choix faits

_Tout ce qui est décrit ci-dessous est évidemment discutable et peut évoluer librement._

Les objectifs principaux de ce code sont :

- permettre d’itérer rapidement ;
- requérir peu de maintenance ;
- être facilement compréhensible, corrigeable et modifiable par d’autres développeur·se·s Rails.

Les commentaires dans le code sont à limiter au minimum, on préfère refactorer le code pour qu’il soit plus clair.

Les controlleurs sont légers.
Les modèles contiennent la logique métier. Il y a des modèles ActiveRecord et d’autres PORO.
On utilise les concerns pour isoler des comportements de modèles. cf [doctrine 37signals](https://dev.37signals.com/vanilla-rails-is-plenty). 
Cela peut évidemment évoluer.

La couverture des tests est modérée. 
Il y a des tests E2E pour les chemins les plus importants, principalement pour les cas de succès.
Il y a des tests unitaires pour les modèles quand cela semble nécessaire ou que ça aide l’écriture du code.
Il n’y a pas de tests de controlleurs, on favorisera les tests E2E ou pas de tests.
Il n’y a pas de tests pour les fonctionnalités natives de Rails ni ActiveRecord.
Les appels ActiveRecord ne sont pas mockés, ils font partie de ce qui est couvert par les tests.  

L’ajout de dépendances se fait avec parcimonie, les dépendances transitives sont étudiées à chaque fois.
Cela vaut pour les services tiers, les gems, et les packages JS.

L’introduction de comportements JS custom hors DSFR et Turbo est faite avec parcimonie.
Le site peut en grande partie fonctionner sans JS.
De nombreux usagers sont peu à l’aise avec le numérique, le site doit être aussi standard et sans surprise que possible.
Le site n’est pour l’instant pas tout à fait responsive, c’est une erreur à corriger.

Les règles rubocop basées uniquement sur la longueur des méthodes ou des classes sont volontairement désactivées.
En général il ne faut pas hésiter à désactiver les règles rubocop si on juge qu’elles n’aident pas.

Avec le recul, certains choix méritent d’être revus :

- Le modèle Dossier est peut-être superflu. On pourrait utiliser uniquement le modèle Commune. Aujourd’hui il y a un lien 1:1 dans beaucoup de cas entre ces deux modèles. Il avait été pensé pour permettre à une commune d’ouvrir plusieurs dossiers de recensement mais ce n’est pas le cas aujourd’hui. En année n+5, il est probable qu’on aura déjà supprimé le dossier précédent de notre base de données pour des raisons RGPD.
- Netlify CMS pour le contenu peut être remplacé par des contenus stockés en DB et édités via des textarea ActionText / Trix.
- Sidekiq peut être remplacé par GoodJob pour supprimer la dépendance à Redis et simplifier les [CRON-like jobs](https://github.com/bensheldon/good_job#cron-style-repeatingrecurring-jobs).
- Le choix de vite pour le build JS est peut–être trop exotique. Il faudrait réévaluer l’usage des importmaps pour éviter tout build system.
- L’utilisation de I18n est à proscrire, ce projet n’a aucune vocation internationale, et l’isolation des contenus dans les fichiers yml ralentit plus qu’elle n’aide. (seule utilité à remplacer : la pluralisation).
- Le mélange de français et d’anglais dans le code et la DB est désagréable. Il faudrait harmoniser les choix, mais la direction à suivre n’est pas encore claire.

## Diagramme d'entités de la base de données

![](doc/erd-simple.drawio.svg)

*Diagramme d'entités simplifié de la base de données* · 
[éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Ferd-simple.drawio.svg)

- Les `User` sont les comptes usagers des communes. C'est un modèle Devise. Un `User` a accès à une et une seule 
  commune.
- Les `Conservateurs` sont les comptes usagers des conservateurs. C'est aussi un modèle Devise. 
  Un Conservateur a accès à un ou plusieurs départements et toutes les communes inclues.
- Les `Édifices` sont les lieux abritant les objets. Une partie sont des monuments historiques avec des références 
  vers la base Mérimée.
- Les `Objets` sont les objets monuments historiques. Leurs infos proviennent de Palissy. 
  Leur identifiant unique provient de POP et s'appelle dans notre base `palissy_REF`, il ressemble à `PM00023944`.
- Un `Recensement` contient les observations sur l'état d'un `Objet` et les photos associées à la visite du `User`.
- Un `Dossier` est un ensemble de `Recensements` pour une commune. 
  Il doit être finalisé par la commune pour être analysable par les conservateurs.
- Une `Campagne` contient les dates et les communes à démarcher pour une campagne mail avec plusieurs relances. 
  Elle est gérée et visible uniquement par les administrateurs.

La version complète du diagramme d'entités de la base de données est visible ici 
[doc/entity-relationship-diagram.svg](doc/entity-relationship-diagram.svg)

## Machines à états finis

| Communes | Dossiers | Campaigns |
| - | - | - |
| ![](doc/commune_state_machine_diagram.png) | ![](doc/dossier_state_machine_diagram.png) | ![](doc/campaign_state_machine_diagram.png) |

- Un `Dossier` est d'abord en construction, puis est soumis aux conservateurs et enfin accepté ou rejeté.
- L'état d'une `Commune` est lié à l'état de son `Dossier`. 
  La commune passe en recensement démarré lorsque le dossier est en construction, puis en recensement complété lorsque 
  le dossier est soumis.

`bundle exec rake diagrams:generate` permet de mettre à jour ces diagrammes

Voici le schéma du cycle de vie d'un dossier.

![cycle de vie dossier drawio](doc/cycle-vie-dossier.drawio.svg)

[éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Fcycle-vie-dossier.drawio.svg)

## Installation

### Gitpod

Gitpod est un environnement de développement en ligne.
Toutes les dépendances sont installées et préconfigurées.
En un clic et quelques minutes d’attente, VSCode s’ouvrira avec le serveur web lancé, vite-dev, mailhog, redis etc…

[![Ouvrir dans Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/betagouv/collectif-objets)

### Installation via Docker

```
docker compose up
# CTRL-C to break

docker compose run web rails db:setup
```

### Installation en local via rbenv et bundle

- installer manuellement [`rbenv`](https://github.com/rbenv/rbenv#installation)

```sh
rbenv install `cat .ruby-version`
make install
make dev
```

optionnel: pour une utilisation de rubocop plus rapide en local, 
[voir le mode serveur](https://docs.rubocop.org/rubocop/usage/server.html)

## Premiers pas - Découverte du produit

Durée à prévoir : 15 minutes 

**Découverte interface administrateurs**

- [ ] aller sur [localhost:3000/admin](http://localhost:3000/admin)
- [ ] se connecter avec le compte de seed `admin@collectif.local` mot de passe `123456`
- [ ] trouver un lien de connexion magique à une commune dans la Marne 51 et le suivre

**Découverte interface communes**

- [ ] se connecter depuis un lien magique depuis l'admin (pour info, dans les seeds, le code du lien magique est le code INSEE)
- [ ] recenser un objet en uploadant une photo
- [ ] recenser tous les objets d'une commune et finaliser un dossier

**Découverte interface conservateurs**

- [ ] se déconnecter en tant que commune
- [ ] se connecter en tant que conservateur depuis le lien de connexion sur le site avec le compte suivant : `conservateur@collectif.local` mot de passe `123456789 123456789 123456789`
- [ ] ouvrir un dossier de recensement à analyser
- [ ] analyser un recensement
- [ ] analyser tous les recensements d'un dossier et l'accepter
- [ ] lire le mail envoyé depuis MailHog sur [localhost:8025](http://localhost:8025)

## Configurations DNS, boites mails, et serveurs mails

La configuration des domaines en `.beta.gouv.fr` est gérée par l'équipe transverse de beta.gouv.fr, 
idem pour les domaines en `.incubateur.net`

L'adresse `collectifobjets@beta.gouv.fr` est une liste de diffusion beta.gouv.fr, elle se gère depuis le mattermost 
de beta cf https://doc.incubateur.net/communaute/travailler-a-beta-gouv/jutilise-les-outils-de-la-communaute/outils/liste-de-diffusion-et-adresses-de-contact#la-commande-mattermost-emails

L'adresse `support@collectif-objets.beta.gouv.fr` est gérée en délégation de service par l'incubateur du ministère de 
  la Culture (référent : Ned Baldessin). Idem pour tout le sous-domaine `collectif-objets.beta.gouv.fr`

Le domaine `collectifobjets.org`, le sous domaine de redirection des emails de réponse, et les adresses mails associées
  de l'équipe sont gérées par Adrien et son compte Gandi.

## Dumps des bases de données

```sh
# Dans un terminal
scalingo --app collectif-objets-staging db-tunnel SCALINGO_POSTGRESQL_URL

# Dans un second terminal
./scripts/pg_dump_data_anonymous.sh postgres://collectif_o_9999:XXXXX@localhost:10000/collectif_o_9999 tmp/dump.pgsql

# Le dump peut alors être importé en local
rails db:drop db:create db:schema:load
rails runner scripts/create_postgres_sequences_memoire_photos_numbers.rb
pg_restore --data-only --no-owner --no-privileges --no-comments --dbname=collectif_objets_dev tmp/dump.pgsql
```

Pour mettre à jour le fichier `seeds.pgsql` pour les review apps : 

1. Créer et importer un dump de staging (voir section précédente)
2. lancer `rails runner scripts/reset_recensements_dossiers_communes.rb`
3. créer le dump de seeds via `./scripts/pg_dump_data_anonymous.sh collectif_objets_dev tmp/seeds.pgsql`
4. uploader `tmp/seeds.pgsql` sur le bucket S3 `collectif-objets-public`, par exemple avec Cyberduck

en local `rails db:reset` : détruit puis recréé les bases locales, charge le schéma puis les seeds qui se téléchargent 
depuis le bucket S3 `collectif-objets-public`.

## Review apps

Les review apps ne sont pas activées automatiquement pour toutes les PRs car elles sont coûteuses en ressources et pas
utiles

```sh
  # Création :
  scalingo integration-link-manual-review-app --app collectif-objets-staging 701

  # Déploiement d’une nouvelle version de la branche
  # git push origin feature/etapes-recensement
  scalingo integration-link-manual-deploy --app collectif-objets-staging-pr701 feature/etapes-recensement && \
  scalingo --app collectif-objets-staging-pr701 deployment-follow

  # Réinitialisation de la base de données
  # on n’a pas les droits pour dropper la db ni l’app
  scalingo --app collectif-objets-staging-pr701 run bash
  rails runner scripts/truncate_all_tables.rb
  rails db:seed
```

Note: Pour faire fonctionner le direct-upload pour les photos sur une review vous devrez rajouter l’hôte de la review dans la liste des hosts autorisés en CORS sur le bucket S3 de staging, voir plus bas.

## Préparation d'une astreinte dev

Voici une liste à suivre pour préparer une astreinte sereine :

- [ ] demander un accès d'administrateur au projet Scalingo. Il faut un compte validé pour accéder à la région osc-secnum-fr1. Une adresse en beta.gouv.fr permet de l'avoir
- [ ] demander un accès contributeur au repository GitHub
- [ ] demander un accès aux projets sur sentry.incubateur.net
- [ ] vérifier que les notifications mail Sentry sont activées
- [ ] activer le 2FA sur GitHub et Sentry
- [ ] demander à être ajouté aux chaînes Mattermost `~projet-collectif_objets` et `~projet-collectif_objets-dev` dans l'espace AtNumCulture
- [ ] se présenter aux membres de l'équipe, déclarer les dates et horaires d'astreinte et les moyens de contact
- [ ] demander un compte admin en prod et en staging
- [ ] faire tourner le projet en local, [cf README/installation](https://github.com/betagouv/collectif-objets/#readme)
- [ ] récupérer la variable d'env RAILS_MASTER_KEY depuis l'app de prod scalingo (ou un membre de l'équipe) et la définir dans `config/master.key`
- [ ] faire un tour des principales fonctionnalités de l'appli en tant que commune et conservateur

Optionnel :

- [ ] demander un accès Scaleway
- [ ] demander les identifiants partagés Send In Blue de l'équipe

## Buckets S3 : ACLs et CORS

Les buckets de photos uploadés doivent être configurés pour le CORS

cf https://www.scaleway.com/en/docs/storage/object/api-cli/setting-cors-rules/

```sh
aws s3api put-bucket-cors --bucket collectif-objets-development2 --cors-configuration file://scripts/s3buckets/cors-development.json
aws s3api put-bucket-cors --bucket collectif-objets-staging2 --cors-configuration file://scripts/s3buckets/cors-staging.json
aws s3api put-bucket-cors --bucket collectif-objets-production --cors-configuration file://scripts/s3buckets/cors-production.json
```

Il y a deux buckets où tous les fichiers sont publics

- `collectif-objets-public` : contient le fichier seeds.pgsql pour les review apps ainsi que les vidéos des articles de presse
- `collectif-objets-photos-overrides` : contient des photos d'objets à utiliser préférentiellement par rapport à POP

Pour configurer l'accès public de ces buckets utilisez la commande suivante :

`aws s3api put-bucket-policy --bucket collectif-objets-photos-overrides --policy file://bucket-policy-objet-overrides.json`

Avec le fichier suivant

```json
{
  "Version": "2022-09-21",
  "Id": "collectifobjets",
  "Statement": [
    {
      "Sid": "Allow public access on all photos overrides",
      "Effect": "Allow",
      "Principal": {
        "SCW": "project_id:xxxx-xxxx-xxxx"
      },
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "collectif-objets-public",
        "collectif-objets-photos-overrides"
      ]
    }
  ]
}
```

## Données (Origine, Transformations, Republications)

![Schéma de transformation des données](doc/data-pipeline.drawio.svg)

*Schéma de transformation des données* · [éditer](https://app.diagrams.net/#Uhttps%3A%2F%2Fgithub.com%2Fbetagouv%2Fcollectif-objets%2Fraw%2Fmain%2Fdoc%2Finfrastructure-simple.drawio.svg)

Les données sur les communes (email de la mairie, numéro de téléphone etc…) proviennent
de [service-public.fr](https://www.service-public.fr/).
Nous utilisons [BaseAdresseNationale/annuaire-api](https://github.com/BaseAdresseNationale/annuaire-api), un outil qui 
récupère et parse les exports XML de service-public.fr.

Les données sur les objets monuments historiques sont celles de Palissy, la base patrimoniale hébergée sur la
[Plateforme Ouverte du Patrimoine (POP)](https://www.pop.culture.gouv.fr/).
L'export publié sur data.gouv.fr est trop partiel et peu fréquent pour les besoins de Collectif Objets.
Nous scrappons donc POP via [pop-scraper](https://github.com/adipasquale/pop-scraper).

Les données sur les conservateurs nous ont été transmises personnellement via un annuaire national en PDF.

Pour simplifier la réutilisation des données de service-public.fr et de POP, nous avons déployé une plateforme de 
données publique : [collectif-objets-datasette.fly.dev](https://collectif-objets-datasette.fly.dev) qui fournit une 
interface visuelle web avec des filtres, et une API JSON.
Le code est disponible [sur GitHub](https://github.com/adipasquale/collectif-objets-datasette) et utilise la librairie
[datasette](https://github.com/simonw/datasette/).

`rails runner Synchronizer::SynchronizeObjetsJob.perform_inline` importe les données depuis la 
collectif-objets-datasette.fly.dev vers la base de donnée locale de Collectif Objets.

La plupart des données stockées sur Collectif Objets sont publiques. Les exceptions sont :

- Les infos personnelles des conservateurs (email, numéro de téléphone)
- Les données de recensements. avant d'être validées et republiées sur POP, elles peuvent contenir des données à ne pas
  publier.

```mermaid
flowchart TD
  palissy[[pour chaque notice Palissy]]
  palissy -->code_insee_existe[une commune existe pour le code INSEE ?]
  code_insee_existe -.->|non| ne_pas_importer[Ne pas importer]
  code_insee_existe -->|oui| pm_existe[PM existe déjà ?]

  pm_existe -->|oui| changement_de_commune[Code INSEE a changé ?]
  pm_existe -.->|non| commune_ok[commune inactive \n ou dossier accepté ?]
  
  subgraph nouvel objet
  commune_ok -->|oui| import_nouvel_objet(Importer nouvel objet)
  commune_ok -.->|non| interactive1[Acceptation interactive manuelle ?]

  interactive1 -.->|non| ne_pas_importer_nouvel_objet(Ne pas importer \nle nouvel objet)
  interactive1 -->|oui| import_nouvel_objet
  end
  
  subgraph Mise à jour d'objet
  changement_de_commune -.->|non| mise_a_jour(Mise à jour de l'objet)
  changement_de_commune -->|oui| 2_communes_ok[Commune destinataire inactive ou dossier accepté \n+ commune d'origine inactive ?]
  
  2_communes_ok -->|oui| mise_a_jour_et_changement_commune(Changement de commune\net mise à jour de l'objet)
  2_communes_ok -.->|non| interactive2[Acceptation interactive manuelle ?]

  interactive2 -->|oui| mise_a_jour_et_changement_commune
  interactive2 -.->|non| mise_a_jour_prudente(Mise à jour des champs sûrs\npas de changement de commune)
  end

  style mise_a_jour fill:#006600
  style import_nouvel_objet fill:#006600
  style mise_a_jour_et_changement_commune fill:#006600
  style mise_a_jour_prudente fill:#003300
  style ne_pas_importer fill:#660000
  style ne_pas_importer_nouvel_objet fill:#660000
```

## Frontend : Vite, View Components, Stimulus

Les fichiers `.rb` des composants View Components sont dans `/app/components`.
Pour chaque composant, tous les fichiers liés (JS, CSS, preview) sont dans un dossier du même nom dans 
`/app/components`.

Par exemple un composant GalleryComponent pourra être composé les fichiers suivants: 

- `/app/components/gallery_component.rb`
- `/app/components/gallery_component/gallery_component.css`
- `/app/components/gallery_component/gallery_component_controller.js`
- `/app/components/gallery_component/gallery_component_preview.rb`

Le format du nom du fichier `gallery_component_controller.js` est important : il ne sera importé que s'il respecte ce format. 
Ce fichier doit exporter un controlleur Stimulus et est responsable d'importer le fichier CSS.
La classe de preview doit malheureusement être préfixée par le nom du composant, ici `GalleryComponent::GalleryComponentPreview`.
Cette configuration s'inspire partiellement de [view_component-contrib](https://github.com/palkan/view_component-contrib).

Des controlleurs Stimulus non liés à des composants existent dans : 

- `/app/frontend/stimulus_controllers` : importés par défaut dans l'entrypoint `application.js`
- `/app/frontend/stimulus_controllers_standalone` : doivent être importés dans des entrypoints spécifiques

## Intégration du Design Système de l'État Français (DSFR)

L'intégration du DSFR est faite par des liens symboliques définis dans `/public` qui pointent vers les assets 
précompilés du package node :

```
/public/dsfr/dsfr.min.css -> /node_modules/@gouvfr/dsfr/dist/dsfr.min.css
/public/dsfr/fonts -> /node_modules/@gouvfr/dsfr/dist/fonts/
/public/dsfr/icons -> /node_modules/@gouvfr/dsfr/dist/icons/
/public/dsfr/utility/utility.min.css -> /../node_modules/@gouvfr/dsfr/dist/utility/utility.min.css
```

Cela permet :
- de ne pas repasser inutilement par un compilateur d'assets (vite dans ce projet)
- de rester à jour avec le DSFR plus facilement en utilisant les upgrades de packages JS

En revanche ce n'est vraiment pas standard et risque de poser des soucis de maintenance.

C'est discuté ici : https://mattermost.incubateur.net/betagouv/pl/ehsuormqztnr3fz6ncuqt9f5ac

## Overrides de Photos Palissy

Les overrides de photos permettent d'intégrer des photos de bases locales non reversées dans POP.

### Préparer des overrides de photos en local 

- récupérer les photos et le lien avec la référence palissy depuis le département
- s'assurer que les noms de fichiers sont corrects et présents
- isoler les photos qui nous concernent
- les uploader sur S3 public
- lancer le script pour importer les ObjetsOverrides dans la db
- resynchroniser les objets

### Importer des overrides de photos en production

`scalingo --app collectif-objets-prod --region osc-secnum-fr1 run bash`

```sh
curl https://transfer.sh/url-du-fichier.csv > tmp.csv
rake objet_overrides:import[tmp.csv]
rails runner "SynchronizeObjetsJob.perform_inline('52')"
```

## Messagerie

La messagerie permet des échanges entre les usagers, les conservateurs et l'équipe support de Collectif Objets.
Les messages apparaissent dans l'interface de Collectif Objets et sont envoyés par email aux destinataires.
Les conservateurs et usagers peuvent répondre aux emails et les réponses apparaissent dans l'interface de 
Collectif Objets.

Pour récupérer ces emails, nous utilisons la fonctionnalité 
[Inbound Parsing Webhooks de Send In Blue](https://developers.sendinblue.com/docs/inbound-parse-webhooks).
Le script `scripts/create_sib_webhooks.sh` permet de gérer les webhooks actifs sur Send In Blue.
Il y a 3 webhooks actifs pour les 3 environnements (production, staging, local) :

```json
[{
  "description": "[STAGING] inbound emails webhook",
  "url": "https://staging.collectifobjets.org/api/v1/inbound_emails",
  "events": ["inboundEmailProcessed"],
  "domain": "reponse-staging.collectifobjets.org"
}, {
  "description": "[PROD] inbound emails webhook",
  "url": "https://collectif-objets.beta.gouv.fr/api/v1/inbound_emails",
  "events": ["inboundEmailProcessed"],
  "domain": "reponse.collectifobjets.org"
}, {
  "description": "Debug inbound email webhook tunneled to localhost",
  "url": "https://collectifobjets-mail-inbound.loophole.site",
  "events": ["inboundEmailProcessed"],
  "domain": "reponse-loophole.collectifobjets.org"
}]
```

Chacun des sous domaines `reponse(-[a-z]+)` de `collectifobjets.org` hébergé sur Gandi est configuré pour rediriger 
les emails entrants vers SIB.

Les emails entrants sont reçus sur des adresses signées (qui sont les reply-to des mails de notifications de nouveau 
message) qui permettent d'authentifier l'auteur du message :

- `mairie-30001-a1b2c3d4h5@reponse.collectifobjets.org` : réponse de l'usager de la commune 30001 dont le 
  `inbound_email_token` secret est `a1b2c3d4h5`.
- `mairie-30001-conservateur-a1b2c3d4h5@reponse.collectifobjets.org` : réponse du conservateur pour la même commune

Voir la partie sur les tunnels plus bas pour itérer en local sur ces webhooks.

## Accessibilité, Plan du site et Pages démos

La démarche d'accessibilité est de réaliser une couverture quasi exhaustive des pages de l'application par des tests 
automatisés, puis de faire réaliser des tests manuels dans un second temps. 
Actuellement (février 2023) nous sommes à environ 70% de couverture des pages par des tests automatisés.

Les tests automatisés sont réalisés avec [aXe](https://www.deque.com/axe/). 
Pour les pages publiques, les tests sont lancées de manière classique sur des pages avec des seeds générées à chaque 
test via FactoryBot.

Pour les pages privées accessibles uniquement aux communes et aux conservateurs, l'approche est différente. 
Pour chaque page privée, une version de "démo" est accessible publiquement sur une route parallèle, par exemple 
[`demos/communes/completion_new`](https://collectif-objets.beta.gouv.fr/demos/communes/completion_new). 
Ces pages de démo présentent des données de test générées à la volée par FactoryBot.
Elles simulent la connexion de la commune ou du conservateur. 
Des précautions sont prises pour ne pas générer de données en base de données en freezant tous les objets de seeds et en
limitant les clics sur les boutons d'actions.

Ce sont ces pages de démos qui sont testées automatiquement par aXe. 
Leur accessibilité publique comme des vraies pages permet aussi de présenter l'application plus facilement, ou bien de
faire tester l'accessibilité de ces pages à des intervenants externes ou à des outils en ligne.

## Netlify CMS

Netlify CMS est un headless CMS (c'est à dire un backend dissocié de l'application principale) qui permet de modifier
des contenus facilement par des personnes sans modifier le code directement.

Les particularités de ce CMS sont :

- de stocker les contenus dans des fichiers Markdown dans le dépôt Git du projet ;
- de créer des branches et des pull requests pour chaque modification de contenu 

Il n'y a donc pas de base de données supplémentaire à gérer ou de serveur d'API de contenu à maintenir, tous les 
contenus restent présents dans le dépôt Git.

Nous utilisons ce CMS pour permettre à l'équipe d'éditer les articles de presse, les fiches de conseil et les pages de documentation.

Le CMS est hébergé sur [Netlify](https://www.netlify.com/) et est accessible à l'adresse 
[collectif-objets-cms.netlify.app](https://collectif-objets-cms.netlify.app).

Le projet Netlify est configuré pour déployer le répertoire `/cms` à la racine de ce dépôt Git courant. 
Le fichier `/cms/config.yml` configure Netlify CMS pour notre cas.
Nous utilisons Netlify Identity pour authentifier les accès au CMS, et un user github robot pour réaliser les commits 
et les PRs émanant de Netlify CMS.
Cette configuration est décrite sur [ce pad](https://pad.incubateur.net/zdhV1dI-RBivCfmwXq-hVw#).

⚠️ Après modification de `/cms/config.yml` il faut réactiver les builds sur Netlify. 
Ils sont désactivés en temps normal puisque ce fichier est très rarement modifié.

Si l’erreur `Git Gateway Error: Please ask your site administrator to reissue the Git Gateway token` apparaît, il faut 
- renouveller le token du user GitHub robot@collectifobjets.org depuis [sur cette page GitHub](https://github.com/settings/tokens) (Settings > Developer settings > Personal Access Tokens (classic)) avec le droit `repo` uniquement
- copiez le sur [la configuration Netlify Identity](https://app.netlify.com/sites/collectif-objets-cms/settings/identity) dans Git Gateway

## Rajouter une vidéo sur le site

Commencez par télécharger la vidéo au format MP4.
Pour les vidéos Loom il faut avoir un compte, mais pas nécessairement celui du créateur de la vidéo.

Prenez une capture d’écran d’un moment clé de la vidéo à utiliser comme poster.
Convertissez la en WEBP avec `convert titre.png titre.webm` ou bien utilisez imageoptim pour compresser le PNG.

Renommez les fichiers MP4 et PNG/WEBM au format suivant `2023_05_titre_video.mp4`.

Puis convertissez en local la vidéo au format WEBM (conservez le fichier MP4) :

```bash
ffmpeg -i 2023_05_titre_video.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus 2023_05_titre_video.webm
```

Si le fichier MP4 lui-même est trop gros, vous pouvez le compresser :

```bash
ffmpeg -i 2023_05_titre_video.mp4 -vcodec libx265 -crf 30 2023_05_titre_video.mp4
```

Uploadez les fichiers MP4 et WEBM sur le bucket S3 `collectif-objets-public`.
Donnez les permissions ACL en lecture pour tous les visiteurs pour les fichiers uploadés.

Enfin vous pouvez insérer et adapter l’un des deux snippets suivants en HAML ou HTML :

```haml
%video.co-cursor-pointer{controls:"", width:"100%", preload:"none", poster:vite_asset_path("images/2023_05_titre_video.webp"), href:"#"}
  / the href is a fix for a bad rule in DSFR
  %source(src="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.webm" type="video/webm")
  %source(src="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.mp4" type="video/mp4")
  %a(href="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.mp4")
    Télécharger la vidéo au format MP4
```

```html
<video class="co-cursor-pointer" controls="" width="100%" preload="none" poster="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.png" href="#">
  <source src="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.webm" type="video/webm">
  <source src="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.mp4" type="video/mp4">
  <a href="https://s3.fr-par.scw.cloud/collectif-objets-public/2023_05_titre_video.mp4">
    Télécharger la vidéo au format MP4
  </a>
</video>
```


## Debug local via tunneling

Le tunneling consiste à exposer votre environnement local sur une URL publiquement accessible.
`ngrok` est l’outil de tunneling le plus répandu mais nous avons configuré `loophole` sur ce projet car le plan gratuit est plus généreux.
Les instructions d’installation sont sur [le site public de loophole](https://loophole.cloud/).

Une fois installé vous pouvez utiliser :

- `make tunnel` tunnel général du port 3000 accessible sur https://collectifobjets.loophole.site. Cela permet par exemple de tester le rendu sur un mobile.
- `make tunnel_webhooks` expose uniquement l’URL racine https://collectifobjets-mail-inbound.loophole.site qui est configurée sur un webhook inbound parsing sur Send In Blue.
