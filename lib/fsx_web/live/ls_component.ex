defmodule FsxWeb.LsComponent do
  use FsxWeb, :live_component

  @goto_parent_icon "⮌"

  def update(%{cwd: cwd, root: root, selected: selected} = assigns, socket) do
    {:ok, assign(socket, ls: ls(assigns), cwd: cwd, root: root, selected: selected)}
  end

  defp ls(%{cwd: cwd, root: root}) do
    ls =
      (cwd ++ ["*"])
      |> Path.join()
      |> Path.wildcard()
      |> Enum.map(fn x -> {File.dir?(x), Path.basename(x)} end)

    if cwd == root do
      ls
    else
      [{true, @goto_parent_icon} | ls]
    end
  end
end
