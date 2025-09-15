# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Crosby.Repo.insert!(%Crosby.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Crosby.Repo
alias Crosby.Category 

Repo.insert! %Category {
  name: "psa"
}

Repo.insert! %Category {
  name: "ids"
}

Repo.insert! %Category {
  name: "lnr"
}

Repo.insert! %Category {
  name: "soo"
}

Repo.insert! %Category {
  name: "pro"
}

Repo.insert! %Category {
  name: "backup"
}
