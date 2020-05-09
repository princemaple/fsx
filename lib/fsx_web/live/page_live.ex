defmodule FsxWeb.PageLive do
  use FsxWeb, :live_view

  @goto_parent "⮌"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, selected: nil, cwd: ["/"], root: File.cwd!(), vsn: 0)}
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
        @goto_parent ->
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
  def handle_event("goto", %{"path" => path}, socket) do
    cwd = path |> String.split("@@") |> Enum.reverse()

    {:noreply, assign(socket, cwd: cwd, selected: nil)}
  end

  @impl true
  def handle_event(
        "select",
        %{"selection" => selection},
        %{assigns: %{selected: selection, cwd: cwd, root: root}} = socket
      ) do
    uri = %URI{
      path: "/download",
      query: URI.encode_query(path: Path.join(root, Path.join(cwd ++ [selection])))
    }

    {:noreply, redirect(socket, external: URI.to_string(uri))}
  end

  @impl true
  def handle_event("select", %{"selection" => selection}, socket) do
    {:noreply, assign(socket, selected: selection)}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, update(socket, :vsn, &(&1 + 1))}
  end

  @impl true
  def handle_event("new_folder", %{"name" => name}, %{assigns: %{cwd: cwd, root: root}} = socket) do
    File.mkdir!(Path.join(root, cwd |> Path.join() |> Path.join(name)))
    {:noreply, update(socket, :vsn, &(&1 + 1))}
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

    {:noreply, update(socket, :vsn, &(&1 + 1))}
  end

  @impl true
  def handle_event("keypress", _params, socket) do
    {:noreply, socket}
  end
end
