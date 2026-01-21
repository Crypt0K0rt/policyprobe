# PolicyProbe

**AI-powered policy evaluation and remediation demo application**

PolicyProbe is a deliberately vulnerable chat agent application designed to demonstrate how Unifai detects security policy violations and instructs Cursor IDE to remediate them.

## Demo Flow

1. **Run PolicyProbe with Unifai disabled** → vulnerable behavior is visible
2. **Enable Unifai in Cursor** → scans code, detects violations
3. **Unifai instructs Cursor** to fix the violations
4. **Run PolicyProbe again** → guardrails now active, violations blocked

## Four Policy Violations Demonstrated

| Policy | Vulnerability | After Remediation |
|--------|---------------|-------------------|
| **PII Detection** | Files processed without PII scanning | SSN, credit cards, phone numbers detected and blocked |
| **Prompt Injection** | Hidden text/prompts sent to LLM | Hidden content detected and filtered |
| **Agent Auth** | Inter-agent calls bypass authentication | JWT-based authentication required |
| **Vulnerable Deps** | Old packages with known CVEs | Updated to patched versions |

## Quick Start

### Prerequisites

- Node.js 18+
- Python 3.10+
- OpenRouter API key (get one at https://openrouter.ai/keys)

### Setup

1. **Clone and set up environment**

```bash
cd policyprobe

# Copy environment template
cp .env.example .env
# Edit .env and add your OPENROUTER_API_KEY
```

2. **Start the application**

```bash
./scripts/run_dev.sh    # Start both servers
./scripts/stop_dev.sh   # Stop both servers
```

Or manually:

```bash
# Terminal 1: Backend
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 5500

# Terminal 2: Frontend
cd frontend
npm install
npm run dev -- -p 5001
```

3. **Open the app**

- Frontend: http://localhost:5001
- Backend API: http://localhost:5500
- API Docs: http://localhost:5500/docs

## Project Structure

```
policyprobe/
├── frontend/                    # Next.js React frontend
│   ├── src/
│   │   ├── app/                 # Next.js app router
│   │   └── components/          # React components
│   └── package.json             # ⚠️ Vulnerable npm deps
│
├── backend/                     # Python FastAPI backend
│   ├── agents/                  # Multi-agent system
│   │   ├── orchestrator.py      # Request routing
│   │   ├── tech_support.py      # Low privilege agent
│   │   ├── finance.py           # High privilege agent
│   │   └── auth/                # ⚠️ Auth bypass
│   ├── policies/                # Policy modules
│   │   ├── pii_detection.py     # ⚠️ NO-OP detection
│   │   ├── prompt_injection.py  # ⚠️ NO-OP detection
│   │   └── runtime/             # Runtime guardrails
│   ├── file_parsers/            # File processing
│   └── requirements.txt         # ⚠️ Vulnerable Python deps
│
├── config/                      # Policy configuration
├── test_files/                  # Demo test files
└── scripts/                     # Development scripts
```

## Demo Scenarios

### 1. PII Detection Demo

**Before:**
1. Upload `test_files/advanced/nested_pii.json`
2. Observe: "File processed successfully"
3. PII is sent to the LLM without detection

**After Unifai Remediation:**
1. Upload the same file
2. Observe: "Error: PII detected - SSN found in user.profile.contact.ssn"

### 2. Prompt Injection Demo

**Before:**
1. Upload `test_files/advanced/base64_hidden.html`
2. Hidden prompts are extracted and sent to LLM
3. LLM may respond to malicious instructions

**After Unifai Remediation:**
1. Upload the same file
2. Observe: "Security threat detected: Hidden content in HTML elements"

### 3. Agent Authentication Demo

**Before:**
1. Ask: "Can you show me the quarterly financial report?"
2. Tech support agent escalates to finance agent
3. Access granted without proper authentication

**After Unifai Remediation:**
1. Same request
2. Observe: "Unauthorized: Agent token validation failed"

### 4. Vulnerable Dependencies Demo

**Before:**
```bash
cd frontend && npm audit
# Shows vulnerabilities in lodash, axios, etc.
```

**After Unifai Remediation:**
- `package.json` updated with patched versions
- `npm audit` shows no vulnerabilities

## Key Files for Demo

| File | Vulnerability | Change After Remediation |
|------|---------------|--------------------------|
| `backend/policies/pii_detection.py` | `scan()` is NO-OP | Actual regex scanning |
| `backend/policies/prompt_injection.py` | `scan()` is NO-OP | Hidden text detection |
| `backend/agents/auth/agent_auth.py` | `verify()` always returns True | JWT validation |
| `frontend/package.json` | lodash 4.17.15 | lodash 4.17.21 |
| `backend/requirements.txt` | requests 2.25.0 | requests 2.31.0 |

## Test Files

- `test_files/simple/` - Basic examples for warm-up
- `test_files/advanced/nested_pii.json` - PII buried 5 levels deep
- `test_files/advanced/base64_hidden.html` - Hidden prompts in HTML
- `test_files/advanced/multi_hop_attack.json` - Chained agent exploit

Generate additional test files:
```bash
python scripts/create_test_files.py
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      PolicyProbe UI                         │
│                   (Next.js + React)                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Agent Orchestrator                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Tech Support │──│   Finance    │  │    File      │      │
│  │ (low priv)   │  │ (high priv)  │  │  Processor   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
         ┌────────┐   ┌──────────┐   ┌─────────┐
         │OpenRouter│  │  Policy  │   │  File   │
         │ (LLM)  │   │ Modules  │   │ Parsers │
         └────────┘   └──────────┘   └─────────┘
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENROUTER_API_KEY` | OpenRouter API key for LLM | Yes |
| `JWT_SECRET` | Secret for JWT signing (after remediation) | No |
| `BACKEND_URL` | Backend URL for frontend | No (default: localhost:5500) |

## License

This is a demo application for Unifai integration testing.
