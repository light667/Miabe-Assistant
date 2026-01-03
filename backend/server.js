const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const fetch = require('node-fetch');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware de sécurité
app.use(helmet());
app.use(cors({
  origin: [
    'https://YOUR_NEW_PROJECT_ID.web.app',
    'https://YOUR_NEW_PROJECT_ID.firebaseapp.com',
    'http://localhost:*',
    /\.web\.app$/,
    /\.firebaseapp\.com$/
  ],
  credentials: true
}));
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limite à 100 requêtes par IP
  message: 'Trop de requêtes, veuillez réessayer plus tard.'
});
app.use('/api/', limiter);

// Prompt système pour le chatbot
const SYSTEM_PROMPT = `Tu es PolyAssistant, l'assistant virtuel officiel de l'IUT de Béjaia. 
Tu es un assistant bienveillant, professionnel et pédagogique qui aide les étudiants et le personnel de l'établissement.

**Tes missions :**
✅ Répondre aux questions sur les formations, départements, et programmes
✅ Aider avec les cours, exercices et révisions
✅ Donner des conseils pour l'organisation et la réussite académique
✅ Fournir des informations pratiques sur la vie étudiante

**Ton comportement :**
• Toujours courtois et encourageant
• Utilise des emojis pour rendre les réponses agréables 📚 ✨
• Structure tes réponses de manière claire (listes, sections)
• Adapte ton niveau de détail selon la question
• Si tu ne sais pas, dis-le honnêtement

**Important :**
• Tu es spécialisé dans l'enseignement supérieur technique (IUT)
• Tu connais les départements : Génie Civil, Génie Électrique, Génie Mécanique, IA & Big Data, Informatique & Systèmes, Logistique & Transport
• Tu fournis des réponses précises et vérifiables
• Tu encourages l'autonomie et l'apprentissage actif`;

// Route de santé
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    service: 'PolyAssistant Backend'
  });
});

// Route principale du chatbot
app.post('/api/chatbot', async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ 
        error: 'Le message est requis et doit être une chaîne de caractères.' 
      });
    }

    const mistralApiKey = process.env.MISTRAL_API_KEY;
    
    if (!mistralApiKey) {
      console.error('MISTRAL_API_KEY non configurée');
      return res.status(500).json({ 
        error: 'Configuration serveur manquante.' 
      });
    }

    // Construire l'historique de conversation
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT }
    ];

    // Ajouter l'historique (limité aux 10 derniers messages)
    const recentHistory = conversationHistory.slice(-10);
    messages.push(...recentHistory);

    // Ajouter le nouveau message
    messages.push({ role: 'user', content: message });

    // Appel à l'API Mistral
    const response = await fetch('https://api.mistral.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${mistralApiKey}`
      },
      body: JSON.stringify({
        model: 'mistral-small-latest',
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Erreur API Mistral:', response.status, errorText);
      return res.status(response.status).json({ 
        error: `Erreur API Mistral: ${response.status}` 
      });
    }

    const result = await response.json();
    
    if (!result.choices || result.choices.length === 0) {
      return res.status(500).json({ 
        error: 'Aucune réponse reçue de l\'API Mistral' 
      });
    }

    res.json({
      response: result.choices[0].message.content,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Erreur chatbot:', error);
    res.status(500).json({ 
      error: 'Erreur lors du traitement de votre message.' 
    });
  }
});

// Route 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
  console.log(`📡 API disponible sur http://localhost:${PORT}`);
  console.log(`✅ Santé: http://localhost:${PORT}/health`);
  console.log(`💬 Chatbot: POST http://localhost:${PORT}/api/chatbot`);
});
