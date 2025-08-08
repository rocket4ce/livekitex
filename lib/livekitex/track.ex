defmodule Livekitex.Track do
  @moduledoc """
  Track type exported by RoomService operations.

  Note: Current implementation returns plain maps (see TwirpUtils.proto_to_track/1).
  This module exists to provide a stable typespec for callbacks and Dialyzer.
  """

  @typedoc "Track as a map with keys like :sid, :type, :name, etc."
  @type t :: map()
end
