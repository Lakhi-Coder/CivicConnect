const functions = require('firebase-functions');
const config = require('./config');

exports.newsProxy = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const { category, query, country = 'us', pageSize = '50' } = req.query;
  
  const NEWS_API_KEY = config.newsApiKey;
  
  try {
    let url;
    
    if (query) {
      url = `https://newsapi.org/v2/everything?q=${encodeURIComponent(query)}&language=en&sortBy=publishedAt&pageSize=${pageSize}&apiKey=${NEWS_API_KEY}`;
    } else if (category) {
      url = `https://newsapi.org/v2/top-headlines?country=${country}&category=${category}&pageSize=${pageSize}&apiKey=${NEWS_API_KEY}`;
    } else {
      url = `https://newsapi.org/v2/top-headlines?country=${country}&pageSize=${pageSize}&apiKey=${NEWS_API_KEY}`;
    }

    console.log('Fetching from NewsAPI');

    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`NewsAPI error: ${response.status}`);
    }
    
    const data = await response.json();
    res.json(data);
    
  } catch (error) {
    console.error('Proxy error:', error);
    res.status(500).json({ error: error.message });
  }
});