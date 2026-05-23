# RSSI Secure Command Deck

Application web chiffrée destinée aux RSSI et professionnels de la cybersécurité. Tableau de bord, outils techniques/GRC, threat intelligence, gouvernance (RGPD, plan d'actions, incidents), playbooks avec historique, calculateurs RPO/RTO/amende RGPD, et persistance locale — le tout dans un seul fichier HTML.

## Fonctionnalités

- **Dashboard** — Statistiques, favoris récents, jauges composites (couverture outillage, complétion playbooks, maturité prioritaire)
- **Outils Techniques** — 33 fiches (Nmap, Wireshark, Nessus, Metasploit, Velociraptor, Wazuh, CrowdStrike, Keycloak, Veeam…)
- **Outils Fonctionnels (GRC)** — 14 fiches (TheHive, MISP, Eramba, GLPI, Obsidian, Bitwarden…)
- **Threat Intel** — Sources OSINT, flux CISA/ANSSI, modèles conceptuels (Kill Chain, Diamond Model). Chaque fiche (nom, URL, description, icône) est modifiable, ajoutable et supprimable avec confirmation.
- **Frameworks & Normes** — 7 référentiels (RGPD, NIS 2, DORA, ISO 27001/27002, CIS Controls v8, NIST CSF 2.0). Mêmes possibilités d'édition/ajout/suppression que Threat Intel.
- **Calculateurs** — Amende RGPD (paramétrable de 0€ au plafond légal), grille de risque EBIOS, **RPO/RTO avec coût d'arrêt horaire**
- **Gouvernance** — 10 sous-onglets :
  - **Registre des traitements RGPD** (Art. 30) — Finalité, base légale (6 options Art. 6), responsable, catégories de données/personnes, destinataires, mesures de sécurité, statut
  - **Plan d'actions Sécurité** — Actions pré-remplies (PSSI, audit RGPD, MFA, sensibilisation), priorité, responsable, échéance, statut
  - **Registre des incidents** — Taxonomie ENISA/ANSSI (15 types : ransomware, phishing, fuite de données, DDoS, compromission, intrusion, malware, FOVI…), impact, statut, date de résolution
  - **Registre des actifs** — Inventaire, propriétaire, classification, localisation, statut
  - **Registre des risques** — Analyse, cotation, traitement, responsable, statut
  - **Politique PSSI** — 20 sections pré-définies, ~80 clauses suggérées, cycle de validation (Brouillon→Rédaction→Validé→En révision→Publié), fréquence de révision (Annuelle/Semestrielle/Trimestrielle), vue Document complet avec rendu Markdown et impression
  - **Matrice RACI** — 15 activités, 7 rôles, cycle R→A→C→I au clic, double-clic pour effacer une cellule, export CSV presse-papier
  - **AIPD / DPIA** — Analyse d'impact complète, gravité, statut
  - **Auto-évaluation NIST CSF 2.0** — 6 domaines, sous-domaines détaillés, échelle CMMI 1→5, score pondéré, radar chart, date d'évaluation
  - **Registre des prestataires** — Criticité, conformité, planification d'audit
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
- **SRI (Subresource Integrity)** sur toutes les ressources CDN (FontAwesome 6.5.1, Chart.js 4.4.7, Marked.js 15.0.4) avec `crossorigin="anonymous"`
- **Anti-XSS** : `filterText()` blindé (`esc()` interne) sur toutes les données utilisateur affichées ; texte de secours `<span>` pour les icônes quand le CDN est indisponible

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
- **Migration automatique** : Ajout des champs manquants (fréquence de révision PSSI, pondération et date d'évaluation maturité, historique playbooks, registres gouvernance) au chargement des coffres existants

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
- **FontAwesome 6.5.1** (CDN, version figée + SRI) — Icônes
- **Chart.js 4.4.7** (CDN, version figée + SRI) — Graphiques du dashboard et radar chart maturité NIST CSF
- **Marked.js 15.0.4** (CDN, version figée + SRI) — Rendu Markdown des mémos et playbooks
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
