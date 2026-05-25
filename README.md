# RSSI Secure Command Deck

Application web chiffrée destinée aux RSSI et professionnels de la cybersécurité. Tableau de bord, outils techniques/GRC, threat intelligence, gouvernance (RGPD, plan d'actions, incidents), playbooks avec historique, calculateurs RPO/RTO/amende RGPD, et persistance locale — le tout dans un seul fichier HTML.

## Fonctionnalités

- **Dashboard** — Statistiques, favoris récents, jauges composites (couverture outillage, complétion playbooks, maturité prioritaire)
- **Outils Techniques** — 33 fiches (Nmap, Wireshark, Nessus, Metasploit, Velociraptor, Wazuh, CrowdStrike, Keycloak, Veeam…)
- **Outils Fonctionnels (GRC)** — 14 fiches (TheHive, MISP, Eramba, GLPI, Obsidian, Bitwarden…)
- **Threat Intel** — Sources OSINT, flux CISA/ANSSI, modèles conceptuels (Kill Chain, Diamond Model). Chaque fiche (nom, URL, description, icône) est modifiable, ajoutable et supprimable avec confirmation.
- **Frameworks & Normes** — 7 référentiels (RGPD, NIS 2, DORA, ISO 27001/27002, CIS Controls v8, NIST CSF 2.0). Mêmes possibilités d'édition/ajout/suppression que Threat Intel.
- **Calculateurs** — Amende RGPD (paramétrable de 0€ au plafond légal), grille de risque EBIOS, **RPO/RTO avec coût d'arrêt horaire**
- **Gouvernance** — 11 sous-onglets :
  - **Registre des traitements RGPD** (Art. 30) — Finalité, base légale (6 options Art. 6), responsable, catégories de données/personnes, destinataires, mesures de sécurité, statut
  - **Plan d'actions Sécurité** — Actions pré-remplies (PSSI, audit RGPD, MFA, sensibilisation), priorité, responsable, échéance, statut
  - **Registre des incidents** — Taxonomie ENISA/ANSSI (15 types : ransomware, phishing, fuite de données, DDoS, compromission, intrusion, malware, FOVI…), impact, statut, date de résolution
  - **Registre des actifs** — Inventaire, propriétaire, classification, localisation, statut
  - **Registre des risques** — Analyse, cotation, traitement, responsable, statut
   - **Politique PSSI** — 23 sections pré-définies, 97 clauses suggérées, cycle de validation (Brouillon→Rédaction→Validé→En révision→Publié), fréquence de révision (Annuelle/Semestrielle/Trimestrielle), vue Document complet avec rendu Markdown et impression
  - **Matrice RACI** — 15 activités, 7 rôles, cycle R→A→C→I au clic, double-clic pour effacer une cellule, **bouton « Valider »** avec détection d'anomalies (doublons A, absence R, goulots d'étranglement par rôle), **3 niveaux de protection** des rôles (protégé/important/normal), export CSV presse-papier
  - **AIPD / DPIA** — Analyse d'impact complète, gravité, statut
  - **Auto-évaluation NIST CSF 2.0** — 6 domaines, sous-domaines détaillés, échelle CMMI 1→5, score pondéré, radar chart, date d'évaluation
     - **Registre des prestataires** — Criticité, conformité, planification d'audit
   - **Évaluation CVSS v3.1** — Vecteur, score de base, sévérité, analyse environnementale
- **Mémos & Playbooks** — 4 playbooks (Ransomware, Fuite RGPD, Panne Datacenter, Compromission Admin) avec historique des exercices, date, éditeur de notes Markdown, vue/édition/suppression
- **Contacts d'Urgence** — 4 fiches modifiables (assurance, avocat, hébergeur, direction)
- **Recherche globale** — Filtrage instantané de toutes les fiches
- **Tri par priorité** — Essentiel / Important / Complémentaire avec badges colorés

## Sécurité

- Chiffrement **AES-GCM 256 bits** via Web Crypto API
- Dérivation de clé **PBKDF2** — 600 000 itérations avec sel aléatoire
- IV aléatoire de 12 octets pour chaque chiffrement
- Aucune clé en clair conservée en mémoire persistante
- Coffre déchiffré uniquement en mémoire vive, pendant la session
- Mot de passe saisi via **modale DOM** (plus de `prompt()`)
- Alerte de confirmation avant écrasement d'un coffre existant à la création
- **Rate-limiting exponentiel** (1 s → 60 s) sur les tentatives de déchiffrement échouées
- **Bouton bouclier** `securityCheck()` : vérification complète (librairies, conformité du coffre, 20 sections, doublons, favoris orphelins, anomalies structurelles, pollution de prototype, fonctions natives, API des librairies critiques)
- **Bouton restauration** : affiche les URL officielles CDN et les empreintes SHA-256 des librairies pour téléchargement manuel avec vérification d'intégrité
- **Surveillance du chargement** des librairies via `onerror` + variables globales (`Chart`, `marked`)
- **Script externe `verify_integrity.ps1`** : vérification hors navigateur des hash SHA-256 des fichiers `lib/` et de l'intégrité de `rssi_deck.html` (avec initialisation par `-Init` et fichier de référence `.sha256`)

## Stockage

Deux couches de persistance :

| Couche | Technologie | Usage |
|---|---|---|
| **IDB** (IndexedDB) | Base `rssi_deck_vault` | Sauvegarde automatique universelle (file:// + http://) |
| **FSA** (File System Access) | `showDirectoryPicker` | Synchronisation fichier disque (http:// uniquement) |

- **http://** : `showDirectoryPicker` → choisir `.rssi_deck/rssi_coffre.json` + copie IDB
- **file://** : IndexedDB automatique + bouton "Exporter" pour copie fichier manuelle
- **Export** : Téléchargement du fichier `.json` chiffré (nom horodaté)
- **Import** : Chargement depuis un fichier `.json` externe (toujours disponible)
- **Migration automatique** : Ajout des champs manquants (fréquence de révision PSSI, pondération et date d'évaluation maturité, historique playbooks, registres gouvernance, **correction des doublons RACI**, **thème préféré**) au chargement des coffres existants

## Utilisation

1. Cloner ce dépôt (ou télécharger l'archive) — le dossier `lib/` avec ses dépendances locales est inclus
2. Ouvrir `rssi_deck.html` dans Chrome, Edge ou Opera
3. Créer un coffre : choisir ou créer un dossier `.rssi_deck`, définir un mot de passe
4. Naviguer dans les vues via la barre latérale
5. "Sauvegarder" → chiffre et persiste le coffre
6. "Verrouiller" → protège l'accès
7. Au rechargement : "Charger" depuis le dossier ou le navigateur
8. **Vérification d'intégrité** : `.\verify_integrity.ps1 -Init` (première fois), puis `.\verify_integrity.ps1` (contrôles réguliers) — compare les hash des fichiers `lib/` et l'empreinte de `rssi_deck.html`

## Technologies

- **Vanilla JS** — Zéro framework, zéro dépendance build
- **Tailwind CSS** (local `lib/tailwind.css`) — Styles utilitaires
- **FontAwesome 6.5.1** (local `lib/fontawesome/`) — Icônes
- **Chart.js 4.4.7** (local `lib/chart.umd.min.js`) — Graphiques du dashboard et radar chart maturité NIST CSF
- **Marked.js 15.0.4** (local `lib/marked.min.js`) — Rendu Markdown des mémos et playbooks
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

Usage interne. Toutes les dépendances (`lib/`) sont embarquées localement — aucune requête CDN externe.
