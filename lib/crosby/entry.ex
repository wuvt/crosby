defmodule Crosby.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :path, :string
    field :category_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:path])
    |> validate_required([:path])
  end
end
