import os
import requests
import logging
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class NewsService:
    def __init__(self):
        self.news_api_key = os.getenv("NEWSAPI_KEY")
        self.base_url = "https://newsapi.org/v2/everything"

    def get_sentiment(self, query):
        """
        Naive sentiment analysis based on NewsAPI titles.
        Returns a float between -1 (Negative) and 1 (Positive).
        """
        if not self.news_api_key:
            return 0.0

        params = {
            "q": query,
            "from": (datetime.now() - timedelta(days=2)).strftime("%Y-%m-%d"),
            "sortBy": "popularity",
            "apiKey": self.news_api_key,
            "language": "en"
        }
        
        try:
            resp = requests.get(self.base_url, params=params)
            data = resp.json()
            if data.get('status') != 'ok':
                return 0.0
            
            articles = data.get('articles', [])
            if not articles:
                return 0.0
                
            # Simple keyword based sentiment (Replace with BERT/RoBERTa later)
            score = 0
            pos_words = ['surge', 'growth', 'record', 'high', 'profit', 'bull', 'gain']
            neg_words = ['drop', 'loss', 'crash', 'bear', 'fall', 'dump', 'crisis']
            
            count = 0
            for art in articles[:10]: # Analyze top 10
                title = art['title'].lower()
                for w in pos_words: 
                    if w in title: score += 1
                for w in neg_words: 
                    if w in title: score -= 1
                count += 1
            
            if count == 0: return 0.0
            
            # Normalize to -1 to 1
            normalized = score / count
            return max(min(normalized, 1.0), -1.0)
            
        except Exception as e:
            logger.error(f"News fetch error: {e}")
            return 0.0
