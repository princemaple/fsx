defmodule FsxWeb.FileController do
  use FsxWeb, :controller

  def download(conn, %{"path" => path}) do
    send_download(conn, {:file, path})
  end

  def upload(conn, %{"dir" => dir, "file" => %{filename: filename, path: path}}) do
    File.cp!(path, Path.join(dir, filename))
    json conn, %{ok: true}
  end
end
