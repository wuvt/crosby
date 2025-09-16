import Ecto.Query, only: [from: 2]

defmodule CrosbyWeb.Api do
  use CrosbyWeb, :controller
  alias Crosby.{Repo, Category, Entry}

  def entries_for_category(name) do
    query =
      from entry in Entry,
        join: category in Category,
        on: entry.category_id == category.id,
        where: category.name == ^name,
        select: entry.path

    Repo.all(query)
  end

  def m3u(category_name) do
    tracks = entries_for_category(category_name) |> Enum.join("\n")
    "#EXTM3U\n" <> tracks
  end

  def category(conn, params) do
    conn
    |> put_resp_header("content-type", "application/vnd.apple.mpegurl")
    |> text(m3u(params |> Map.get("category")))
  end

  # TODO: distinguish "special" categories (like psas),
  # so that we can zip up the non-special playlists
  # checkbox on category page?
end
