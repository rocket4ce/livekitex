ExUnit.start()

# Ensure Finch is started for HTTP tests
Application.ensure_all_started(:finch)

# Define mocks
Mox.defmock(Livekitex.RoomServiceMock, for: Livekitex.RoomServiceBehaviour)
