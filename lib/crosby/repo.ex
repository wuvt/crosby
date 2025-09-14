defmodule Crosby.Repo do
  use Ecto.Repo,
    otp_app: :crosby,
    adapter: Ecto.Adapters.SQLite3
end
