import http from 'node:http';

const port = Number(process.env.PORT || 8787);

// ============================================================
// TUTOR AI CONFIGURATION
// ============================================================

// TutorAI runs in cost-aware AUTO mode by default:
// - Gemini 2.5 Flash-Lite handles normal, high-volume student work.
// - DeepSeek V4.1 Flash handles harder reasoning when a DeepSeek key is configured.
// - Ollama remains an optional local fallback and is OFF unless explicitly enabled.
//
// Backward compatibility:
// The existing OPENAI_* variables are still accepted where they were previously
// used for the Gemini OpenAI-compatible endpoint. New deployments should use
// GEMINI_* and DEEPSEEK_* names instead.
const rawAiProvider = (process.env.AI_PROVIDER || 'auto').toLowerCase();
const aiProvider = rawAiProvider === 'openai' ? 'auto' : rawAiProvider;

const aiFallbackToDeepSeek = process.env.AI_FALLBACK_TO_DEEPSEEK !== 'false';
const aiFallbackToOllama = process.env.AI_FALLBACK_TO_OLLAMA !== 'false';

// -------------------------
// Google Gemini
// -------------------------

const legacyOpenAiBaseUrl = (process.env.OPENAI_BASE_URL || '').trim();
const defaultGeminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/openai';

const geminiBaseUrl = (
  process.env.GEMINI_BASE_URL ||
  (legacyOpenAiBaseUrl.includes('generativelanguage.googleapis.com')
    ? legacyOpenAiBaseUrl
    : defaultGeminiBaseUrl)
).replace(/\/+$/, '');

const geminiApiKey =
  process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY || '';

// Cost-first default. Set GEMINI_MODEL explicitly only when you intentionally
// want a different Gemini model.
const geminiModel = process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite';
const geminiSimpleModel =
  process.env.GEMINI_SIMPLE_MODEL || 'gemini-2.5-flash-lite';

// -------------------------
// DeepSeek
// -------------------------

const deepSeekBaseUrl = (
  process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com'
).replace(/\/+$/, '');

const deepSeekApiKey = process.env.DEEPSEEK_API_KEY || '';
const deepSeekModel = process.env.DEEPSEEK_MODEL || 'deepseek-flash';

// -------------------------
// Ollama fallback
// -------------------------

const ollamaBaseUrl = (
  process.env.OLLAMA_BASE_URL || 'http://127.0.0.1:11434/v1'
).replace(/\/+$/, '');

const ollamaApiKey = process.env.OLLAMA_API_KEY || 'ollama';
const ollamaModel = process.env.OLLAMA_MODEL || 'gemma3:1b';

// ============================================================
// HTTP HELPERS
// ============================================================

function send(res, status, payload) {
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'cache-control': 'no-store',
  });

  res.end(JSON.stringify(payload));
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let data = '';

    req.on('data', (chunk) => {
      data += chunk;

      if (data.length > 1024 * 1024) {
        req.destroy(new Error('Payload too large'));
      }
    });

    req.on('end', () => {
      try {
        resolve(JSON.parse(data || '{}'));
      } catch (error) {
        reject(error);
      }
    });

    req.on('error', reject);
  });
}

function normalizeText(value) {
  return String(value || '').trim();
}

// ============================================================
// SMART COST-AWARE MODEL ROUTING
// ============================================================

function isGenuinelySimpleChat(question) {
  const text = normalizeText(question).toLowerCase();

  if (!text || text.length > 120) {
    return false;
  }

  return /^(hi|hello|hey|thanks|thank you|good morning|good afternoon|good evening|who are you|what can you do|help)$/i.test(
    text,
  );
}

function needsDeeperReasoning(question) {
  const text = normalizeText(question).toLowerCase();

  const patterns = [
    'solve',
    'calculate',
    'work out',
    'derive',
    'prove',
    'simplify',
    'factorize',
    'factorise',
    'equation',
    'simultaneous',
    'quadratic',
    'trigonometry',
    'integration',
    'differentiate',
    'probability',
    'permutation',
    'combination',
    'physics calculation',
    'chemistry calculation',
    'balance the equation',
    'show that',
    'find x',
    'find y',
    'why does',
    'explain why',
    'compare and justify',
  ];

  return patterns.some((pattern) => text.includes(pattern));
}

function isFastFollowUp(question) {
  const text = normalizeText(question).toLowerCase();

  if (!text || text.length > 180) {
    return false;
  }

  // Keep calculations and other multi-step reasoning off the lightweight lane.
  if (needsDeeperReasoning(text)) {
    return false;
  }

  return /^(why|why did|why do|why is|why are|how|how did|how do|how is|how are|explain|can you explain|what does|what is)\b/.test(
    text,
  );
}

