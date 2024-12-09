defmodule Blade do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  import Pgvector.Ecto.Query
  require Logger

  @model "nomic-embed-text"

  def name, do: Application.get_env(:blade, :vault_name)
  def root, do: Application.get_env(:blade, :vault_root)
  def pandoc, do: Application.get_env(:blade, :pandoc)

  def client(timeout), do: Ollama.init(receive_timeout: timeout)

  def notes do
    root = root()
    prefix = root <> "/"

    root()
    |> Path.join("**/*.md")
    |> Path.wildcard()
    |> Stream.map(&{root, String.trim_leading(&1, prefix)})
  end

  def index(client \\ client(900_000)) do
    notes()
    |> Stream.each(fn {root, base} ->
      case record(base) do
        nil ->
          Logger.info(base)

          with text <- plaintext(root, base),
               false <- is_nil(text),
               embedding <- embedding(client, @model, Path.basename(base), text),
               false <- is_nil(embedding) do
            %Blade.Note{}
            |> Ecto.Changeset.change(%{
              filepath: base,
              checksum: hash(root, base),
              embedding: embedding
            })
            |> Blade.Repo.insert!()

            Logger.info("indexed")
          else
            _ -> Logger.error("failed to index, skipping")
          end

        record ->
          hash = hash(root, base)

          updated = record.checksum != hash
          no_embedding = record.embedding == nil

          if updated || no_embedding do
            Logger.info(base)

            with text <- plaintext(root, base),
                 false <- is_nil(text),
                 embedding <- embedding(client, @model, Path.basename(base), text),
                 false <- is_nil(embedding) do
              record
              |> Ecto.Changeset.change(%{checksum: hash, embedding: embedding})
              |> Blade.Repo.update!()

              Logger.info("updated note")
            else
              _ -> Logger.error("failed to index, skipping")
            end
          end
      end
    end)
    |> Stream.run()
  end

  def rehash do
    notes()
    |> Stream.each(fn {root, base} ->
      hash = hash(root, base)

      case record(base) do
        nil ->
          nil

        record ->
          record
          |> Ecto.Changeset.change(checksum: hash)
          |> Blade.Repo.update!()
      end
    end)
    |> Stream.run()
  end

  def prune do
    root = root()

    Blade.Repo.transaction(fn ->
      Blade.Repo.stream(Blade.Note)
      |> Stream.each(fn note ->
        base = note.filepath

        if !File.exists?(Path.join(root, base)) do
          Blade.Repo.delete!(note)
          IO.puts("deleted note #{base}")
        end
      end)
      |> Stream.run()
    end)
  end

  def search(client \\ client(5000), query) do
    embedding = embedding(client, @model, query)

    if embedding do
      from(note in Blade.Note,
        select: note.filepath,
        order_by: l2_distance(note.embedding, ^Pgvector.new(embedding)),
        limit: 15
      )
      |> Blade.Repo.all()
    end
  end

  defp hash(root, base) do
    hash(base <> "\n" <> File.read!(Path.join(root, base)))
  end

  defp hash(text), do: :sha256 |> :crypto.hash(text) |> Base.encode64()

  defp record(base) do
    Blade.Repo.one(from n in Blade.Note, where: n.filepath == ^base)
  end

  defp plaintext(root, base) do
    path = Path.join(root, base)

    case System.cmd(pandoc(), [path, "-t", "plain"]) do
      {text, 0} -> text
      _ -> nil
    end
  end

  @spec embedding(%Ollama{req: Req.Request.t()}, any(), any()) :: any()
  def embedding(client \\ client(60_000), model, text) do
    case Ollama.embed(client, model: model, input: [text]) do
      {:ok, %{"embeddings" => [embedding]}} ->
        embedding

      {:error, error} ->
        IO.inspect(error)
        nil
    end
  end

  def embedding(client, model, title, text) do
    embedding(client, model, title <> "\n" <> text)
  end
end
