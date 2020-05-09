defmodule FsxWeb.PageLive do
  use FsxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected: [],
       selected_index: nil,
       cwd: ["/"],
       root: File.cwd!()
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("goto", %{"path" => path}, socket) do
    cwd = path |> String.split("@@") |> Enum.reverse()

    {:noreply, assign(socket, cwd: cwd, selected: [])}
  end

  @impl true
  def handle_info({:update_cwd, cwd}, socket) do
    {:noreply, assign(socket, cwd: cwd)}
  end
end
