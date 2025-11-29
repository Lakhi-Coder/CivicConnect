![Branding](assets/graphics/branding.png)
*For demonstration purposes, CivicConnect utilizes free API tiers with inherent usage limitations. In a production environment, these services would be upgraded to commercial tiers to ensure uninterrupted access to all features showcased in the video demo.* 
# CivicConnect - AI-Powered Political Engagement Platform
## Project Description
CivicConnect is a comprehensive Flutter web application that revolutionizes how citizens engage with politics. By combining AI-powered news personalization with real-time legislative tracking, CivicConnect helps users stay informed about elections, bills, and political developments while learning their unique interests.

## What Problem We Solve
Most citizens struggle to stay informed about complex political processes. CivicConnect solves this by providing personalized news, AI explanations of legislation, and real-time bill tracking - all while learning your political interests to deliver increasingly relevant content.

## Key Features

### **Intelligent Home Dashboard**
- **Election Tracking**: Upcoming and trending elections
- **AI News Curation**: Major top stories selected by AI
- **Personalized Insights**: Reading recommendations based on your interests
- **Bill Monitoring**: Track bills that passed, were enacted, or are in progress

### **Smart News Experience**
- **AI Daily Briefings**: Daily summaries of major political topics
- **Interest-Based Personalization**: News feed that evolves with your reading habits
- **Real-time Interest Tracking**: Watch your topic preferences update as you read
- **Multi-Category Coverage**: Politics, Health, Science, Technology, Business, Sports, Entertainment

### **Comprehensive Legislative Tracking**
- **Bill Descriptions**: AI-generated explanations of legislation
- **Daily Updates**: Real-time bill status monitoring
- **Status Visualization**: Track bills through House, Senate, enactment, and beyond
- **Legislative Calendar**: Timeline of political events and bill progress

### **Advanced Discovery Tools**
- **Powerful Search Engine**: Find specific news articles immediately
- **Category Exploration**: Browse across diverse news categories
- **Reading History**: Manage your previously read articles
- **Smart Recommendations**: AI-suggested content based on your behavior

### **AI-Powered Assistance**
- **Direct AI Chat**: General political discussions in Suggestions page
- **Article-Specific Chat**: Discuss any news article with contextual AI
- **Political Expertise**: Get explanations of complex topics and legislation

## Live Demo
**Playable URL**: https://civicconnect-4012b.web.app/

*Note: For the full AI chat experience, please allow pop-ups when prompted*

## Demo Video
[Watch the complete app walkthrough](https://vimeo.com/1131954580)

## How to Use CivicConnect

### Getting Started
1. **Create Your Account**: Start at the Get Started page to sign up or login
2. **Secure Authentication**: Firebase authentication protects your account
3. **Personalized Experience**: Your account saves interests and reading history

### Homepage - Your Political Dashboard
- Browse upcoming elections and trending political news
- Read AI-curated top stories and personalized recommendations
- Monitor bill progress through government stages

### News Feed - Daily Briefing
- Check the AI's daily political summary
- Discover articles matching your evolving interests
- Stay updated on major current events

### Civic Calendar - Legislative Center
- Read detailed bill descriptions and status updates
- Track daily legislative developments
- Understand bill journey through House and Senate

### Explore & Discover
- Search for specific news articles immediately
- Browse diverse categories beyond politics
- Manage your reading history and preferences

### AI Chat Assistant
- Discuss general politics in Suggestions page
- Get article-specific context by clicking chat icons
- Receive explanations of complex political topics

## Technology Stack

**Frontend Development**
- Flutter Web - Cross-platform framework for web deployment
- Figma - UI/UX design and prototyping

**Backend & Core Technologies**  
- Dart - Primary programming language
- Google Gemini AI - Artificial intelligence for personalized recommendations and chat

**Cloud Infrastructure & Services**
- Firebase Hosting - Web application deployment
- Firebase Functions - Serverless backend and NewsAPI proxy
- Firebase Authentication - Secure user account management
- Cloud Firestore - Real-time database for user data and preferences

**APIs & Data Sources**
- NewsAPI.org - News articles via secure Firebase proxy
- Google Civic Information API - Government and election data
- Congress.gov API - Bill tracking and legislative information

## Quick Start
Simply visit https://civicconnect-4012b.web.app/ and create your account to start your personalized political journey!

## Development Setup
```bash
# Clone and run locally
git clone [your-repo-url]
flutter pub get
flutter run -d chrome

# Deploy to production
flutter build web --release
firebase deploy

## Challenges & Solutions

### API Integration
- **CORS Restrictions**: NewsAPI blocked direct browser access
- **Solution**: Implemented Firebase Functions as secure proxy
- **Multiple Data Sources**: Merged NewsAPI, Congress.gov, and Google Civic API into unified interface

### Firebase Configuration
- **Authentication**: Complex setup for secure user sign-in and session management
- **Data Security**: Configured Firestore rules for user-specific data access
- **Deployment Issues**: Node.js version compatibility and function deployment challenges

### AI Implementation
- **Multi-feature Integration**: Google Gemini AI for search, recommendations, and bill descriptions
- **Rate Limiting**: Managed API costs and usage during development
- **Prompt Engineering**: Developed accurate political context and explanations

### State Management
- **Complex User Data**: Managed preferences, reading history, and real-time interest tracking
- **Real-time Updates**: Synchronized interest percentages based on reading behavior
- **Data Persistence**: Handled offline states and cross-device synchronization

### UI/UX Design
- **Complex Information**: Designed intuitive interfaces for political data and bill tracking
- **Responsive Design**: Ensured consistent experience across all devices
- **Information Density**: Balanced comprehensive data with clean, engaging design

### Deployment & Production
- **Flutter Web Configuration**: Optimized for Firebase Hosting
- **Ad Blocker Interference**: AI chat windows blocked by popup filters
- **Performance Optimization**: Improved news loading and image handling

### Feature Integration
- **Real-time Learning**: Connected AI personalization with legislative tracking
- **Cohesive Experience**: Unified news reading with political engagement features
- **Performance Balance**: Maintained speed while adding rich functionality

