defmodule FsxWeb.LsComponent do
  use FsxWeb, :live_component

  @goto_parent "⮌"

  def update(%{cwd: cwd, root: root, selected: selected} = assigns, socket) do
    {:ok,
     assign(socket,
       ls: ls(assigns),
       cwd: cwd,
       root: root,
       selected: selected,
       path: Path.join(root, Path.join(cwd))
     )}
  end

  defp ls(%{cwd: cwd, root: root}) do
    ls =
      root
      |> Path.join(Path.join(cwd ++ ["*"]))
      |> Path.wildcard()
      |> Enum.map(fn x -> {File.dir?(x), Path.basename(x)} end)

    case cwd do
      ["/"] ->
        ls

      _ ->
        [{true, @goto_parent} | ls]
    end
  end
end
