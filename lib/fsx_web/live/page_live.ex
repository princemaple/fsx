defmodule FsxWeb.PageLive do
  use FsxWeb, :live_view

  @goto_parent_icon "⮌"

  @impl true
  def mount(_params, _session, socket) do
    cwd = File.cwd!() |> Path.split()
    {:ok, assign(socket, selected: nil, cwd: cwd, root: cwd, vsn: 0)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "select",
        %{"folder" => "true", "selection" => selection},
        %{assigns: %{selected: selection, cwd: cwd}} = socket
      ) do
    cwd =
      case selection do
        @goto_parent_icon ->
          {_folder, cwd} = List.pop_at(cwd, -1)
          cwd

        folder ->
          cwd ++ [folder]
      end

    {:noreply,
     socket
     |> assign(selected: nil, cwd: cwd)
     |> push_patch(to: "/explore")}
  end

  @impl true
  def handle_event(
        "select",
        %{"selection" => selection},
        %{assigns: %{selected: selection, cwd: cwd}} = socket
      ) do
    uri = %URI{path: "/download", query: URI.encode_query(path: Path.join(cwd ++ [selection]))}
    {:noreply, redirect(socket, external: URI.to_string(uri))}
  end

  @impl true
  def handle_event("select", %{"selection" => selection}, socket) do
    {:noreply, assign(socket, selected: selection)}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, update(socket, :vsn, & &1 + 1)}
  end

  @impl true
  def handle_event("new_folder", %{"name" => name}, socket) do
    File.mkdir(socket.assigns.cwd |> Path.join() |> Path.join(name))
    {:noreply, update(socket, :vsn, & &1 + 1)}
  end


  end
end
