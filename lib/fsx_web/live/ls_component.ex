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

    send(self(), {:update_cwd, cwd})
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
        %{"index" => index, "shiftKey" => true},
        %{
          assigns: %{
            ls: %{files: files, folders: folders},
            selected_is_folder: is_folder,
            selected_index: selected_index,
            selected: selected
          }
        } = socket
      ) do
    items =
      if is_folder do
        folders
      else
        files
      end

    index = String.to_integer(index)

    range =
      if index < selected_index do
        index..selected_index
      else
        selected_index..index
      end

    new_selected =
      items
      |> Enum.with_index()
      |> Enum.filter(fn {_, i} -> i in range end)
      |> Enum.map(fn {x, _} -> x end)

    {:noreply,
     assign(socket,
       selected: Enum.uniq(new_selected ++ selected),
       selected_index: index
     )}
  end

  @impl true
  def handle_event(
        "select",
        %{"selection" => selection, "folder" => is_folder, "index" => index},
        socket
      ) do
    {:noreply,
     assign(socket,
       selected: [selection],
       selected_is_folder: is_folder == "true",
       selected_index: String.to_integer(index)
     )}
  end

  @impl true
  def handle_event(
        "keypress",
        %{"key" => "Backspace", "ctrlKey" => true, "shiftKey" => shift},
        %{assigns: %{cwd: cwd, root: root, selected: [selected]}} = socket
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
