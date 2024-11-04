defmodule SecretSantaWeb.GroupLive.Show do
  use SecretSantaWeb, :live_view

  require Logger

  alias SecretSanta.Groups
  alias SecretSanta.Groups.Budget

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    group = Groups.get_group_by_id!(id)

    {:noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:group, group)}
  end

  # ! private functions

  defp format_budget(budget = %Budget{}) do
    budget
    |> to_string()
  end

  defp page_title(:show), do: "Show Group"
  defp page_title(:edit), do: "Edit Group"

  defp sorted_by(list, key) do
    list
    |> Enum.sort_by(fn e -> get_in(e, [Access.key!(key)]) end)
  end
end
