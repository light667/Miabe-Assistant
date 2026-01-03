import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class MistralService {
  static const String _baseUrl = 'https://api.mistral.ai/v1/chat/completions';
  
  // Mode mock pour les tests (false = utilise l'API réelle)
  static const bool _useMockMode = false;
  
  // Récupère la clé API de manière sécurisée
  static String get _apiKey => AppConfig.mistralApiKey;
  
  // Prompt système pour guider le chatbot
  static const String _systemPrompt = '''
Vous êtes Miabé ASSISTANT, un assistant pédagogique intelligent dédié aux étudiants de l'école polytechnique et d'ingénierie.

Votre mission est d'aider les étudiants dans leurs études en sciences et technologies.

Vos domaines d'expertise incluent :
- Rédaction de rapports de stage académiques
- Préparation et réalisation de stages professionnels
- Rédaction de lettres de motivation
- Création de CV professionnels
- Organisation et planification des études
- Validation des unités d'enseignement
- Élaboration de plans de travail
- Préparation à la vie professionnelle

Règles de communication :
1. Soyez précis, structuré et pédagogique
2. Adaptez vos réponses au contexte togolais et africain
3. Fournissez des exemples concrets et applicables
4. Utilisez un français clair et professionnel
5. Encouragez et motivez les étudiants
6. Proposez des étapes concrètes et actionnables

Lorsqu'un étudiant demande un exemple de document (CV, lettre de motivation, rapport), fournissez une structure détaillée avec des sections claires.
Signature: 'Miabé ASSISTANT 🤖'
''';

  /// Envoie un message au chatbot Mistral et retourne la réponse
  static Future<String> sendMessage(String userMessage, {List<Map<String, String>>? conversationHistory}) async {
    // Mode mock pour les tests
    if (_useMockMode) {
      await Future.delayed(const Duration(seconds: 2)); // Simule latence API
      return _getMockResponse(userMessage);
    }
    
    try {
      // Construire l'historique de conversation
      final messages = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
      ];
      
      // Ajouter l'historique de conversation s'il existe
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        messages.addAll(conversationHistory);
      }
      
      // Ajouter le nouveau message utilisateur
      messages.add({'role': 'user', 'content': userMessage});

      // Préparer la requête
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'mistral-small-latest', // Modèle économique et performant
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 2000,
          'top_p': 0.95,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else if (response.statusCode == 401) {
        return "❌ Erreur d'authentification API. Veuillez vérifier la clé API Mistral.";
      } else if (response.statusCode == 429) {
        return "⏳ Trop de requêtes. Veuillez patienter quelques instants avant de réessayer.";
      } else {
        return "❌ Erreur ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "❌ Erreur de connexion: ${e.toString()}\n\nVérifiez votre connexion Internet.";
    }
  }

  /// Réponses mock pour tester l'application sans API
  static String _getMockResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('rapport') && lowerMessage.contains('stage')) {
      return '''
📄 **Comment rédiger un excellent rapport de stage**

Voici les étapes clés pour un rapport réussi :

**1. Structure de base** 📋
• Page de garde professionnelle
• Remerciements (1 page)
• Sommaire détaillé
• Introduction (2-3 pages)
• Corps du rapport (25-40 pages)
• Conclusion (2 pages)
• Bibliographie
• Annexes

**2. Conseils de rédaction** ✍️
• Utilisez un français formel et précis
• Structurez avec des titres et sous-titres
• Illustrez avec des schémas, tableaux, graphiques
• Citez vos sources
• Relisez plusieurs fois

**3. Présentation** 🎨
• Police : Times New Roman 12pt
• Interligne : 1.5
• Marges : 2.5cm
• Justification du texte
• Numérotation des pages

**4. Contenu important** 💡
• Décrivez concrètement vos missions
• Analysez ce que vous avez appris
• Soyez critique de manière constructive
• Montrez votre évolution

Voulez-vous voir un exemple détaillé de structure ? Cliquez sur les 3 points en haut à droite et sélectionnez "Exemple Rapport de Stage".
''';
    }
    
    if (lowerMessage.contains('stage') && (lowerMessage.contains('trouver') || lowerMessage.contains('étape') || lowerMessage.contains('recherche'))) {
      return '''
💼 **Guide complet pour trouver un stage**

**Étape 1 : Préparation (1-2 mois avant)** 🎯
• Identifiez vos objectifs professionnels
• Listez vos compétences et centres d'intérêt
• Créez votre CV professionnel
• Préparez une lettre de motivation type
• Créez un profil LinkedIn

**Étape 2 : Recherche active** 🔍
• Consultez les sites d'emploi togolais
• Visitez les sites web des entreprises ciblées
• Utilisez votre réseau (famille, amis, professeurs)
• Participez aux forums emploi de votre université
• Contactez l'administration de votre établissement

**Étape 3 : Candidatures** 📧
• Personnalisez chaque lettre de motivation
• Envoyez des candidatures spontanées
• Relancez par téléphone après 1 semaine
• Gardez un tableau de suivi de vos candidatures

**Étape 4 : Préparation aux entretiens** 🎤
• Renseignez-vous sur l'entreprise
• Préparez vos réponses aux questions classiques
• Prévoyez des questions à poser
• Soignez votre présentation

**Étape 5 : Suivi** 📞
• Remerciez après chaque entretien
• Relancez si pas de réponse après 2 semaines
• Restez motivé et persévérant

**Timing recommandé** ⏰
Commencez votre recherche 2-3 mois avant la date souhaitée de début de stage.

Des questions sur une étape en particulier ?
''';
    }
    
    if (lowerMessage.contains('lettre') && lowerMessage.contains('motivation')) {
      return '''
✉️ **Rédiger une lettre de motivation efficace**

**Structure en 3 paragraphes** 📝

**§1 - VOUS (L'entreprise)** 🏢
Montrez que vous connaissez l'entreprise :
"Passionné(e) par [domaine], j'ai été particulièrement attiré(e) par votre entreprise [Nom] reconnue pour [point fort]. Votre engagement dans [projet/valeur] correspond parfaitement à mes aspirations professionnelles."

**§2 - MOI (Vos atouts)** 💪
Présentez vos compétences :
"Actuellement étudiant(e) en [formation] à [établissement], j'ai développé des compétences en [compétence 1], [compétence 2] et [compétence 3]. Mon expérience en [projet/stage] m'a permis de [réalisation concrète]."

**§3 - NOUS (La collaboration)** 🤝
Expliquez ce que vous apportez :
"Convaincu(e) que mes compétences en [domaine] peuvent contribuer à [objectif de l'entreprise], je serais ravi(e) de mettre mon [qualité] au service de votre équipe. Ce stage représente pour moi l'opportunité de [objectif d'apprentissage]."

**Règles d'or** ⭐
✓ Maximum 1 page
✓ Français impeccable (0 faute)
✓ Personnalisez pour chaque entreprise
✓ Soyez concret et factuel
✓ Restez professionnel mais humain
✓ Terminez par une formule de politesse classique

**Formule de fin** 👔
"Je reste à votre disposition pour un entretien et vous prie d'agréer, Madame, Monsieur, l'expression de mes salutations distinguées."

Voulez-vous voir un exemple complet ? Utilisez le menu en haut à droite !
''';
    }
    
    if (lowerMessage.contains('cv')) {
      return '''
📄 **Créer un CV professionnel qui marque**

**Les sections essentielles** 📋

**1. En-tête** 👤
• Prénom NOM (en gras, plus grand)
• Titre professionnel / Domaine d'études
• Email professionnel
• Téléphone
• LinkedIn (optionnel)
• Ville, Pays

**2. Profil professionnel** 💡
3-4 lignes percutantes :
"Étudiant(e) en [formation], passionné(e) par [domaine], avec une expérience en [compétence]. Recherche un stage en [domaine] pour développer mes compétences en [objectif]."

**3. Formation** 🎓
• Diplôme en cours (avec année prévue)
• Établissement, ville
• Spécialisation
• Diplômes précédents

**4. Expériences** 💼
Pour chaque expérience :
• Période (Mois/Année - Mois/Année)
• Poste - Entreprise, Ville
• 3-5 points clés avec verbes d'action
• Résultats quantifiés si possible

**5. Compétences** 🛠️
• Techniques : logiciels, langages, outils
• Linguistiques : Français (natif), Anglais (niveau)
• Transversales : travail d'équipe, communication...

**6. Projets** (optionnel) 🚀
• Projets académiques significatifs
• Technologies utilisées
• Résultats obtenus

**Conseils de mise en page** 🎨
✓ 1 page maximum (étudiant)
✓ Police lisible (Arial, Calibri) 10-11pt
✓ Marges équilibrées (2cm)
✓ Sections bien délimitées
✓ Utilisation de puces (•)
✓ Pas de photo (sauf demandé)
✓ Export en PDF

**Erreurs à éviter** ❌
✗ Fautes d'orthographe
✗ Informations non pertinentes
✗ CV trop chargé
✗ Mensonges sur compétences
✗ Email non professionnel

Consultez le menu pour voir une structure complète !

💡 **Astuce** : Pour créer rapidement un CV, utilisez :
• Canva (modèles gratuits)
• WebCV
• LinkedIn (exportation PDF)
''';
    }
    
    if (lowerMessage.contains('organis') || lowerMessage.contains('étud')) {
      return '''
📚 **S'organiser pour réussir ses études**

**1. Planning hebdomadaire** 📅
• Bloquez des créneaux fixes pour chaque matière
• Alternez matières difficiles et faciles
• Prévoyez des pauses régulières
• Gardez du temps pour les imprévus

**2. Méthode de travail efficace** 💪
• **Pomodoro** : 25min de travail + 5min de pause
• Éliminez les distractions (téléphone en mode avion)
• Créez un espace de travail dédié
• Travaillez en groupe pour certaines matières

**3. Prise de notes** ✍️
• Méthode Cornell ou Mind Mapping
• Relisez vos notes le soir même
• Complétez avec des ressources en ligne
• Créez des fiches de révision au fur et à mesure

**4. Gestion des priorités** 🎯
Utilisez la matrice d'Eisenhower :
• **Urgent + Important** : À faire immédiatement
• **Important mais pas urgent** : À planifier
• **Urgent mais pas important** : À déléguer/limiter
• **Ni urgent ni important** : À éliminer

**5. Équilibre vie étudiante** ⚖️
• Sommeil : 7-8h par nuit minimum
• Sport : 30min 3x par semaine
• Loisirs : Gardez du temps pour vous
• Social : Maintenez vos relations

**6. Outils recommandés** 🛠️
• **Notion** : Organisation générale
• **Google Calendar** : Planning
• **Forest** : Focus et concentration
• **Anki** : Mémorisation espacée

**Planning type étudiant** 📋
```
Lundi - Vendredi :
6h-7h : Réveil, routine
8h-12h : Cours
12h-14h : Pause déjeuner
14h-17h : Cours/TD
17h-19h : Révisions/Devoirs
19h-20h : Sport/Détente
20h-21h : Dîner
21h-23h : Révisions légères/Loisirs
23h : Coucher

Week-end :
Samedi matin : Révisions intensives
Samedi après-midi : Loisirs
Dimanche : Révisions + préparation semaine
```

Quelle partie voulez-vous approfondir ?
''';
    }
    
    if (lowerMessage.contains('ue') || lowerMessage.contains('unité') || lowerMessage.contains('valider')) {
      return '''
✅ **Stratégie pour valider toutes vos UE**

**Analyse de départ** 📊
1. Listez toutes vos UE avec leurs coefficients
2. Identifiez vos points forts et faibles
3. Calculez la moyenne minimum requise par UE
4. Priorisez selon les coefficients

**Plan d'action par UE** 🎯

**Pour les UE difficiles :**
• Commencez les révisions tôt (dès le début du semestre)
• Assistez à TOUS les cours et TD
• Formez un groupe d'étude
• Consultez le professeur en cas de blocage
• Faites tous les exercices et annales

**Pour les UE moyennes :**
• Travail régulier mais modéré
• Focus sur les points essentiels
• Entraînement avec anciens sujets

**Pour les UE faciles :**
• Maintien d'une bonne note
• Peu de temps mais régularité
• Ce sont vos "filets de sécurité"

**Calcul stratégique** 🧮
```
Moyenne UE = (Note CC × Coef CC) + (Note Exam × Coef Exam)
            ───────────────────────────────────────────
                        Coef CC + Coef Exam

Moyenne Semestre = Σ (Moyenne UE × Coefficient UE)
                   ──────────────────────────────
                        Σ Coefficients UE
```

**Stratégie de compensation** ⚖️
• Identifiez les UE où vous pouvez exceller (15-18/20)
• Elles compenseront les UE plus difficiles
• Visez 12/20 minimum partout
• Évitez les notes éliminatoires (<8/20)

**Planning de révisions** 📅
**6 semaines avant examen :**
• Semaine 1-2 : Reprise des cours
• Semaine 3-4 : Fiches et exercices
• Semaine 5 : Annales et simulation
• Semaine 6 : Révisions ciblées

**Pendant la session** 🎓
• Commencez par vos UE les plus difficiles
• Espacez vos révisions (pas de bourrage)
• Dormez bien avant chaque examen
• Gérez votre stress (respiration, sport)

**Après chaque examen** ✓
• Ne ressassez pas
• Passez à la suivante immédiatement
• Gardez confiance jusqu'à la fin

**En cas de rattrapage** 🔄
• Analysez vos erreurs
• Focus sur les points manqués
• Révisez plus stratégiquement
• Consultez les corrections si disponibles

Quelle UE vous pose problème actuellement ?
''';
    }
    
    if (lowerMessage.contains('plan') && lowerMessage.contains('travail')) {
      return '''
📋 **Élaborer un plan de travail efficace**

**Modèle de plan de travail sur 1 semestre**

**Phase 1 : Définition des objectifs (Semaine 1)** 🎯
• Listez toutes vos UE avec coefficients
• Fixez un objectif de moyenne par UE
• Identifiez les deadlines importantes
• Définissez vos priorités

**Phase 2 : Organisation (Semaine 2-14)** 📚

**Planning hebdomadaire type :**
```
LUNDI
8h-12h : Cours
14h-16h : Révision cours de la semaine
16h-18h : Exercices Maths/Physique

MARDI
8h-12h : Cours
14h-17h : TD/TP
17h-19h : Travail de groupe

MERCREDI
8h-12h : Cours
14h-16h : Bibliothèque (lectures)
16h-18h : Exercices à rendre

JEUDI
8h-12h : Cours
14h-17h : TD/TP
17h-19h : Révisions générales

VENDREDI
8h-12h : Cours
14h-17h : Avance sur devoirs
17h-19h : Fiches de révision

SAMEDI
9h-13h : Révisions intensives
14h-17h : Projets personnels/Loisirs

DIMANCHE
10h-13h : Révisions légères
14h-18h : Repos/Préparation semaine
```

**Outils de suivi** 📊
• **Tableau Excel** : Suivi des notes
• **Trello/Notion** : Tâches par matière
• **Google Agenda** : Deadlines et examens
• **Feuille de progression** : Chapitres validés

**Exemple de feuille de suivi :**
```
UE : Analyse Mathématique
Objectif : 14/20
Coefficient : 6

Chapitre 1 : Limites         ✅ Compris
Chapitre 2 : Dérivées        ✅ Compris
Chapitre 3 : Intégrales      🔄 En cours
Chapitre 4 : Séries          ⏸️ À faire

Exercices faits : 45/80
TD rendus : 3/4
Note CC : 13/20
```

**Phase 3 : Révisions finales (3 semaines avant)** 📖
```
Semaine -3 : Reprise complète des cours
Semaine -2 : Exercices types et annales
Semaine -1 : Simulations d'examen
```

**Indicateurs de réussite** ✅
• Assistez à 95%+ des cours
• Rendez 100% des devoirs
• Faites 80%+ des exercices
• Révisez chaque soir (30min minimum)
• 1 fiche par chapitre
• Groupes d'étude 1-2x/semaine

**Ajustements en cours de route** 🔄
Chaque mois :
• Analysez vos notes obtenues
• Ajustez le temps par matière
• Identifiez ce qui ne fonctionne pas
• Adaptez votre méthode

**Gestion des imprévus** ⚠️
• Gardez 20% de temps libre
• Prévoyez des "journées buffer"
• Soyez flexible mais discipliné

Voulez-vous que je vous aide à créer votre plan personnalisé ?
''';
    }
    
    if (lowerMessage.contains('professionnel') || lowerMessage.contains('carrière') || lowerMessage.contains('emploi')) {
      return '''
🎯 **Préparer sa vie professionnelle dès maintenant**

**Pendant vos études (Années 1-3)** 🎓

**1. Construction du profil** 👤
• Créez votre LinkedIn dès la 1ère année
• Développez votre réseau professionnel
• Participez aux événements de votre école
• Rejoignez des associations étudiantes

**2. Expériences terrain** 💼
• Stage de 1ère année : Découverte
• Stage de 2ème année : Approfondissement
• Stage de 3ème année : Pré-embauche
• Jobs étudiants pertinents
• Projets personnels à montrer

**3. Compétences à développer** 🛠️
**Techniques :**
• Maîtrise des outils de votre domaine
• Anglais professionnel (TOEIC 750+)
• Pack Office avancé
• Outils collaboratifs (Slack, Teams)

**Soft skills :**
• Communication orale et écrite
• Travail en équipe
• Gestion de projet
• Leadership
• Résolution de problèmes

**En fin d'études (Dernière année)** 🎯

**4. Préparation intensive** 📋
```
6 mois avant :
✓ CV parfait et à jour
✓ Lettre de motivation type
✓ Portfolio de projets
✓ LinkedIn optimisé
✓ Liste d'entreprises cibles

3 mois avant :
✓ Candidatures actives (20+)
✓ Participation forums emploi
✓ Préparation entretiens
✓ Activations du réseau
✓ Veille emploi quotidienne

1 mois avant :
✓ Relances téléphoniques
✓ Simulation d'entretiens
✓ Finalisation portfolio
✓ Révision questions techniques
```

**5. Recherche d'emploi** 🔍
**Canaux à exploiter :**
• Sites d'emploi togolais (EmploiTogo, etc.)
• LinkedIn Jobs
• Sites des entreprises
• Réseaux d'anciens élèves
• Candidatures spontanées
• Cabinets de recrutement
• Recommandations professeurs

**6. Entretiens** 🎤
**Préparez-vous sur :**
• Présentation de vous en 3 minutes
• Vos forces et faiblesses
• Vos réalisations concrètes (méthode STAR)
• Vos connaissances de l'entreprise
• Vos questions à poser
• Vos prétentions salariales

**Méthode STAR pour les réponses :**
• **S**ituation : Contexte
• **T**âche : Votre mission
• **A**ction : Ce que vous avez fait
• **R**ésultat : Les résultats obtenus

**7. Premier emploi** 💼
**Critères de choix :**
✓ Opportunités d'apprentissage
✓ Perspectives d'évolution
✓ Culture d'entreprise
✓ Équilibre vie pro/perso
✓ Rémunération (pas le seul critère)

**Les 100 premiers jours :**
• Soyez ponctuel et professionnel
• Observez et apprenez
• Posez des questions
• Créez des relations
• Montrez votre valeur
• Demandez des feedbacks

**8. Plan de carrière** 🚀
```
Années 1-2 : Apprentissage intensif
Années 3-5 : Montée en compétences
Années 5-7 : Expertise et leadership
Années 7-10 : Management/Spécialisation

Points de contrôle annuels :
✓ Compétences acquises
✓ Réseau développé
✓ Salaire évolution
✓ Satisfaction professionnelle
```

**9. Formation continue** 📚
• Certifications professionnelles
• MOOCs et formations en ligne
• Conférences et séminaires
• Veille technologique constante
• Mentorat (être mentoré puis mentorer)

**10. Réseau professionnel** 🤝
• Cultivez vos relations
• Donnez avant de recevoir
• Restez en contact avec anciens collègues
• Participez aux événements pro
• Partagez vos connaissances

Dans quel domaine souhaitez-vous vous spécialiser ?
''';
    }
    
    // Réponse par défaut
    return '''
Je suis Miabé ASSISTANT, votre expert en génie et technologie ! 🤖

Je peux vous aider avec :

📝 **Rapports de stage** - Structure, rédaction, exemples
💼 **Recherche de stage** - Étapes, candidatures, entretiens
✉️ **Lettres de motivation** - Rédaction efficace avec exemples
📄 **CV professionnels** - Structure, conseils, outils
📚 **Organisation des études** - Planning, méthodes de travail
✅ **Validation des UE** - Stratégies, calculs, planification
📋 **Plans de travail** - Organisation semestrielle
🎯 **Vie professionnelle** - Préparation carrière, réseautage

💡 Essayez de me poser une question comme :
• "Comment rédiger un rapport de stage ?"
• "Aide-moi à trouver un stage"
• "Comment faire une lettre de motivation ?"
• "Conseils pour organiser mes révisions"

Ou utilisez les suggestions ci-dessous ! ⬇️

---
🤖 *Mode démonstration actif*
Pour activer l'API Mistral réelle, consultez API_CONFIGURATION.md
''';
  }

  /// Génère des suggestions de questions pour démarrer la conversation
  static List<String> getSuggestions() {
    return [
      "Comment rédiger un bon rapport de stage ?",
      "Quelles sont les étapes pour trouver un stage ?",
      "Aide-moi à écrire une lettre de motivation",
      "Comment créer un CV professionnel ?",
      "Comment bien organiser mes études ?",
      "Comment valider toutes mes UE ?",
      "Aide-moi à faire un plan de travail",
      "Comment préparer ma vie professionnelle ?",
    ];
  }

  /// Exemples de documents à fournir aux étudiants
  static Map<String, String> getDocumentTemplates() {
    return {
      'rapport_stage': '''
📄 STRUCTURE D'UN RAPPORT DE STAGE

1. PAGE DE GARDE
   - Nom de l'établissement
   - Titre du stage
   - Nom et prénom de l'étudiant
   - Année académique

2. REMERCIEMENTS
   - Remerciez votre tuteur académique
   - Votre maître de stage
   - L'équipe qui vous a accueilli

3. SOMMAIRE
   - Liste des chapitres et sous-chapitres
   - Numérotation des pages

4. INTRODUCTION
   - Contexte du stage
   - Objectifs poursuivis
   - Problématique
   - Annonce du plan

5. PRÉSENTATION DE L'ENTREPRISE
   - Historique
   - Activités
   - Organisation
   - Positionnement

6. MISSIONS RÉALISÉES
   - Description détaillée de vos tâches
   - Méthodologie utilisée
   - Outils et technologies
   - Résultats obtenus

7. ANALYSE ET BILAN
   - Compétences acquises
   - Difficultés rencontrées
   - Solutions apportées
   - Apport du stage

8. CONCLUSION
   - Synthèse de l'expérience
   - Perspectives professionnelles
   - Ouverture

9. BIBLIOGRAPHIE
10. ANNEXES

📏 NORMES DE PRÉSENTATION :
- Police: Times New Roman 12pt
- Interligne: 1.5
- Marges: 2.5cm
- Nombre de pages: 30-50 pages
''',
      
      'lettre_motivation': '''
📧 STRUCTURE D'UNE LETTRE DE MOTIVATION

[Vos Nom et Prénom]
[Votre adresse]
[Ville, Code postal]
[Email]
[Téléphone]

[Nom de l'entreprise]
[Service/Département]
[Adresse]
[Ville, Code postal]

À [Ville], le [Date]

Objet : Candidature pour [poste/stage]

Madame, Monsieur,

§1 - VOUS (L'entreprise)
Montrez que vous connaissez l'entreprise :
- Son secteur d'activité
- Ses valeurs
- Ses projets récents
- Pourquoi elle vous intéresse

§2 - MOI (Vos compétences)
Présentez votre parcours :
- Formation actuelle
- Compétences pertinentes
- Expériences significatives
- Qualités personnelles

§3 - NOUS (La collaboration)
Expliquez ce que vous apportez :
- En quoi vos compétences répondent aux besoins
- Votre motivation pour le poste
- Ce que vous souhaitez apprendre
- Votre valeur ajoutée

CONCLUSION
- Remerciement
- Disponibilité pour un entretien
- Formule de politesse

Je vous prie d'agréer, Madame, Monsieur, l'expression de mes salutations distinguées.

[Signature manuscrite]
[Nom Prénom]

💡 CONSEILS :
- Maximum 1 page
- Police professionnelle (Arial, Calibri)
- Personnalisez pour chaque candidature
- Relisez plusieurs fois
- Faites relire par un tiers
''',
      
      'cv_structure': '''
📋 STRUCTURE D'UN CV PROFESSIONNEL

EN-TÊTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[VOTRE NOM] [Prénom]
[Titre professionnel / Domaine d'études]

📧 email@example.com | 📱 +228 XX XX XX XX
🌍 LinkedIn | Portfolio (si applicable)
📍 Ville, Pays

PROFIL PROFESSIONNEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Résumé percutant de 3-4 lignes présentant :
- Votre formation actuelle
- Vos compétences clés
- Vos objectifs professionnels

FORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Année] - [Diplôme préparé]
         [Établissement], [Ville]
         - Spécialisation
         - Projets majeurs

[Année] - [Diplôme obtenu]
         [Établissement], [Ville]

EXPÉRIENCES PROFESSIONNELLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Mois/Année] - [Mois/Année]
[Poste] - [Entreprise], [Ville]
• Réalisation 1 (quantifiée si possible)
• Réalisation 2
• Compétence développée

COMPÉTENCES TECHNIQUES
━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Informatique: [Logiciels, langages]
• Outils: [Outils métier]
• Langues: Français (natif), Anglais (niveau)

PROJETS ACADÉMIQUES
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Titre du projet] - [Année]
Description succincte + Technologies utilisées

CENTRES D'INTÉRÊT
━━━━━━━━━━━━━━━━━━━━━━━━━━━
(Activités qui montrent des compétences transférables)

✅ RÈGLES D'OR :
- 1 page maximum (2 si > 5 ans d'expérience)
- Police lisible (Calibri, Arial) 10-11pt
- Marges équilibrées
- Pas de photo (sauf demandé)
- Format PDF pour l'envoi
- Nom de fichier: Nom_Prenom_CV.pdf
''',
    };
  }
}
