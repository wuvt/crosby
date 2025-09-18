import Ecto.Query, only: [from: 2]

defmodule CrosbyWeb.Api do
  use CrosbyWeb, :controller
  alias Crosby.{Repo, Category, Entry}

  @special_categories MapSet.new(~w[psa ids lnr soo pro backup])

  def special_category?(name) do
    MapSet.member?(@special_categories, name)
  end

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

  def category(conn, %{"category" => category}) do
    conn
    |> put_resp_header("content-type", "application/vnd.apple.mpegurl")
    |> text(m3u(category))
  end

  def categories do
    Repo.all(from category in Category, select: category.name)
  end

  def playlists(conn, _params) do
    categories = categories() |> Enum.reject(&special_category?/1)

    files =
      categories
      |> Task.async_stream(fn cat -> {String.to_charlist(cat <> ".m3u"), m3u(cat)} end)
      |> Enum.map(fn {:ok, file} -> file end)
      |> Enum.to_list()

    {:ok, {_filename, zip}} = :zip.create(~c"playlists.zip", files, [:memory])

    conn |> send_download({:binary, zip}, filename: "playlists.zip")
  end

  # TODO: distinguish "special" categories (like psas),
  # so that we can zip up the non-special playlists
  # checkbox on category page?
end
