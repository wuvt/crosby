defmodule CrosbyWeb.PageController do
  use CrosbyWeb, :controller

  def home(conn, _params) do
    categories = Crosby.Repo.all Crosby.Category

    conn
    |> assign(:categories, categories)
    |> render(:home)
  end
end
