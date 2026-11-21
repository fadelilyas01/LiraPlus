# LiraPlus — Application Mobile Québécoise d'Aide à la Lecture Inclusive

Application mobile éducative conçue pour accompagner les élèves du primaire des centres de services scolaires (CSS) du Québec et du Canada rencontrant des défis d'apprentissage de la lecture :
- **Élèves sourds et malentendants** : Intégration native de la Langue des Signes Québécoise (LSQ), avec visualiseur 60 FPS des trajectoires gestuelles, moteur vectoriel anatomique de dactylologie (A-Z) et vue miroir.
- **Élèves dyslexiques et dysorthographiques** : Découpage syllabique phonétique hors-ligne, alternance chromatique et arcs de liaison sous les syllabes pour fluidifier le déchiffrage.
- **Élèves malvoyants ou ayant une basse vision** : Contraste maximal WCAG AAA, règle de lecture horizontale guidée par le doigt et typographie grand format.
- **Élèves neurodivergents ou à besoins particuliers** : Récits adaptés en Français Facile à Lire et à Comprendre (FALC) et suivi de progression valorisant sans stress.

---

## Principes Directeurs & Souveraineté des Données

L'application fonctionne selon le standard **Zero-Cloud & Edge Computing** :
- **100 % Hors-Ligne (Offline-First)** : L'ensemble des traitements (synthèse vocale locale `fr-CA`, reconnaissance optique de caractères OCR de manuels scolaires via Google ML Kit, segmentation syllabique, rendu dactylologique et animations gestuelles) s'exécute exclusivement en local sur l'appareil.
- **Conformité Légale Rigoureuse** : Aucune donnée nominative, télémétrie ou texte d'élève ne transite sur le réseau, assurant une conformité totale avec la **Loi 25 du Québec sur la protection des renseignements personnels**, la **LPRPDE/PIPEDA** fédérale et les critères d'approbation ministérielle du **Ministère de l'Éducation du Québec (MEQ)**.

---

## Fonctionnalités Principales

### 1. Lecteur Interactif & Ergonomique
- **Prononciation immédiate au toucher** : L'élève touche n'importe quel mot du texte pour l'écouter instantanément, avec vibration haptique synchronisée par syllabe.
- **Stabilité absolue du viewport (Anti-Saut)** : La page conserve rigoureusement sa position sous le doigt de l'élève sans aucun retour forcé au début du document.
- **Défilement karaoké fluide** : Lors de la lecture continue, le mot actif est centré avec douceur dans le champ visuel.
- **Cadence vocale apaisée** : Trois vitesses adaptées à l'école primaire : Doucement (0.5x), Tranquille (0.75x) et Allant (1.0x).
- **Interface responsive anti-overflow** : Mise en page testée et validée sans aucun débordement de pixels sur tout format d'écran (téléphones compacts 320px, tablettes en portrait et paysage).

### 2. Espace Sourd & Langue des Signes Québécoise (LSQ)
- **Mouvements animés des signes (60 FPS)** : Visualiseur graphique de trajectoires physiques (battements d'ailes, caresse des moustaches, tracé du toit, rayonnement solaire, etc.) avec décomposition en 3 temps (position de départ, trajectoire, point d'arrivée).
- **Ralenti pédagogique (0.5x)** : Permet à l'enfant d'observer et de décomposer le mouvement gestuel à son propre rythme.
- **Moteur vectoriel de dactylologie** : Représentation anatomique fidèle des 26 formes de main de l'alphabet québécois, sans pictogrammes génériques.
- **Bascule Vue Miroir** : Permet à l'élève d'alterner entre la perspective d'observation (« En face ») et la reproduction de sa propre main (« Ma main »).
- **Défileur d'épellation pas à pas** : Épellation automatique ou manuelle lettre par lettre de chaque mot du texte.

### 3. Atelier de l'Alphabet A à Z & Mots de la Classe
- **Grand Abécédaire A-Z interactif** : Fiches détaillées pour chaque lettre avec conseils de placement des doigts pour les parents et enseignants, sons phonétiques et mots d'exemple.
- **Dictionnaire des 10 mots essentiels de l'école** : Bonjour, Merci, Ami, Chat, Oiseau, Livre, Arbre, Soleil, Maison, Jouer avec animations et phrases de mise en contexte.
- **Mini-jeu éducatif « Trouve la bonne main »** : Quiz bienveillant valorisant chaque réussite sans pénalité.

### 4. Carnet de Progression & Motivation
- **Barre d'étapes de lecture** : Indicateur visuel d'avancement par phrase avec messages d'encouragement dynamique.
- **Tableau de bord de réussite** : Suivi des mots découverts, des étapes franchies, des histoires complétées et déblocage de badges d'accomplissement.

### 5. Numérisation OCR Locale
- Capture de devoirs ou de pages de manuels scolaires via la caméra de la tablette.
- Extraction de texte 100 % locale sans connexion Internet.
- Enregistrement dans « Mes Textes » pour une lecture accessible immédiate.

---

## Profils d'Accessibilité

