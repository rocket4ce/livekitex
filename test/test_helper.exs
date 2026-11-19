# Integration tests need a running `livekit-server --dev` (devkey/secret on :7880):
#
#     mix test --only integration
#
# Cloud tests need LIVEKIT_CLOUD_URL, LIVEKIT_CLOUD_API_KEY and LIVEKIT_CLOUD_API_SECRET:
#
#     mix test --only cloud
ExUnit.start(exclude: [:integration, :cloud])
