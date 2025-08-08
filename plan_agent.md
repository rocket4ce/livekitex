## Roadmap: LiveKit Agents Integration in livekitex

This document outlines the plan to add support for “Agents” (LiveKit Agents) to this Elixir library, including API design, implementation phases, examples, testing, deployment, and metrics. The goal is to provide an idiomatic Elixir experience to create, run, and operate conversational/multimodal agents on top of LiveKit.

### Official references (source of truth):
-	https://docs.livekit.io/agents/
-	Getting started / Quickstarts:
-	Voice AI: https://docs.livekit.io/agents/start/voice-ai/
-	Telephony: https://docs.livekit.io/agents/start/telephony/
-	Frontend: https://docs.livekit.io/agents/start/frontend/
-	Playground: https://docs.livekit.io/agents/start/playground/
-	v0 Migration: https://docs.livekit.io/agents/start/v0-migration/
-	Building:
-	Workflows: https://docs.livekit.io/agents/build/workflows/
-	Audio: https://docs.livekit.io/agents/build/audio/
-	Vision: https://docs.livekit.io/agents/build/vision/
-	Tools: https://docs.livekit.io/agents/build/tools/
-	Nodes: https://docs.livekit.io/agents/build/nodes/
-	Text: https://docs.livekit.io/agents/build/text/
-	External data: https://docs.livekit.io/agents/build/external-data/
-	Metrics: https://docs.livekit.io/agents/build/metrics/
-	Events: https://docs.livekit.io/agents/build/events/
-	Testing: https://docs.livekit.io/agents/build/testing/
-	Worker / Agent operation:
-	Worker: https://docs.livekit.io/agents/worker/
-	Dispatch: https://docs.livekit.io/agents/worker/agent-dispatch/
-	Job: https://docs.livekit.io/agents/worker/job/
-	Options: https://docs.livekit.io/agents/worker/options/
-	Operations:
-	Deployment: https://docs.livekit.io/agents/ops/deployment/
-	Recording: https://docs.livekit.io/agents/ops/recording/
-	Integrations:
-	Cerebras: https://docs.livekit.io/agents/integrations/cerebras/
-	Llama: https://docs.livekit.io/agents/integrations/llama/
-	Index: https://docs.livekit.io/agents/integrations/



### Objectives
-	Idiomatic public Elixir API for creating, configuring, running, and observing LiveKit agents.
-	Compatibility with quickstarts (Voice AI, Telephony, Frontend) via examples and helpers.
-	Support for “worker/dispatch/job/options” for agent orchestration.
-	Abstractions for audio, text, vision, tools, workflows/nodes, and external data.
-	Integrated telemetry/metrics and events with the Elixir ecosystem (Telemetry, OpenTelemetry/PromEx, Logger).
-	Deployment guides (Docker, Mix release, Kubernetes) and recording (egress/recording).



### Initial Scope (MVP)
-	Define contracts (behaviours) and types for agents, jobs, tools, workflows, and events.
-	Dispatcher/Jober: send/receive agent jobs with basic options.
-	Audio and text: minimal I/O pipeline for Voice AI (capture, transcription, LLM, TTS) using configurable adapters.
-	Reproducible “Voice AI” and “Frontend” examples in Elixir.
-	Basic metrics/telemetry and integration tests.



### Assumptions and Architecture Decisions
-	Official LiveKit Agents SDKs are more mature in Python/TypeScript. We offer two paths:
1.	Native Elixir integration (preferred medium-term): implement clients/services that speak required protocols (e.g., gRPC/WebSocket/HTTP) for Worker/Dispatch/Jobs.
2.	Operational bridge (quick short-term): supervise external workers (Python/Node) from Elixir using processes, gRPC/HTTP, queues, or Ports. Provide lifecycle, config, and metrics modules; expose a unified Elixir API.
-	Maintain a stable public API compatible with future improvements.



