defmodule Livekitex.Room do
  @moduledoc """
  Represents a LiveKit room.
  """

  defstruct name: nil,
            sid: nil,
            empty_timeout: nil,
            departure_timeout: nil,
            max_participants: nil,
            creation_time: nil,
            turn_password: nil,
            enabled_codecs: [],
            metadata: nil,
            num_participants: nil,
            num_publishers: nil,
            active_recording: nil,
            version: nil

  @type t :: %__MODULE__{
          name: String.t() | nil,
          sid: String.t() | nil,
          empty_timeout: integer() | nil,
          departure_timeout: integer() | nil,
          max_participants: integer() | nil,
          creation_time: integer() | nil,
          turn_password: String.t() | nil,
          enabled_codecs: list(map()) | nil,
          metadata: String.t() | nil,
          num_participants: integer() | nil,
          num_publishers: integer() | nil,
          active_recording: boolean() | nil,
          version: map() | nil
        }
end
