defmodule Blade.Repo do
  use Ecto.Repo,
    otp_app: :blade,
    adapter: Ecto.Adapters.Postgres
end
