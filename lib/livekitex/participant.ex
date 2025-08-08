defmodule Livekitex.Participant do
  @moduledoc """
  Participant type exported by RoomService operations.

  Note: Current implementation returns plain maps (see TwirpUtils.proto_to_participant/1).
  This module exists to provide a stable typespec for callbacks and Dialyzer.
  """

  @typedoc "Participant as a map with keys like :sid, :identity, :tracks, etc."
  @type t :: map()
end
