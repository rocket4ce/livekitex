ExUnit.start()
Application.ensure_all_started(:gun)

# Define mocks
Mox.defmock(Livekitex.RoomServiceMock, for: Livekitex.RoomServiceBehaviour)
