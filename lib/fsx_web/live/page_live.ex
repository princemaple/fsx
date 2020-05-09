defmodule FsxWeb.PageLive do
  use FsxWeb, :live_view

  @goto_parent "⮌"

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
  def handle_event(
        "keypress",
        %{"key" => "Backspace", "ctrlKey" => true, "shiftKey" => shift},
        %{assigns: %{cwd: cwd, root: root, selected: selected}} = socket
      ) do
    path = Path.join(root, cwd |> Path.join() |> Path.join(selected))

    cond do
      File.dir?(path) and shift -> File.rm_rf!(path)
      File.dir?(path) -> File.rmdir!(path)
      File.regular?(path) -> File.rm!(path)
    end

    send_update(FsxWeb.LsComponent, id: "ls", refresh: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("keypress", _params, socket) do
    {:noreply, socket}
  end
end