### Proposed API Design (modules and behaviours)
-	LiveKit.Agents
-	start_agent/1..n, stop_agent/1, list_agents/0
-	submit_job/2, cancel_job/1, job_status/1
-	LiveKit.Agents.Worker
-	Behaviour for runtimes; start_link/1; callbacks for setup, run, teardown
-	Adapters: :native, :external_python, :external_node
-	LiveKit.Agents.Dispatcher
-	Routing and queues; policies (round-robin, weighted, tags)
-	LiveKit.Agents.Job
-	Types/structs: Job.t, Job.Options, Job.Result, standardized errors
-	LiveKit.Agents.Tools
-	Behaviour: call/2; tool registry and discovery
-	LiveKit.Agents.Workflow / LiveKit.Agents.Nodes
-	Simple DSL to chain nodes (stt -> llm -> tools -> tts)
-	LiveKit.Agents.Audio | .Text | .Vision
-	Codecs/formats, resampling, normalization; I/O adapters
-	LiveKit.Agents.Events
-	Pub/Sub and lifecycle events; optional Phoenix.PubSub integration
-	LiveKit.Agents.Metrics
-	Telemetry events; exporters (OpenTelemetry, Prometheus)
-	LiveKit.Agents.Testing
-	Simulation helpers, audio/text fixtures, test harness
-	LiveKit.Agents.Telephony
-	SIP/telephony integration (helpers and examples)
-	LiveKit.Agents.Frontend
-	Helpers for UI integration (e.g., tokens, endpoints, signaling)

### Key Contracts (summary):
-	Worker behaviour: init(opts) -> state | {:stop, reason}; handle_job(job, state) -> {:ok, result, state} | {:error, reason, state}
-	Tool behaviour: call(input, ctx) -> {:ok, output} | {:error, reason}
-	Dispatcher: choose_worker(job_meta) -> worker_ref



### Phases and Deliverables
1.	Research & alignment (week 1)
-	Map docs to Elixir features (with links).
-	Decide MVP scope/protocol (native vs bridge). Deliverable: ADR.
2.	Public API design & contracts (week 1-2)
-	Define behaviours, structs, and types. Deliverable: skeleton modules and @doc.
3.	MVP Worker/Dispatch/Job (week 2–3)
-	Implement Dispatcher + External worker (Python/Node) with supervision (bridge).
-	submit_job/2 and job_status/1 functional. Deliverable: simple Playground demo.
4.	Audio + Text (Voice AI) (week 3–4)
-	Configurable STT, LLM, TTS adapters; minimal pipeline.
-	End-to-end “Voice AI” example using LiveKit room. Deliverable: reproducible example.
5.	Frontend + Tokens + Signaling (week 4)
-	UI helpers; minimal web example. Deliverable: “Frontend” demo.
6.	Telephony (week 5)
-	SIP/ingress helpers; agent bridge. Deliverable: “Telephony” demo.
7.	Workflows/Nodes/Tools (week 5–6)
-	Node DSL + tool registry; tool examples (search, basic RAG). Deliverable: docs & tests.
8.	External data (week 6)
-	Connector abstraction (HTTP, DB, vector stores). Deliverable: 1–2 adapters.
9.	Metrics & Events (week 6–7)
-	Telemetry, OpenTelemetry/PromEx, basic dashboard. Deliverable: metrics + guide.
10.	Testing & QA (week 7)
-	Test harness (audio/text fixtures), basic load tests. Deliverable: green suite.
11.	Ops: Deployment & Recording (week 7–8)
-	Docker/k8s/Mix release guides; recording/egress sample. Deliverable: docs + scripts.
12.	Integrations (ongoing)
-	Llama and Cerebras adapters (as applicable). Deliverable: optional examples.
13.	v0 Migration (if applicable)
-	Migration guide and breaking changes summary.



### Detailed Technical Plan (MVP + External Bridge)
-	External worker supervision
-	Supervisor that launches external process (Python/Node) with config, health checks, retries.
-	gRPC/HTTP or stdio (Ports) communication: request/response for jobs.
-	Map Job.Options <-> official worker payload.
-	Dispatcher
-	Dynamic worker registration with metadata (capabilities, tags, load).
-	Assignment strategies and backpressure.
-	Public API
-	submit_job/2: validate options, pick worker, send, return job_id.
-	job_status/1: query worker state; events via optional PubSub.
-	Audio/Text pipeline
-	Define structs for frames/audio and messages/text; normalization (sample rate, PCM floats).
-	Connect to LiveKit room (if applicable) and STT/LLM/TTS adapters.

