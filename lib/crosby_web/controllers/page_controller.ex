defmodule CrosbyWeb.PageController do
  use CrosbyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
