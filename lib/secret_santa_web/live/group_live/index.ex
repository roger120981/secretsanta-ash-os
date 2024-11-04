defmodule SecretSantaWeb.GroupLive.Index do
  use SecretSantaWeb, :live_view

  require Logger

  alias SecretSanta.Groups
  alias SecretSanta.Groups.Group

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Loading groups")
    groups = Groups.list_groups!()
    Logger.debug("Loaded #{Enum.count(groups)} groups.")

    {:ok, stream(socket, :groups, groups)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Group")
    |> assign(:group, Groups.get_group_by_id!(id))
  end

  defp apply_action(socket, :new, _params) do
    form =
      AshPhoenix.Form.for_create(Group, :create,
        forms: [
          element_ratios: [
            type: :list,
            as: "form_name",
            create_action: :create,
          ],
        ]
      )

    socket
    |> assign(:page_title, "New Group")
    |> assign(:form, form |> to_form())
    |> assign(:group_id, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Groups")
    |> assign(:group, nil)
  end

  @impl true
  def handle_info({SecretSantaWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, group} <- Groups.get_group_by_id(id),
         {:ok, _} <- Groups.delete_group(group) do
      {:noreply, stream_delete(socket, :groups, group)}
    else
      _ ->
        Logger.warning("No group with ID #{id} exists! Cannot delete")
        {:noreply, socket}
    end
  end
end
