# RSSI Secure Command Deck

Application web chiffrée destinée aux RSSI et professionnels de la cybersécurité. Tableau de bord, outils techniques/GRC, threat intelligence, playbooks avec historique, calculateurs RPO/RTO/amende, et persistance locale — le tout dans un seul fichier HTML.

## Fonctionnalités

- **Dashboard** — Statistiques, favoris récents, jauges composites (couverture outillage, complétion playbooks, maturité prioritaire)
- **Outils Techniques** — 33 fiches (Nmap, Wireshark, Nessus, Metasploit, Velociraptor, Wazuh, CrowdStrike, Keycloak, Veeam…)
- **Outils Fonctionnels (GRC)** — 14 fiches (TheHive, MISP, Eramba, GLPI, Obsidian, Bitwarden…)
- **Threat Intel** — Sources OSINT, flux CISA/ANSSI, modèles conceptuels (Kill Chain, Diamond Model)
- **Frameworks & Normes** — 7 référentiels (RGPD, NIS 2, DORA, ISO 27001/27002, CIS Controls v8, NIST CSF 2.0)
- **Calculateurs** — Amende RGPD, grille de risque EBIOS, **RPO/RTO avec coût d'arrêt horaire**
- **Mémos & Playbooks** — 4 playbooks (Ransomware, Fuite RGPD, Panne Datacenter, Compromission Admin) avec historique des exercices, éditeur de notes Markdown, vue/édition/suppression
- **Contacts d'Urgence** — 4 fiches modifiables (assurance, avocat, hébergeur, direction)
- **Recherche globale** — Filtrage instantané de toutes les fiches
- **Tri par priorité** — Essentiel / Important / Complémentaire avec badges colorés

## Sécurité

- Chiffrement **AES-GCM 256 bits** via Web Crypto API
- Dérivation de clé **PBKDF2** — 100 000 itérations avec sel aléatoire
- IV aléatoire de 12 octets pour chaque chiffrement
- Aucune clé en clair conservée en mémoire persistante
- Coffre déchiffré uniquement en mémoire vive, pendant la session
- Mot de passe saisi via **modale DOM** (plus de `prompt()`)

## Stockage

Deux couches de persistance :

| Couche | Technologie | Usage |
|---|---|---|
| **IDB** (IndexedDB) | Base `rssi_deck_vault` | Sauvegarde automatique universelle (file:// + http://) |
| **FSA** (File System Access) | `showDirectoryPicker` | Synchronisation fichier disque (http:// uniquement) |

- **http://** : `showDirectoryPicker` → choisir `.rssi_deck/rssi_coffre.json` + copie IDB
- **file://** : IndexedDB automatique + bouton "Exporter" pour copie fichier manuelle
- **Export** : Téléchargement du fichier `.json` chiffré (nom horodaté : `rssi_coffre_2026-05-22_08_30.json`)
- **Import** : Chargement depuis un fichier `.json` externe (toujours disponible)

Le chemin fichier attendu sur le disque est affiché sur l'écran de verrouillage :
- Windows : `C:\Users\<USER>\AppData\Local\.rssi_deck\rssi_coffre.json`
- Linux   : `~/.rssi_deck/rssi_coffre.json`
- macOS   : `~/.rssi_deck/rssi_coffre.json`

## Utilisation

1. Ouvrir `rssi_deck.html` dans Chrome, Edge ou Opera
2. Créer un coffre : choisir ou créer un dossier `.rssi_deck`, définir un mot de passe
3. Naviguer dans les vues via la barre latérale
4. "Sauvegarder" → chiffre et persiste le coffre
5. "Verrouiller" → protège l'accès
6. Au rechargement : "Charger" depuis le dossier ou le navigateur

## Technologies

- **Vanilla JS** — Zéro framework, zéro dépendance build
- **Tailwind CSS** (CDN) — Styles utilitaires
- **FontAwesome 6** (CDN) — Icônes
- **Chart.js** — Graphiques du dashboard
- **Marked.js** — Rendu Markdown des mémos et playbooks
- **Web Crypto API** — Chiffrement AES-GCM 256 + PBKDF2
- **IndexedDB** — Persistance navigateur
- **File System Access API** — Accès fichier disque (Chrome http://)

## Compatibilité Navigateur

| Fonctionnalité | Chrome / Edge | Firefox | Safari |
|---|---|---|---|
| Chiffrement AES-GCM | ✅ | ✅ | ✅ |
| IndexedDB (auto-save) | ✅ | ⬜ futur | ⬜ futur |
| FSA showDirectoryPicker | ✅ | ❌ | ❌ |
| Export / Import fichiers | ✅ | ✅ | ✅ |

## Licence

Usage interne. Aucune dépendance externe autre que les CDN listés.