### Risks & Mitigations
-	SDK/protocol differences: start with external bridge for speed; plan native in parallel.
-	Stability: use OTP supervision, retries, circuit breakers, timeouts.
-	Performance: queues with limits, telemetry, early load testing.



### Metrics and Telemetry (mapped to docs/metrics)
-	Telemetry events: job_started, job_failed, job_succeeded, job_latency, worker_crash, queue_depth, audio_frames_processed.
-	Export: OpenTelemetry → Prometheus/Grafana. Instrumentation examples in modules.



### Events (mapped to docs/events)
-	Internal events (PubSub): agent_started, agent_stopped, tool_invoked, node_transition, stt_result, tts_output.
-	Hooks for structured logging and auditing.



### Testing (mapped to docs/testing)
-	Fixtures: audio clips, prompts and responses.
-	Mocks/fakes: STT/LLM/TTS; simulate failures and timeouts.
-	Integration tests: E2E Voice AI flow with limited resources.



### Deployment and Operations (mapped to docs/ops)
-	Mix release + multi-stage Dockerfile; external runtime readiness/liveness.
-	Kubernetes: Deployment with resource limits and HPA; config via env/ConfigMap/Secret.
-	Recording/Egress: example to record sessions and store in S3/GCS/Azure Blob.



### Integrations (mapped to docs/integrations)
-	Optional adapters:
-	Llama (Meta): model selection, prompt helpers.
-	Cerebras: configuration and execution.
-	Provide interfaces to add other providers (OpenAI, Anthropic, etc.).



### Examples and Guides (mapped to quickstarts)
-	examples/voice_ai: minimal pipeline sample (mic -> STT -> LLM -> TTS -> out).
-	examples/telephony: SIP bridge -> agent -> response.
-	examples/frontend: token helper, endpoints, signaling.
-	examples/playground: job orchestration with simple UI.



### Detailed Backlog (checklist)
-	ADR: external bridge vs native path
-	Behaviours: Worker, Tool, Node, Dispatcher
-	Structs/Types: Job, Options, Result, Error
-	Dispatcher: registration, policies, backpressure
-	External Worker: supervisor, health, rpc (gRPC/HTTP/Port)
-	Public API: start/stop/list, submit/cancel/status
-	Audio/Text: basic types and adapters
-	Voice AI example (quickstart)
-	Frontend example
-	Telephony example
-	Tools + Nodes + minimal Workflow DSL
-	External data adapter (1–2)
-	Metrics (Telemetry + OTel exporter) and basic dashboard
-	Events (PubSub + Logger) and hooks
-	Testing: fixtures + mocks + E2E
-	Ops: Docker/Mix release/K8s + Recording sample
-	Optional integrations (Llama/Cerebras)
-	v0 Migration guide (if applicable)



### Estimated Timeline (indicative)
-	Functional MVP (bridge): 4–5 weeks
-	Advanced features (workflows/tools/telephony/metrics): +3–4 weeks
-	Native Elixir (partial/progressive): in parallel, depending on protocol & priorities



### Implementation Notes
-	Keep API stable and well-documented (@doc, doctests where applicable).
-	Avoid heavy dependencies; prefer optional adapters.
-	Publish examples with Makefile or mix tasks for quick reproduction.



### Appendix: Quick Docs → Module/Deliverables Mapping
-	start/voice-ai → examples/voice_ai + LiveKit.Agents.Audio/Text + Worker/Dispatch/Job
-	start/telephony → LiveKit.Agents.Telephony + SIP/ingress example
-	start/frontend → LiveKit.Agents.Frontend + token/signaling helpers
-	build/workflows/nodes/tools → LiveKit.Agents.Workflow/Nodes/Tools
-	build/audio/vision/text → LiveKit.Agents.Audio/Vision/Text
-	build/external-data → connectors and adapters
-	build/metrics/events/testing → LiveKit.Agents.Metrics/Events/Testing
-	worker/agent-dispatch/job/options → LiveKit.Agents.Dispatcher/Worker/Job
-	ops/deployment/recording → Docker/K8s/Recording guides
-	integrations/* → optional adapters



Last updated: 2025-08-08