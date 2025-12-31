# 🚀 CapitalYX — The AI-Powered Startup Funding Advisor

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Neo4j](https://img.shields.io/badge/Neo4j-008CC1?style=for-the-badge&logo=neo4j&logoColor=white)
![Pinecone](https://img.shields.io/badge/Pinecone-27272E?style=for-the-badge&logo=pinecone&logoColor=white)

---

## 📌 Overview

**CapitalYX** is an AI-powered startup funding advisor built to empower founders in **Tier-2 and Tier-3 Indian cities**.  
It transforms complex government policies, legal documents, and funding guidelines into **clear, verifiable, and actionable steps** tailored to each startup.

Built using **Flutter**, **Supabase**, and a **Hybrid GraphRAG architecture**, CapitalYX bridges the gap between massive policy documents and a founder’s real-world funding needs.

---

## 🌟 Key Features

### 1️⃣ Vernacular-First Interaction
- **Multilingual Support**: Global language selector for major Indic languages (Hindi, Tamil, Marathi, etc.)
- **Voice-to-Intent**: Founders can speak naturally using Google Cloud Speech-to-Text and Google Translate APIs

---

### 2️⃣ Hybrid GraphRAG Intelligence Engine
- **Semantic + Relational Search**  
  - Pinecone for high-speed semantic retrieval  
  - Neo4j for multi-hop legal and policy reasoning
- **Trust & Accuracy Layer**  
  - Every claim audited by an SLM using NLI-based faithfulness checks
- **Deep-Link Citations**  
  - Every response is grounded with direct citations to original PDF pages and clauses

---

### 3️⃣ Information → Action Layer
- **Dynamic Eligibility Checklists**  
  - Real-time comparison of founder profiles against grant and scheme rules
- **Agentic Form Filling**  
  - Pre-fills official government application PDFs using structured validation, reducing weeks of effort to minutes

---

### 4️⃣ Intelligent Startup Tools
- **Investor Matching**  
  - Matches startups with ideal investors based on sector, ticket size, and geography
- **Funding Readiness Score**  
  - AI-driven evaluation of team, product, market, and traction
- **Pitch Deck Analyzer**  
  - Tailored feedback for Angel or VC decks based on target funding stage

---

## 🛠️ Technical Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter | Cross-platform UI with dynamic theming |
| Backend & Auth | Supabase | PostgreSQL, Authentication, Storage |
| Orchestration | LangGraph | Stateful AI agent workflows |
| Vector Database | Pinecone | Semantic document retrieval |
| Graph Database | Neo4j | Legal and policy relationship modeling |
| Auditor | Llama 3.2 (SLM) | Hallucination detection and faithfulness checks |
| Expert LLM | GPT-4o | Complex synthesis and drafting |

---

## 📁 Project Structure

```bash
├── lib/
│   ├── core/          # Unified SLM Router & Theme Notifiers
│   ├── data/          # Supabase & API repository layers
│   ├── domain/        # Business logic & AI agent definitions
│   └── presentation/  # Flutter UI (Auth, Home, Feature Screens)
├── assets/            # Localized strings & icons
└── supabase/          # Edge Functions & database migrations

## Clone the Repository
```bash
git clone https://github.com/yourusername/CapitalYX.git
cd CapitalYX
```

## Install Dependencies
```bash
flutter pub get
```

## Configure Environment Variables
```bash
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GOOGLE_TRANSLATE_API_KEY=your_api_key
```

## Run the Application
```bash
flutter run
```

## 🤝 Contributing

Contributions are welcome!
Feel free to open an issue or submit a Pull Request to improve CapitalYX.

## 🌍 Vision

CapitalYX is not just a chatbot — it is a policy-grade AI funding assistant designed to turn bureaucratic complexity into founder action.
