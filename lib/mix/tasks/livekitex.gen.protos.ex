defmodule Mix.Tasks.Livekitex.Gen.Protos do
  @shortdoc "Regenerates the LiveKit protobuf modules from livekit/protocol"

  @moduledoc """
  Regenerates `lib/livekitex/proto/**` from the upstream
  [livekit/protocol](https://github.com/livekit/protocol) repository.

  This is a maintainer task; users of the library never need `protoc`.

      mix livekitex.gen.protos                 # tag from priv/protos/VERSION
      mix livekitex.gen.protos --tag v1.55.0   # upgrade
      mix livekitex.gen.protos --source ../protocol/protobufs

  Requirements: `git`, `protoc`, and `protoc-gen-elixir` on the `PATH`
  (`mix escript.install hex protobuf`).

  The vendored `.proto` files are copied unmodified into `priv/protos/` and compiled
  with `package_prefix=livekitex.proto`, so every message lives under
  `Livekitex.Proto.Livekit.*`.
  """

  use Mix.Task

  @files ~w(
    livekit_models.proto
    livekit_metrics.proto
    livekit_room.proto
    livekit_egress.proto
    livekit_ingress.proto
    livekit_sip.proto
    livekit_agent.proto
    livekit_agent_dispatch.proto
    livekit_webhook.proto
    livekit_token_source.proto
    livekit_connector.proto
    livekit_connector_whatsapp.proto
    livekit_connector_twilio.proto
    livekit_phone_number.proto
    livekit_rtc.proto
    logger/options.proto
  )

  @protos_dir "priv/protos"
  @out_dir "lib/livekitex/proto"

  @impl Mix.Task
  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: [tag: :string, source: :string])

    for exe <- ["protoc", "protoc-gen-elixir"], is_nil(System.find_executable(exe)) do
      Mix.raise(
        "#{exe} not found on PATH (protoc-gen-elixir: `mix escript.install hex protobuf`)"
      )
    end

    tag = opts[:tag] || @protos_dir |> Path.join("VERSION") |> File.read!() |> String.trim()

    case opts[:source] do
      nil ->
        clone = clone(tag)

        try do
          regenerate(Path.join(clone, "protobufs"), tag)
        after
          File.rm_rf(clone)
        end

      source ->
        regenerate(source, tag)
    end

    Mix.shell().info("Generated #{@out_dir} from livekit/protocol #{tag}")
  end

  defp regenerate(source, tag) do
    copy_protos(source)
    File.write!(Path.join(@protos_dir, "VERSION"), tag <> "\n")
    generate()
    Mix.Task.run("format", [Path.join(@out_dir, "**/*.ex")])
  end

  defp clone(tag) do
    dir =
      Path.join(
        System.tmp_dir!(),
        "livekit-protocol-#{tag}-#{System.unique_integer([:positive])}"
      )

    url = "https://github.com/livekit/protocol.git"
    Mix.shell().info("Cloning #{url} @ #{tag}")

    {_, 0} =
      System.cmd("git", ["clone", "--quiet", "--depth", "1", "--branch", tag, url, dir],
        stderr_to_stdout: true
      )

    dir
  end

  defp copy_protos(source) do
    for file <- @files do
      target = Path.join(@protos_dir, file)
      File.mkdir_p!(Path.dirname(target))
      File.cp!(Path.join(source, file), target)
    end
  end

  # protoc runs into a temporary directory first: a failure must not leave the
  # repository without its generated modules.
  defp generate do
    tmp = Path.join(System.tmp_dir!(), "livekitex-gen-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)

    try do
      include = google_include()

      args =
        ["-I", @protos_dir] ++
          if(include, do: ["-I", include], else: []) ++
          ["--elixir_out=package_prefix=livekitex.proto,include_docs=true:#{tmp}"] ++
          Enum.map(@files, &Path.join(@protos_dir, &1))

      case System.cmd("protoc", args, stderr_to_stdout: true) do
        {_, 0} -> :ok
        {output, status} -> Mix.raise("protoc failed (#{status}):\n#{output}")
      end

      generated = Path.join(tmp, "livekitex/proto")

      unless File.dir?(generated) do
        Mix.raise("protoc produced no output in #{generated}")
      end

      File.rm_rf!(@out_dir)
      File.mkdir_p!(Path.dirname(@out_dir))
      File.cp_r!(generated, @out_dir)
    after
      File.rm_rf(tmp)
    end
  end

  # protoc ships google/protobuf/*.proto next to its binary (e.g. /opt/homebrew/include).
  defp google_include do
    with protoc when is_binary(protoc) <- System.find_executable("protoc"),
         dir = protoc |> Path.dirname() |> Path.join("../include") |> Path.expand(),
         true <- File.exists?(Path.join(dir, "google/protobuf/descriptor.proto")) do
      dir
    else
      _ -> nil
    end
  end
end