function geminiRoute({ purpose, question }) {
  const simple = purpose === 'follow-up' && isFastFollowUp(question);

  return {
    provider: 'gemini',
    model: simple ? geminiSimpleModel : geminiModel,
    reasoningEffort: 'low',
    maxOutputTokens:
      purpose === 'tutor'
        ? 1600
        : purpose === 'follow-up'
          ? simple
            ? 300
            : 500
          : purpose === 'chat'
            ? 900
            : 900,
    responseFormat: purpose === 'tutor' ? 'tutor-lesson' : null,
  };
}

function deepSeekRoute({ purpose, question }) {
  const hard = needsDeeperReasoning(question);

  return {
    provider: 'deepseek',
    model: deepSeekModel,
    reasoningEffort: hard ? 'high' : 'low',
    maxOutputTokens:
      purpose === 'tutor'
        ? 1600
        : purpose === 'follow-up'
          ? 500
          : 900,
    responseFormat: purpose === 'tutor' ? 'tutor-lesson-json' : null,
  };
}

function chooseAiRoute({ purpose, question }) {
  // Explicit local-only mode.
  if (aiProvider === 'ollama') {
    return {
      provider: 'ollama',
      model: ollamaModel,
      reasoningEffort: null,
      maxOutputTokens: purpose === 'tutor' ? 1600 : 900,
      responseFormat: null,
    };
  }

  // Explicit provider overrides are useful for diagnostics/testing.
  if (aiProvider === 'gemini') {
    return geminiRoute({ purpose, question });
  }

  if (aiProvider === 'deepseek') {
    return deepSeekRoute({ purpose, question });
  }

  // AUTO MODE:
  // Normal high-volume work stays on the cheapest Gemini Flash-Lite lane.
  // Hard reasoning uses DeepSeek V4.1-Flash when configured.
  if (needsDeeperReasoning(question) && aiFallbackToDeepSeek && deepSeekApiKey) {
    return deepSeekRoute({ purpose, question });
  }

  return geminiRoute({ purpose, question });
}

// ============================================================
// TUTOR LESSON RESPONSE SCHEMA
// ============================================================

// Gemini supports structured JSON output through the OpenAI-compatible
// endpoint. Using an explicit schema prevents free-form responses from
// reaching the Flutter client and removes the old schema-mismatch failure.
const tutorLessonSchema = {
  type: 'object',
  additionalProperties: false,
  properties: {
    question: { type: 'string' },
    topic: { type: 'string' },
    steps: {
      type: 'array',
      minItems: 1,
      items: {
        type: 'object',
        additionalProperties: false,
        properties: {
          title: { type: 'string' },
          body: { type: 'string' },
          why: { type: 'string' },
        },
        required: ['title', 'body', 'why'],
      },
    },
    answer: { type: 'string' },
    methodSummary: { type: 'string' },
    example: { type: 'string' },
    supported: { type: 'boolean' },
  },
  required: [
    'question',
    'topic',
    'steps',
    'answer',
    'methodSummary',
    'example',
    'supported',
  ],
};

// ============================================================
// TUTOR SYSTEM PROMPT
// ============================================================

function buildSystemPrompt() {
  return `You are TutorAI, a professional educational tutor for Primary, JSS, SSS, WAEC, NECO, JAMB and Post-UTME learners.

Your job is to teach the student, not merely produce an answer.

Teaching rules:

1. Understand the student's exact question before answering.
2. Adapt vocabulary, depth, examples and difficulty to the academic context supplied by the client.
3. For mathematics and quantitative subjects, solve carefully, check the arithmetic, and show the necessary working.
4. Explain why each important step works in language the student can understand.
5. Identify at least one common mistake when it is useful.
6. Include a similar example when it helps the student learn.
7. Never invent facts, references, official exam claims, marking schemes or sources.
8. If the question is genuinely ambiguous, ask one precise clarification question rather than guessing.
9. If local verification contains evidence, use it; do not pretend you independently verified something you did not verify.
10. Encourage understanding and independent problem solving.
11. Keep the answer readable on a phone.
12. If the requested topic is outside your reliable knowledge, say so clearly.
13. Do not reveal private chain-of-thought or hidden reasoning.

Return ONLY valid JSON with exactly this structure:

{
  "question": "...",
  "topic": "...",
  "steps": [
    {
      "title": "...",
      "body": "...",
      "why": "..."
    }
  ],
  "answer": "...",
  "methodSummary": "...",
  "example": "...",
  "supported": true
}

The visible steps should be concise teaching steps.`;
}

