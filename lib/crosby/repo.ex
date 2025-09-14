defmodule Crosby.Repo do
  use Ecto.Repo,
    otp_app: :crosby,
    adapter: Ecto.Adapters.Postgres
end
