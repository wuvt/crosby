import Ecto.Query, only: [from: 2]

defmodule CrosbyWeb.PageController do
  use CrosbyWeb, :controller

  def home(conn, _params) do
    categories = Crosby.Repo.all(Crosby.Category)

    conn
    |> assign(:categories, categories)
    |> render(:home)
  end

  def category(conn, params) do
    category_name = params |> Map.get("category")

    # could probably be one query, but it's still a constant number (two)

    category =
      Crosby.Repo.one(from category in Crosby.Category, where: category.name == ^category_name)

    entries =
      Crosby.Repo.all(from entry in Crosby.Entry, where: entry.category_id == ^category.id)

    conn
    |> assign(:category, category)
    |> assign(:entries, entries)
    |> render(:category)
  end
end