function buildUserPrompt(body) {
  const context = body.academicContext || {};

  return JSON.stringify(
    {
      task: 'Teach this student accurately and pedagogically.',
      question: body.question || '',
      academicContext: context,
      localVerification: body.localVerification || null,
    },
    null,
    2,
  );
}

// ============================================================
// CHAT SYSTEM PROMPT
// ============================================================

function buildChatSystemPrompt() {
  return `You are TutorAI, a friendly professional AI school tutor.

You support Primary, JSS, SSS, WAEC, NECO, JAMB, Post-UTME and general academic learning.

You can help with mathematics, English, physics, chemistry, biology, computer studies, economics, accounting, government, geography, literature, history and other school subjects.

Teaching rules:

1. Answer the student's actual question.
2. Do not force every question into mathematics.
3. Explain concepts clearly at the student's level.
4. When solving mathematics, show the working and verify the result.
5. If the student says they are confused, explain the exact confusing part differently.
6. Ask for clarification only when the question genuinely cannot be understood.
7. Do not invent facts, sources, exam questions or references.
8. Maintain conversational context from the supplied conversation.
9. Encourage understanding instead of simply giving answers.
10. Keep responses readable on a phone.
11. For difficult reasoning, verify the result before responding.
12. Do not reveal private chain-of-thought or hidden reasoning.

Return plain text only.

Do not return JSON.
Do not write markdown tables unless they are genuinely useful.`;
}

function buildChatUserPrompt(body) {
  const context = body.academicContext || {};

  const conversation = Array.isArray(body.conversation)
    ? body.conversation.slice(-20)
    : [];

  return JSON.stringify(
    {
      studentQuestion: body.question || '',
      academicContext: context,
      conversation,
    },
    null,
    2,
  );
}

// ============================================================
// OPENAI-COMPATIBLE CLOUD PROVIDERS
// ============================================================

function providerConfig(provider) {
  if (provider === 'gemini') {
    return {
      baseUrl: geminiBaseUrl,
      apiKey: geminiApiKey,
      errorName: 'Gemini',
    };
  }

  if (provider === 'deepseek') {
    return {
      baseUrl: deepSeekBaseUrl,
      apiKey: deepSeekApiKey,
      errorName: 'DeepSeek',
    };
  }

  throw new Error(`Unsupported cloud provider: ${provider}`);
}

async function callOpenAiCompatible(messages, route) {
  const config = providerConfig(route.provider);

  if (!config.apiKey) {
    throw new Error(`${config.errorName} API key is not configured.`);
  }

  const payload = {
    model: route.model,
    messages,
  };

  // Gemini's OpenAI-compatible endpoint accepts max_completion_tokens.
  // DeepSeek's Chat Completions endpoint uses max_tokens.
  if (route.provider === 'deepseek') {
    payload.max_tokens = route.maxOutputTokens;
  } else {
    payload.max_completion_tokens = route.maxOutputTokens;
  }

  if (route.reasoningEffort) {
    payload.reasoning_effort = route.reasoningEffort;
  }

  // Tutor lessons must return the exact object consumed by Flutter.
  if (route.responseFormat === 'tutor-lesson') {
    payload.response_format = {
      type: 'json_schema',
      json_schema: {
        name: 'tutor_lesson',
        strict: true,
        schema: tutorLessonSchema,
      },
    };
  } else if (route.responseFormat === 'tutor-lesson-json') {
    // DeepSeek currently guarantees valid JSON through json_object mode.
    payload.response_format = {
      type: 'json_object',
    };
  }

  const response = await fetch(`${config.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${config.apiKey}`,
    },
    body: JSON.stringify(payload),
  });

  const raw = await response.text();

  if (!response.ok) {
    throw new Error(`${config.errorName} ${response.status}: ${raw.slice(0, 700)}`);
  }

  let data;

  try {
    data = JSON.parse(raw);
  } catch (error) {
    throw new Error(`${config.errorName} returned invalid JSON: ${error.message}`);
  }

  const content = data?.choices?.[0]?.message?.content;

  if (typeof content !== 'string' || !content.trim()) {
    throw new Error(`${config.errorName} returned no message content.`);
  }

  return {
    content: content.trim(),
    provider: route.provider,
    model: route.model,
  };
}

// ============================================================
// OLLAMA FALLBACK
// ============================================================

