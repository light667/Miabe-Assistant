const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const fetch = require('node-fetch');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gtnyqqstqfwvncnymptm.supabase.co';
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE || process.env.SERVICE_ROLE_KEY || '';

// Middleware de sécurité
app.use(helmet());
// Enable CORS: allow requests from development origins and echo origin for browsers.
// Using a permissive origin: true is safe for local development (it reflects the request origin).
// For production, replace with a strict origin list.
app.use(cors({
  origin: true,
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

// Upsert campus member using Supabase service role (backend-side)
app.post('/api/members', async (req, res) => {
  try {
    const payload = req.body;
    if (!payload || !payload.user_id) return res.status(400).json({ error: 'user_id is required' });

    if (!SUPABASE_SERVICE_ROLE) return res.status(500).json({ error: 'Supabase service role key not configured' });

    const resp = await fetch(`${SUPABASE_URL}/rest/v1/campus_members?on_conflict=user_id`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_SERVICE_ROLE,
        'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
        'Prefer': 'resolution=merge-duplicates'
      },
      body: JSON.stringify([payload])
    });

    const text = await resp.text();
    if (!resp.ok) return res.status(resp.status).send(text);
    return res.status(200).send(text);
  } catch (e) {
    console.error('Error /api/members', e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Create a post via Supabase service role
app.post('/api/posts', async (req, res) => {
  try {
    const payload = req.body;
    if (!payload) return res.status(400).json({ error: 'payload required' });
    if (!SUPABASE_SERVICE_ROLE) return res.status(500).json({ error: 'Supabase service role key not configured' });

    const resp = await fetch(`${SUPABASE_URL}/rest/v1/campus_posts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_SERVICE_ROLE,
        'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
        'Prefer': 'return=representation'
      },
      body: JSON.stringify([payload])
    });

    const text = await resp.text();
    if (!resp.ok) return res.status(resp.status).send(text);
    return res.status(200).send(text);
  } catch (e) {
    console.error('Error /api/posts', e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Create a fiche via Supabase service role
app.post('/api/fiches', async (req, res) => {
  try {
    const payload = req.body;
    if (!payload) return res.status(400).json({ error: 'payload required' });
    if (!SUPABASE_SERVICE_ROLE) return res.status(500).json({ error: 'Supabase service role key not configured' });

    const resp = await fetch(`${SUPABASE_URL}/rest/v1/campus_fiches`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_SERVICE_ROLE,
        'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
        'Prefer': 'return=representation'
      },
      body: JSON.stringify([payload])
    });

    const text = await resp.text();
    if (!resp.ok) return res.status(resp.status).send(text);
    return res.status(200).send(text);
  } catch (e) {
    console.error('Error /api/fiches', e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Upload file proxy: accepts JSON { bucket, path, content_base64, content_type }
app.post('/api/upload', async (req, res) => {
  try {
    const { bucket, path, content_base64, content_type } = req.body;
    if (!bucket || !path || !content_base64) return res.status(400).json({ error: 'bucket, path and content_base64 are required' });
    if (!SUPABASE_SERVICE_ROLE) return res.status(500).json({ error: 'Supabase service role key not configured' });

    const buffer = Buffer.from(content_base64, 'base64');
    const uploadUrl = `${SUPABASE_URL}/storage/v1/object/${bucket}/${path}`;

    const resp = await fetch(uploadUrl, {
      method: 'PUT',
      headers: {
        'Content-Type': content_type || 'application/octet-stream',
        'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
        'apikey': SUPABASE_SERVICE_ROLE
      },
      body: buffer
    });

    const text = await resp.text();
    if (!resp.ok) return res.status(resp.status).send(text);

    // Build public URL (if bucket is public) or return path for further processing
    const publicUrl = `${SUPABASE_URL}/storage/v1/object/public/${bucket}/${path}`;
    return res.json({ publicUrl });
  } catch (e) {
    console.error('Error /api/upload', e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// Clear all posts (dangerous) - protected by a simple env flag
app.post('/api/clear_posts', async (req, res) => {
  try {
    if (process.env.ALLOW_CLEAR !== '1') return res.status(403).json({ error: 'Clear not allowed' });
    if (!SUPABASE_SERVICE_ROLE) return res.status(500).json({ error: 'Supabase service role key not configured' });

    const resp = await fetch(`${SUPABASE_URL}/rest/v1/campus_posts`, {
      method: 'DELETE',
      headers: {
        'apikey': SUPABASE_SERVICE_ROLE,
        'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE}`,
        'Content-Type': 'application/json'
      }
    });

    const text = await resp.text();
    if (!resp.ok) return res.status(resp.status).send(text);
    return res.json({ status: 'cleared', detail: text });
  } catch (e) {
    console.error('Error /api/clear_posts', e);
    return res.status(500).json({ error: 'Server error' });
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
