defmodule FsxWeb.NewFolderComponent do
  use FsxWeb, :live_component

  @impl true
  def handle_event(
        "new_folder",
        %{"name" => name},
        %{assigns: %{cwd: cwd, root: root}} = socket
      ) do
    File.mkdir!(Path.join(root, cwd |> Path.join() |> Path.join(name)))
    send_update(FsxWeb.LsComponent, id: "ls", refresh: true)
    {:noreply, socket}
  end
end