async function callOllama(messages, route) {
  const response = await fetch(`${ollamaBaseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${ollamaApiKey}`,
    },
    body: JSON.stringify({
      model: route.model,
      temperature: 0.2,
      messages,
    }),
  });

  const raw = await response.text();

  if (!response.ok) {
    throw new Error(`Ollama ${response.status}: ${raw.slice(0, 700)}`);
  }

  let data;

  try {
    data = JSON.parse(raw);
  } catch (error) {
    throw new Error(`Ollama returned invalid JSON: ${error.message}`);
  }

  const content = data?.choices?.[0]?.message?.content;

  if (typeof content !== 'string' || !content.trim()) {
    throw new Error('Ollama returned no message content.');
  }

  return {
    content: content.trim(),
    provider: 'ollama',
    model: route.model,
  };
}

// ============================================================
// MAIN AI CALLER
// ============================================================

async function callAi(messages, route) {
  if (route.provider === 'ollama') {
    return callOllama(messages, route);
  }

  try {
    return await callOpenAiCompatible(messages, route);
  } catch (primaryError) {
    // In AUTO mode, retry a cloud request on the other configured provider.
    if (aiProvider === 'auto') {
      const fallbackProvider =
        route.provider === 'gemini' ? 'deepseek' : 'gemini';

      const fallbackKeyPresent =
        fallbackProvider === 'gemini' ? Boolean(geminiApiKey) : Boolean(deepSeekApiKey);

      const fallbackAllowed =
        fallbackProvider === 'deepseek' ? aiFallbackToDeepSeek : true;

      if (fallbackAllowed && fallbackKeyPresent) {
        console.warn(
          `${route.provider} failed; trying ${fallbackProvider}: ${primaryError.message}`,
        );

        const fallbackRoute =
          fallbackProvider === 'gemini'
            ? geminiRoute({
                purpose: route.responseFormat ? 'tutor' : 'chat',
                question: '',
              })
            : deepSeekRoute({
                purpose: route.responseFormat ? 'tutor' : 'chat',
                question: '',
              });

        // Preserve the original output budget/format for fallback calls.
        fallbackRoute.maxOutputTokens = route.maxOutputTokens;
        fallbackRoute.reasoningEffort = route.reasoningEffort;

        return callOpenAiCompatible(messages, fallbackRoute);
      }
    }

    if (!aiFallbackToOllama) {
      throw primaryError;
    }

    console.warn(
      `${route.provider} failed; using Ollama fallback: ${primaryError.message}`,
    );

    return callOllama(messages, {
      provider: 'ollama',
      model: ollamaModel,
      reasoningEffort: null,
      maxOutputTokens: route.maxOutputTokens,
      responseFormat: null,
    });
  }
}

// ============================================================
// JSON PARSER
// ============================================================

function parseJsonObject(text) {
  try {
    return JSON.parse(text);
  } catch (_) {}

  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/i);

  if (fenced) {
    try {
      return JSON.parse(fenced[1].trim());
    } catch (_) {}
  }

  const start = text.indexOf('{');
  const end = text.lastIndexOf('}');

  if (start >= 0 && end > start) {
    try {
      return JSON.parse(text.slice(start, end + 1));
    } catch (_) {}
  }

  return null;
}

// ============================================================
// LESSON VALIDATION
// ============================================================

function validateSolution(solution) {
  if (!solution || typeof solution !== 'object') {
    return false;
  }

  if (typeof solution.question !== 'string') {
    return false;
  }

  if (typeof solution.topic !== 'string') {
    return false;
  }

  if (typeof solution.answer !== 'string') {
    return false;
  }

  if (typeof solution.methodSummary !== 'string') {
    return false;
  }

  if (typeof solution.example !== 'string') {
    return false;
  }

  if (typeof solution.supported !== 'boolean') {
    return false;
  }

  if (!Array.isArray(solution.steps) || solution.steps.length === 0) {
    return false;
  }

  return solution.steps.every(
    (step) =>
      step &&
      typeof step.title === 'string' &&
      typeof step.body === 'string' &&
      typeof step.why === 'string',
  );
}

// ============================================================
// /v1/tutor
// ============================================================

async function tutor(req, res) {
  const body = await readJson(req);

  const route = chooseAiRoute({
    purpose: 'tutor',
    question: body.question,
  });

  const result = await callAi(
    [
      {
        role: 'system',
        content: buildSystemPrompt(),
      },
      {
        role: 'user',
        content: buildUserPrompt(body),
      },
    ],
    route,
  );

  const solution = parseJsonObject(result.content);

  if (!validateSolution(solution)) {
    const preview = normalizeText(result.content).slice(0, 300);
    throw new Error(
      `AI response did not match the TutorAI lesson schema (provider=${result.provider}, model=${result.model}). Response preview: ${preview}`,
    );
  }

  send(res, 200, {
    solution,
    backend: 'tutorai',
    provider: result.provider,
    model: result.model,
  });
}

