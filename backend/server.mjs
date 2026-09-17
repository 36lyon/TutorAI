import http from 'node:http';

const port = Number(process.env.PORT || 8787);

// TutorAI uses Ollama locally by default.
// These can still be overridden later with environment variables.
const aiBaseUrl = (
  process.env.AI_BASE_URL ||
  'http://127.0.0.1:11434/v1'
).replace(/\/+$/, '');

const aiApiKey = process.env.AI_API_KEY || 'ollama';
const aiModel = process.env.AI_MODEL || 'gemma3:1b';

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

function buildSystemPrompt() {
  return `You are TutorAI, a professional educational tutor focused on Primary, JSS, SSS, WAEC, NECO, JAMB and Post-UTME learners.

Teach rather than merely output answers.

Never invent a solution when the question is ambiguous.

Adapt vocabulary, depth and difficulty to the academic context supplied by the client.

Show the student's exact problem, explain the concept, work step-by-step, explain why each step works, identify a common mistake, and include a similar example.

For mathematics, verify arithmetic and algebra carefully before responding.

For other subjects, distinguish facts from uncertainty and do not fabricate references or exam claims.

Return ONLY valid JSON with this exact structure:

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
}`;
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

function buildChatSystemPrompt() {
  return `You are TutorAI, a friendly professional AI school tutor.

Your job is to have a real educational conversation with the student.

You support:
- Primary
- JSS
- SSS
- WAEC
- NECO
- JAMB
- Post-UTME

You can help with mathematics, English, physics, chemistry, biology, computer studies, economics, accounting, government, geography, literature, history and other school subjects.

Important teaching rules:

1. Answer the student's actual question.
2. Do not force every question into mathematics.
3. If the student asks a general academic question, answer it as a tutor.
4. Explain concepts clearly at the student's level.
5. When useful, use simple examples.
6. When solving mathematics, show the working and verify the result.
7. If the student says they are confused, explain the exact confusing part differently.
8. Ask a clarification question only when the question genuinely cannot be understood.
9. Do not invent facts, sources, exam questions or references.
10. Maintain conversational context from the supplied conversation.
11. Encourage understanding instead of simply giving answers.
12. Keep responses readable on a phone.

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

async function callAi(messages) {
  const response = await fetch(`${aiBaseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${aiApiKey}`,
    },
    body: JSON.stringify({
      model: aiModel,
      temperature: 0.2,
      messages,
    }),
  });

  const raw = await response.text();

  if (!response.ok) {
    throw new Error(
      `AI provider ${response.status}: ${raw.slice(0, 500)}`,
    );
  }

  let data;

  try {
    data = JSON.parse(raw);
  } catch (error) {
    throw new Error(
      `AI provider returned invalid JSON: ${error.message}`,
    );
  }

  const content = data?.choices?.[0]?.message?.content;

  if (typeof content !== 'string' || !content.trim()) {
    throw new Error('AI provider returned no message content.');
  }

  return content.trim();
}

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

async function tutor(req, res) {
  const body = await readJson(req);

  const content = await callAi([
    {
      role: 'system',
      content: buildSystemPrompt(),
    },
    {
      role: 'user',
      content: buildUserPrompt(body),
    },
  ]);

  const solution = parseJsonObject(content);

  if (!validateSolution(solution)) {
    throw new Error(
      'AI response did not match the TutorAI lesson schema.',
    );
  }

  send(res, 200, {
    solution,
    backend: 'tutorai',
    model: aiModel,
  });
}

async function followUp(req, res) {
  const body = await readJson(req);

  const context = body.academicContext || {};
  const lesson = body.lesson || {};

  const conversation = Array.isArray(body.conversation)
    ? body.conversation.slice(-12)
    : [];

  const system = `You are TutorAI continuing an existing lesson.

Answer the student's exact follow-up question using the supplied lesson context.

Do not repeat generic advice.

Keep the academic level appropriate.

If the student asks why or how, explain the exact step or reasoning.

If the student is confused, change the teaching approach.

If you cannot determine the intended meaning, ask one precise clarification question.

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

  const reply = await callAi([
    {
      role: 'system',
      content: system,
    },
    {
      role: 'user',
      content: user,
    },
  ]);

  send(res, 200, {
    reply,
    backend: 'tutorai',
    model: aiModel,
  });
}

async function tutorChat(req, res) {
  const body = await readJson(req);

  const reply = await callAi([
    {
      role: 'system',
      content: buildChatSystemPrompt(),
    },
    {
      role: 'user',
      content: buildChatUserPrompt(body),
    },
  ]);

  send(res, 200, {
    reply,
    backend: 'tutorai-chat',
    model: aiModel,
  });
}

const server = http.createServer(async (req, res) => {
  try {
    if (req.method === 'GET' && req.url === '/health') {
      return send(res, 200, {
        ok: true,
        service: 'TutorAI backend',
        aiProvider: 'ollama',
        aiBaseUrl,
        aiModel,
      });
    }

    if (req.method === 'POST' && req.url === '/v1/tutor') {
      return await tutor(req, res);
    }

    if (
      req.method === 'POST' &&
      req.url === '/v1/tutor/follow-up'
    ) {
      return await followUp(req, res);
    }

    if (
      req.method === 'POST' &&
      req.url === '/v1/tutor/chat'
    ) {
      return await tutorChat(req, res);
    }

    return send(res, 404, {
      error: 'Not found',
    });
  } catch (error) {
    console.error(error);

    return send(res, 502, {
      error:
        error?.message ||
        'TutorAI backend error',
    });
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(
    `TutorAI backend listening on http://0.0.0.0:${port}`,
  );
  console.log(`AI provider: Ollama`);
  console.log(`AI model: ${aiModel}`);
  console.log(`AI base URL: ${aiBaseUrl}`);
});