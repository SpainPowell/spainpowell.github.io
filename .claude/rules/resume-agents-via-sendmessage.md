## Resuming Background Agents

**To continue a previously spawned agent, use `SendMessage` — never call `Agent` again with its ID as the prompt.**

**Why:** `Agent` always starts a brand-new agent with no memory of prior work, even if
the "prompt" you pass it is literally the old agent's ID string. During the PR 7.1
code-review sweep, an attempt to "resume" an agent to retrieve its findings was made
via `Agent({prompt: "<agentId>"})` — this silently launched a fresh, context-less agent
that had no idea what task it was supposed to continue, and its only useful output was
asking "what would you like me to do?". The actual findings were only recovered because
the *original* agent independently sent a `task-notification` with its results in a
later message.

**How to apply:** to continue a specific agent (get results, give it more work, ask a
follow-up), use `SendMessage` with `to:` set to the agent's name or its raw `agentId`
(format `a...-...`). Only use `Agent` to start something genuinely new. If unsure
whether an agent already finished and reported, check for its `task-notification`
before spawning anything to "check on it."