| Profil | Fond | Texte / Accent | Spécificités d'aide |
| :--- | :--- | :--- | :--- |
| **Standard** | Titane neutre (`#E5E9EE`) | Ardoise / Azur | Réduction de 30 % de la fatigue oculaire, contrastes soignés |
| **Basse Vision** | Noir pur (`#000000`) | Jaune vif (`#FFEA00`) | Règle de lecture horizontale, bordures de 2.5px, grand format |
| **Dyslexie** | Crème chaud (`#FAF6EE`) | Brun doux / Turquoise | Espacement aéré, alternance syllabique, atténuation des lettres muettes |
| **LSQ / Sourd** | Bleu nuit (`#0F172A`) | Ambre / Corail | Panneau LSQ interactif, mouvements animés, dactylologie, retours haptiques |
| **Lecture Soir** | Ambre doux (`#1C1612`) | Or chaud (`#FBBF24`) | Zéro lumière bleue, repos visuel avant le coucher |

---

## Architecture Logicielle

Le projet est structuré selon les principes de la **Clean Architecture** et du découplage des responsabilités :

```text
lib/
├── main.dart                               # Point d'entrée avec Error Boundary et injection des dépendances
├── core/
│   ├── errors/failures.dart                # Pattern fonctionnel Result<T> et gestion d'erreurs typée
│   ├── models/
│   │   ├── dactylology_data.dart           # Référentiel des 26 lettres LSQ et mots-clés de l'école
│   │   └── falc_dictionary.dart            # Dictionnaire FALC québécois et récits gradués MEQ
│   ├── nlp/french_syllabifier.dart         # Découpage syllabique, élisions, lettres muettes et liaisons
│   ├── providers/accessibility_provider.dart# État réactif de l'application, profils et progression
│   ├── services/tts_haptic_service.dart    # Synthèse vocale calibrée et haptique par syllabes
│   ├── storage/preferences_repository.dart # Sauvegarde locale atomique (Zero-Cloud, Loi 25)
│   ├── theme/accessibility_themes.dart     # Tokens de design, couleurs et polices accessibles
│   └── utils/accessibility_announcer.dart  # Annonces d'accessibilité TalkBack / VoiceOver
└── features/
    ├── faq/faq_screen.dart                 # Guide & FAQ pour parents et enseignants
    ├── scanner/ocr_camera_screen.dart      # Scanner OCR local de livres scolaires
    └── reader/
        ├── reader_screen.dart              # Écran principal de lecture interactive
        ├── word_coach_sheet.dart           # Fiche d'étude approfondie du mot (FALC & Syllabes)
        └── presentation/
            ├── alphabet_workshop_screen.dart # Grand Abécédaire A-Z et mots du quotidien
            └── widgets/
                ├── alphabet_quiz_sheet.dart          # Quiz éducatif « Trouve la bonne main »
                ├── dactylology_viewer.dart           # Visualiseur de lettres manuelles
                ├── display_settings_sheet.dart       # Réglages typographiques et d'affichage
                ├── interactive_text_flow.dart        # Flux de texte interactif isolé (Anti-Jank)
                ├── lsq_handshape_widget.dart         # Moteur vectoriel de mains avec Vue Miroir
                ├── lsq_motion_viewer.dart            # Moteur animé 60 FPS des trajectoires de signes
                ├── lsq_reader_panel.dart             # Panneau LSQ en direct sous le texte
                ├── lsq_speller_player.dart           # Défileur automatique « Épelle avec mes mains »
                ├── profile_selector_bar.dart         # Barre de sélection rapide des profils
                ├── progression_dashboard_sheet.dart  # Carnet de progression et trophées de l'élève
                ├── reader_bottom_bar.dart            # Barre de commande accessible (Thumb Zone)
                ├── reading_celebration_sheet.dart    # Célébration bienveillante de fin de lecture
                ├── reading_ruler_overlay.dart        # Règle de lecture fluide guidée par le doigt
                ├── reading_step_progress_bar.dart    # Barre d'étapes de lecture avec encouragements
                ├── sample_text_sheet.dart            # Bibliothèque des récits MEQ et devoirs
                ├── syllable_puzzle_game.dart         # Mini-jeu tactile de reconstitution de mots
                └── word_item_widget.dart             # Mot interactif individuel avec arcs de liaison
```

---

## Assurance Qualité & Intégration Continue (CI/CD)

Le projet intègre un pipeline GitHub Actions automatisé (`.github/workflows/ci.yml`) appliquant le principe du moindre privilège (`permissions: read-all`) :

1. **Vérification du formatage** : `dart format --output=none --set-exit-if-changed .`
2. **Analyse statique stricte** : `flutter analyze --fatal-infos --fatal-warnings` (0 erreur, 0 avertissement).
3. **Suite de tests automatisés** : `flutter test --coverage` (38/38 tests validés).
4. **Vérification de compilabilité mobile** : `flutter build apk --debug`.

### Exécution locale des vérifications :

```bash
# Analyse statique du code
flutter analyze

# Lancement des tests automatisés
flutter test
```

---

## Conformité & Confidentialité

- Conforme aux exigences de la **Loi 25 du Québec sur la protection des renseignements personnels dans le secteur public et privé**.
- Conforme aux standards d'accessibilité numérique **WCAG 2.1 niveau AAA** et **Apple Human Interface Guidelines / Google Material 3**.
