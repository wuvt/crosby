import Ecto.Query, only: [from: 2]

defmodule CrosbyWeb.HomeLive do
  alias Ecto.Changeset
  use CrosbyWeb, :live_view
  alias Crosby.{Repo, Category, Entry}

  def mount(_params, _session, socket) do
    {:ok, socket |> update_categories}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-row justify-between">
        <h1 class="text-4xl sm:text-5xl">Playlists</h1>
        <span class="my-auto">
          <.button phx-click="add_category" aria-label="Add a new playlist">
            <.icon name="hero-plus" />
          </.button>
        </span>
      </div>

      <hr />

      <ul class="space-y-2">
        <%= for category <- @categories do %>
          <li class="w-full flex flex-row justify-between rounded-sm bg-base-200 px-4 py-2">
            <input
              id={"category-#{category.id}"}
              type="text"
              phx-keyup="update_category_name"
              phx-debounce={500}
              phx-value-category-id={category.id}
              class="my-auto w-full"
              value={category.name}
            />
            <div class="flex flex-row gap-2">
              <.button navigate={~p"/category/#{category.name}"}>
                <.icon name="hero-pencil-square" />
              </.button>
              <.button
                phx-click="delete_category"
                phx-value-category-id={category.id}
                data-confirm={"Are you ABSOLUTELY sure you want to delete the \"#{category.name}\" playlist?"}
              >
                <.icon name="hero-trash" />
              </.button>
            </div>
          </li>
        <% end %>
      </ul>
    </Layouts.app>
    """
  end

  def handle_event("add_category", _params, socket) do
    # HACK: i mean look at it. maybe change category pages to use ids?
    id = :rand.uniform(2 ** 64)
    Repo.insert!(%Category{name: "changeme-" <> Integer.to_string(id)})

    {:noreply, socket |> update_categories()}
  end

  def handle_event("delete_category", %{"category-id" => id}, socket) do
    id = String.to_integer(id)

    from(e in Entry, where: e.category_id == ^id) |> Repo.delete_all()
    Repo.get!(Category, id) |> Repo.delete!()

    {:noreply, socket |> update_categories()}
  end

  def handle_event("update_category_name", %{"category-id" => id, "value" => name}, socket) do
    id = String.to_integer(id)

    Repo.get!(Category, id) |> Changeset.change(%{name: name}) |> Repo.update!()

    {:noreply, socket |> update_categories()}
  end

  def update_categories(socket) do
    categories =
      Repo.all(from category in Category, order_by: category.name)

    socket |> assign(:categories, categories)
  end
end
