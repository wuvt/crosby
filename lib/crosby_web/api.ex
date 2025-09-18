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

  def categories do
    Repo.all(from category in Category, order_by: category.name, select: category.name)
  end

  def playlist_m3us do
    categories()
    |> Enum.map(fn cat -> {String.to_charlist(cat <> ".m3u"), m3u(cat)} end)
  end

  def playlists_zip do
    {:ok, {_filename, zip}} = :zip.create(~c"playlists.zip", playlist_m3us(), [:memory])
    zip
  end

  def playlists(conn, _params) do
    conn |> send_download({:binary, playlists_zip()}, filename: "playlists.zip")
  end

  def playlists_checksum(conn, _params) do
    complete = playlist_m3us() |> Enum.map(fn {name, contents} -> "#{name}:\n#{contents}" end)
    hash = :crypto.hash(:sha256, complete) |> Base.encode64()
    conn |> text(hash)
  end
end
