defmodule TeaVent.Example do
  @moduledoc """

  An example of how to use TeaVent:

      iex> state = %{users: %{1 => User.new("Jose")}, events: []}
      iex> state = TeaVent.Example.dispatch([:users], :create, %{name: "Michal"}, state)
      iex> state = TeaVent.Example.dispatch([:users], :create, %{name: "W-M"}, state)
      iex> state = TeaVent.Example.dispatch([:users, 1], :delete, %{}, state)
      %{
        events: [
          %TeaVent.Event{
            changed_subject: %TeaVent.Example.User{
              deleted: true,
              id: 1222957077122717130,
              name: "Jose"
            },
            changes: %{deleted: true},
            data: %{},
            meta: %{},
            name: :delete,
            subject: %TeaVent.Example.User{
              deleted: false,
              id: 1222957077122717130,
              name: "Jose"
            },
            topic: [:users, 1]
          },
          %TeaVent.Event{
            changed_subject: %TeaVent.Example.User{
              deleted: false,
              id: 2900897003816872049,
              name: "W-M"
            },
            changes: nil,
            data: %{name: "W-M"},
            meta: %{},
            name: :create,
            subject: nil,
            topic: [:users]
          },
          %TeaVent.Event{
            changed_subject: %TeaVent.Example.User{
              deleted: false,
              id: 1064675457221707330,
              name: "Michal"
            },
            changes: nil,
            data: %{name: "Michal"},
            meta: %{},
            name: :create,
            subject: nil,
            topic: [:users]
          }
        ],
        users: %{
          1 => %TeaVent.Example.User{
            deleted: true,
            id: 1222957077122717130,
            name: "Jose"
          },
          1064675457221707330 => %TeaVent.Example.User{
            deleted: false,
            id: 1064675457221707330,
            name: "Michal"
          },
          2900897003816872049 => %TeaVent.Example.User{
            deleted: false,
            id: 2900897003816872049,
            name: "W-M"
          }
        }
      }
  """

  alias TeaVent.Event

  defmodule User do
    defstruct [:id, :name, deleted: false]

    def new(name) do
      %__MODULE__{id: Enum.random(1..10_000_000_000_000_000_000), name: name}
    end
  end

  alias __MODULE__.User

  def dispatch(topic, name, data \\ %{}, state \\ %{users: %{1 => User.new("Jose")}, events: []}) do
    dispatch_event(TeaVent.Event.new(topic, name, data), state)
  end

  def dispatch_event(event, state \\ %{users: %{1 => User.new("Jose")}, events: []}) do
    TeaVent.dispatch_event(event,
      reducer: &reduce/2,
      context_provider: injected_context_provider(state)
    )

    receive do
      new_state -> new_state
    end
  end

  def reduce(user = %User{}, %Event{topic: [:users, 1], name: :delete}) do
    {:ok, %User{user | deleted: true}}
  end

  def reduce(_, %Event{topic: [:users], name: :create, data: %{name: username}}) do
    {:ok, User.new(username)}
  end

  def injected_context_provider(injected_state = %{users: users, events: events}) do
    fn
      event = %Event{topic: [:users]}, reducer ->
        case reducer.(nil, event) do
          {:ok, event = %Event{changed_subject: created_user}} ->
            new_state = %{
              injected_state
              | users: users |> Map.put(created_user.id, created_user),
                events: [event | events]
            }

            send_state_to_self(new_state)
            {:ok, event}

          error ->
            error
        end

      %Event{topic: [:users, id]}, reducer ->
        result =
          users
          |> Map.get(id, {:error, :not_found})
          |> IO.inspect()
          |> reducer.()

        case result do
          {:ok, event = %Event{changed_subject: updated_user}} ->
            new_state = %{
              injected_state
              | users: users |> Map.put(id, updated_user),
                events: [event | events]
            }

            send_state_to_self(new_state)
            {:ok, event}

          error ->
            error
        end
    end
  end

  defp send_state_to_self(state) do
    IO.inspect(state)
    send(self(), state)
  end
end
