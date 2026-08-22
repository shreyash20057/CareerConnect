const functions = require('firebase-functions');
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic({
  apiKey: functions.config().anthropic.key,
});

exports.careerAssistant = functions
  .runWith({ timeoutSeconds: 60, memory: '256MB' })
  .https.onRequest(async (req, res) => {
    // CORS
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { message, history = [], systemContext } = req.body;

      if (!message) {
        res.status(400).json({ error: 'Message is required' });
        return;
      }

      // Build messages array
      const messages = [
        ...history.map(h => ({
          role: h.role,
          content: h.content,
        })),
        { role: 'user', content: message },
      ];

      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-6',
        max_tokens: 1024,
        system: systemContext || 'You are CareerConnect AI, a helpful career assistant for students and job seekers.',
        messages,
      });

      const reply = response.content[0]?.text || 'I could not generate a response.';
      res.status(200).json({ reply });
    } catch (error) {
      console.error('AI error:', error);
      res.status(500).json({
        error: 'AI service error',
        reply: 'I encountered an error. Please try again.',
      });
    }
  });const functions = require('firebase-functions');
const Anthropic = require('@anthropic-ai/sdk');

const anthropic = new Anthropic({
  apiKey: functions.config().anthropic.key,
});

exports.careerAssistant = functions
  .runWith({ timeoutSeconds: 60, memory: '256MB' })
  .https.onRequest(async (req, res) => {
    // CORS
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { message, history = [], systemContext } = req.body;

      if (!message) {
        res.status(400).json({ error: 'Message is required' });
        return;
      }

      // Build messages array
      const messages = [
        ...history.map(h => ({
          role: h.role,
          content: h.content,
        })),
        { role: 'user', content: message },
      ];

      const response = await anthropic.messages.create({
        model: 'claude-sonnet-4-6',
        max_tokens: 1024,
        system: systemContext || 'You are CareerConnect AI, a helpful career assistant for students and job seekers.',
        messages,
      });

      const reply = response.content[0]?.text || 'I could not generate a response.';
      res.status(200).json({ reply });
    } catch (error) {
      console.error('AI error:', error);
      res.status(500).json({
        error: 'AI service error',
        reply: 'I encountered an error. Please try again.',
      });
    }
  });