// ============================================================
// /v1/tutor/follow-up
// ============================================================

async function followUp(req, res) {
  const body = await readJson(req);

  const context = body.academicContext || {};
  const lesson = body.lesson || {};
  // Keep only the most recent turns to reduce prompt size and latency.
  const conversation = Array.isArray(body.conversation)
    ? body.conversation.slice(-4)
    : [];

  const system = `You are TutorAI continuing an existing lesson.

Answer the student's exact follow-up question using the supplied lesson context.

Do not repeat generic advice.

Keep the academic level appropriate.

If the student asks why or how, explain the exact step or reasoning.

If the student is confused, change the teaching approach.

If you cannot determine the intended meaning, ask one precise clarification question.

For calculations, verify the result before responding.

Do not reveal private chain-of-thought or hidden reasoning.

Return plain text only.`;

  const user = JSON.stringify(
    {
      question: body.question || '',
      academicContext: context,
      lesson,
      conversation,
    },
    null,
    2,
  );

  const route = chooseAiRoute({
    purpose: 'follow-up',
    question: body.question,
  });

  const result = await callAi(
    [
      {
        role: 'system',
        content: system,
      },
      {
        role: 'user',
        content: user,
      },
    ],
    route,
  );

  send(res, 200, {
    reply: result.content,
    backend: 'tutorai',
    provider: result.provider,
    model: result.model,
  });
}

// ============================================================
// /v1/tutor/chat
// ============================================================

async function tutorChat(req, res) {
  const body = await readJson(req);

  const route = chooseAiRoute({
    purpose: 'chat',
    question: body.question,
  });

  const result = await callAi(
    [
      {
        role: 'system',
        content: buildChatSystemPrompt(),
      },
      {
        role: 'user',
        content: buildChatUserPrompt(body),
      },
    ],
    route,
  );

  send(res, 200, {
    reply: result.content,
    backend: 'tutorai-chat',
    provider: result.provider,
    model: result.model,
  });
}

// ============================================================
// SERVER
// ============================================================

const server = http.createServer(async (req, res) => {
  try {
    // --------------------------
    // HEALTH CHECK
    // --------------------------

    if (req.method === 'GET' && req.url === '/health') {
      return send(res, 200, {
        ok: true,
        service: 'TutorAI backend',
        configuredProvider: aiProvider,
        geminiConfigured: Boolean(geminiApiKey),
        geminiModel,
        geminiSimpleModel,
        deepSeekConfigured: Boolean(deepSeekApiKey),
        deepSeekModel,
        fallbackToDeepSeek: aiFallbackToDeepSeek,
        ollamaModel,
        fallbackToOllama: aiFallbackToOllama,
      });
    }

    // --------------------------
    // LESSON
    // --------------------------

    if (req.method === 'POST' && req.url === '/v1/tutor') {
      return await tutor(req, res);
    }

    // --------------------------
    // FOLLOW-UP
    // --------------------------

    if (req.method === 'POST' && req.url === '/v1/tutor/follow-up') {
      return await followUp(req, res);
    }

    // --------------------------
    // CHAT
    // --------------------------

    if (req.method === 'POST' && req.url === '/v1/tutor/chat') {
      return await tutorChat(req, res);
    }

    return send(res, 404, {
      error: 'Not found',
    });
  } catch (error) {
    console.error(error);

    return send(res, 502, {
      error: error?.message || 'TutorAI backend error',
    });
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`TutorAI backend listening on http://0.0.0.0:${port}`);
  console.log(`Configured provider mode: ${aiProvider}`);
  console.log(`Gemini configured: ${Boolean(geminiApiKey)}`);
  console.log(`Gemini model: ${geminiModel}`);
  console.log(`Gemini simple model: ${geminiSimpleModel}`);
  console.log(`DeepSeek configured: ${Boolean(deepSeekApiKey)}`);
  console.log(`DeepSeek model: ${deepSeekModel}`);
  console.log(`DeepSeek fallback enabled: ${aiFallbackToDeepSeek}`);
  console.log(`Ollama fallback enabled: ${aiFallbackToOllama}`);
  console.log(`Ollama fallback model: ${ollamaModel}`);
});
