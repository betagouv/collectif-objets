# Synchronisation

« Synchronisation » est plus correct qu’« import » car on ne fait pas que créer des données, on en met à jour et on en supprime

## Sources 🌎

Les données de Collectif Objets proviennent de plusieurs sources :

| Source | Contient | Importé dans CO vers |
| - | - | - |
| [data.culture.gouv.fr](https://data.culture.gouv.fr) | Palissy et Mérimée | `Objet` et `Edifice` |
| [api-lannuaire.service-public.fr](api-lannuaire.service-public.fr) | données des établissements publics | `Commune` et `User` |
| [résultats du scrapping de POP](https://collectif-objets-datasette.fly.dev/) | URLs & métadonnées des photos Mémoire | `Objet.palissy_photos` |


## Périmètre

- On ne stocke dans la table `objets` qu’une partie des objets de Palissy : ceux dans notre périmètre (cf [détails plus bas](#périmètre-de-co)) ;
- On ne stocke dans la table `edifices` que les édifices qui contiennent des objets dans le périmètre de CO.
- On ne stocke dans la table `communes` que les communes qui contiennent des objets dans le périmètre de CO.

## Processus de synchronisation ⚙️

Une fois par semaine, on exécute plusieurs processus (ou *scripts*) consécutivement :

1. synchronisation des objets
2. synchronisation des édifices
4. synchronisation des photos
3. synchronisation des communes et usagers

### Synchronisation des objets 🖼️

- met à jour les objets déjà présents dans CO
- créé les objets (nouveaux ou mis à jour) qui rentrent pour la première fois dans notre périmètre
- supprime les objets déjà présents dans CO mais qui ne sont plus dans notre périmètre

Ce processus est aussi en charge d’associer chaque objet à un édifice.
Il cherche un édifice existant dans notre base ou bien on en créé un (cf [détails plus bas](#identification-et-dédoublonnage-des-édifices)).

Ce processus peut aussi supprimer des recensements existants dans deux cas :

- l’objet sort de notre périmètre alors qu’il a été recensé
- l’objet change de code INSEE alors qu’il a été recensé (il peut s’agir d’une correction, d’un déplacement, ou d’une fusion de communes)

### Synchronisation des édifices ⛪️

- parcourt les édifices Mérimée
- cherche un édifice correspondant dans notre base (cf [détails plus bas](#identification-et-dédoublonnage-des-édifices))
- le met à jour le cas échéant

Ce processus ne créé aucun édifice, c’est fait dans le processus de synchronisation des objets
Il ne supprime aucun édifice non plus, c’est fait dans un processus de nettoyage annexe.

### Synchronisation des photos 📸

- parcourt les photos Mémoire associées à un objet Palissy
- cherche l’objet correspondant dans notre base
- ajoute cette photo à l’objet correspondant le cas échéant (dans le mal nommé champ `objets.palissy_photos`)

Pour l’instant nous utilisons encore le scrapping de POP et l’export des données scrappées sur [datasette](https://collectif-objets-datasette.fly.dev/).
Nous attendons que Gautier publie sur data.culture.gouv.fr les photos de Mémoire pour les en importer directement.

### Synchronisation des communes et emails d’usagers 🏠👤

- filtre les données de Service Public pour garder uniquement les "mairies principales"
- supprime les communes et/ou les emails existant déja dans notre base mais n’apparaissant plus dans ces données filtrées
- ignore les données de communes pour lesquelles il n’y a aucun objet existant dans notre base avec ce code INSEE
- créé ou met à jour la commune et l’email correspondant dans notre base

Une cinquantaine de codes INSEE correspondent à plusieurs "mairies principales" dans les données de Service Public, on ignore toutes ces infos.

## Détails

### Périmètre de CO

Il s’agit de nos "règles d’import" de Palissy :

- notices de "dossiers individuels"
- notices qui ne sont pas "en cours de traitement"
- objets qui ne sont pas propriété de l’état
- objets qui ne sont pas volés
- objets qui ne sont pas manquants
- objets qui ne sont pas déclassés

cf implémentation de ces règles dans [`Synchronizer::Objets::Row`](https://github.com/betagouv/collectif-objets/blob/main/app/jobs/synchronizer/objets/row.rb)

### Suppression et archivage des recensements (*soft-deletes*)

Rappel : un recensement est en brouillon si l’usager n’est pas allé au bout des étapes du formulaire de recensement.

Les recensements brouillons sont purement et simplement supprimés de notre base de données.

En revanche les recensements complets sont archivés mais conservés (*soft-deleted*).
Ces recensements archivés sont supprimés des dossiers et des rapports.
Ils restent visibles par les conservateurs mais pas par les usagers.

### Identification et dédoublonnage des édifices

Les édifices de CO divergent volontairement de ceux de Mérimée :

- de nombreux objets sont dans des édifices qui ne sont pas des édifices protégés donc pas dans Mérimée
- dans le cas d’un objet appartenant effectivement à un édifice protégé, sa référence Mérimée est souvent absente de Palissy
- dans le cas d’objets appartenant à des édifices non-protégés, les noms d’édifices ne sont pas normés dans Palissy et génèrent des doublons

Pour identifier les édifices et éviter les doublons on utilise:

- prioritairement la référence Mérimée si elle est présente dans les données Palissy
- sinon, la paire `(code INSEE, nom d’édifice nettoyé)`

Ce mécanisme d’identification est utilisé :

- lors de la synchronisation des objets pour trouver ou créer un édifice dans notre base ;
- lors de la synchronisation des édifices pour mettre à jour un édifice déjà présent dans notre base.

Grace à ce mécanisme :
- on dédoublonne une partie des édifices non-protégés grace au nettoyage des noms (par exemple "église Saint-Jean" et "eglise Saint Jean" seront considérés identiques)
- on retrouve la référence Mérimée de certains édifices : par exemple si un objet Palissy a le code INSEE 01023 et un nom d’édifice "Église Saint-Jean" et qu’on trouve dans Mérimée un édifice correspondant, on met à jour notre `edifice` avec la référence Mérimée.
