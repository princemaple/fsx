defmodule FsxWeb.LsComponent do
  use FsxWeb, :live_component

  @goto_parent "⮌"

  @impl true
  def mount(socket) do
    {:ok, assign(socket, selected: [], selected_index: nil)}
  end

  @impl true
  def update(%{cwd: cwd, root: root} = assigns, socket) do
    {:ok,
     assign(socket,
       ls: ls(assigns),
       cwd: cwd,
       root: root,
       path: Path.join(root, Path.join(cwd))
     )}
  end

  @impl true
  def update(%{refresh: true}, socket) do
    {:ok, assign(socket, ls: ls(socket.assigns))}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, assign(socket, ls: ls(socket.assigns))}
  end

  @impl true
  def handle_event(
        "select",
        %{"folder" => "true", "selection" => selection},
        %{assigns: %{selected: [selection], cwd: cwd}} = socket
      ) do
    cwd =
      case selection do
        @goto_parent ->
          {_folder, cwd} = List.pop_at(cwd, -1)
          cwd

        folder ->
          cwd ++ [folder]
      end

    send_update(FsxWeb.PageLive, cwd: cwd)
    {:noreply, assign(socket, selected: [], selected_index: nil)}
  end

  @impl true
  def handle_event(
        "select",
        %{"selection" => selection},
        %{assigns: %{selected: [selection], cwd: cwd, root: root}} = socket
      ) do
    uri = %URI{
      path: "/download",
      query:
        URI.encode_query(path: Path.join(root, Path.join(cwd ++ [selection])))
    }

    {:noreply, redirect(socket, external: URI.to_string(uri))}
  end

  @impl true
  def handle_event(
        "select",
        %{"selection" => selection, "index" => index},
        socket
      ) do
    {:noreply, assign(socket, selected: [selection], selected_index: index)}
  end

  defp ls(%{cwd: cwd, root: root}) do
    {folders, files} =
      root
      |> Path.join(Path.join(cwd ++ ["*"]))
      |> Path.wildcard()
      |> Enum.split_with(&File.dir?/1)

    folders =
      case cwd do
        ["/"] ->
          folders

        _ ->
          [@goto_parent | folders]
      end

    %{
      files: files |> Enum.map(&Path.basename/1),
      folders: folders |> Enum.map(&Path.basename/1)
    }
  end
end
