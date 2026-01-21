import Ecto.Query, only: [from: 2]

defmodule CrosbyWeb.CategoryLive do
  alias Ecto.Changeset
  use CrosbyWeb, :live_view
  alias Crosby.{Repo, Entry, Category}

  def mount(params, _session, socket) do
    category_name = params |> Map.get("category")

    category =
      Repo.one(from category in Category, where: category.name == ^category_name)

    socket =
      socket
      |> assign(:category, category)
      |> update_entries

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-row justify-between">
        <h1 class="text-4xl sm:text-5xl">{@category.name} playlist</h1>
        <span class="my-auto">
          <.button
            phx-click="add_entry"
            phx-value-category-id={@category.id}
            aria-label="Add a new song"
          >
            <.icon name="hero-plus" />
          </.button>
        </span>
      </div>

      <hr />
      
    <!-- TODO: should maybe use the generic table component -->
      <ul class="space-y-2">
        <%= for entry <- @entries do %>
          <li class="w-full flex flex-row justify-between rounded-sm bg-base-200 px-4 py-2">
            <input
              id={"entry-#{entry.id}"}
              type="text"
              phx-keyup="update_entry_path"
              phx-debounce={500}
              phx-value-entry-id={entry.id}
              class="my-auto w-full"
              value={entry.path}
            />
            <.button
              phx-click="delete_entry"
              phx-value-entry-id={entry.id}
              data-confirm={"Are you sure you want to delete \"#{entry.path}\"?"}
            >
              <.icon name="hero-trash" />
            </.button>
          </li>
        <% end %>
      </ul>
    </Layouts.app>
    """
  end

  # TODO: make it possible to actually change this path :P
  def handle_event("add_entry", _params, socket) do
    path = DateTime.utc_now() |> DateTime.to_iso8601()

    Repo.insert!(%Entry{path: "CHANGEME #{path}", category_id: socket.assigns.category.id})

    {:noreply, socket |> update_entries}
  end

  def handle_event("delete_entry", params, socket) do
    entry_id = params |> Map.get("entry-id") |> String.to_integer()

    Repo.delete!(%Entry{id: entry_id})

    {:noreply, socket |> update_entries}
  end

  def handle_event("update_entry_path", params, socket) do
    entry_id = params |> Map.get("entry-id") |> String.to_integer()
    path = params |> Map.get("value")

    Repo.get!(Entry, entry_id) |> Changeset.change(%{path: path}) |> Repo.update!()

    {:noreply, socket |> update_entries}
  end

  def update_entries(socket) do
    category_id = socket.assigns.category.id

    entries =
      Repo.all(from entry in Entry, where: entry.category_id == ^category_id)

    socket |> assign(:entries, entries)
  end
end
