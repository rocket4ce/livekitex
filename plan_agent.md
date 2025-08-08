from pathlib import Path

# Create the markdown content based on the translation provided
md_content = """
# Roadmap: LiveKit Agents Integration in livekitex

This document outlines the plan to add support for “Agents” (LiveKit Agents) to this Elixir library, including API design, implementation phases, examples, testing, deployment, and metrics. The goal is to provide an idiomatic Elixir experience to create, run, and operate conversational/multimodal agents on top of LiveKit.

## Official references (source of truth)
- https://docs.livekit.io/agents/
- Getting started / Quickstarts:
  - Voice AI: https://docs.livekit.io/agents/start/voice-ai/
  - Telephony: https://docs.livekit.io/agents/start/telephony/
  - Frontend: https://docs.livekit.io/agents/start/frontend/
  - Playground: https://docs.livekit.io/agents/start/playground/
  - v0 Migration: https://docs.livekit.io/agents/start/v0-migration/
- Building:
  - Workflows: https://docs.livekit.io/agents/build/workflows/
  - Audio: https://docs.livekit.io/agents/build/audio/
  - Vision: https://docs.livekit.io/agents/build/vision/
  - Tools: https://docs.livekit.io/agents/build/tools/
  - Nodes: https://docs.livekit.io/agents/build/nodes/
  - Text: https://docs.livekit.io/agents/build/text/
  - External data: https://docs.livekit.io/agents/build/external-data/
  - Metrics: https://docs.livekit.io/agents/build/metrics/
  - Events: https://docs.livekit.io/agents/build/events/
  - Testing: https://docs.livekit.io/agents/build/testing/
- Worker / Agent operation:
  - Worker: https://docs.livekit.io/agents/worker/
  - Dispatch: https://docs.livekit.io/agents/worker/agent-dispatch/
  - Job: https://docs.livekit.io/agents/worker/job/
  - Options: https://docs.livekit.io/agents/worker/options/
- Operations:
  - Deployment: https://docs.livekit.io/agents/ops/deployment/
  - Recording: https://docs.livekit.io/agents/ops/recording/
- Integrations:
  - Cerebras: https://docs.livekit.io/agents/integrations/cerebras/
  - Llama: https://docs.livekit.io/agents/integrations/llama/
  - Index: https://docs.livekit.io/agents/integrations/

## Objectives
- Idiomatic public Elixir API for creating, configuring, running, and observing LiveKit agents.
- Compatibility with quickstarts (Voice AI, Telephony, Frontend) via examples and helpers.
- Support for “worker/dispatch/job/options” for agent orchestration.
- Abstractions for audio, text, vision, tools, workflows/nodes, and external data.
- Integrated telemetry/metrics and events with the Elixir ecosystem (Telemetry, OpenTelemetry/PromEx, Logger).
- Deployment guides (Docker, Mix release, Kubernetes) and recording (egress/recording).

## Initial Scope (MVP)
- Define contracts (behaviours) and types for agents, jobs, tools, workflows, and events.
- Dispatcher/Jober: send/receive agent jobs with basic options.
- Audio and text: minimal I/O pipeline for Voice AI using configurable adapters.
- Reproducible “Voice AI” and “Frontend” examples in Elixir.
- Basic metrics/telemetry and integration tests.

...

## Last updated
**2025-08-08**
"""

# Save the file
file_path = Path("/mnt/data/livekit_agents_roadmap.md")
file_path.write_text(md_content.strip())

file_path.name