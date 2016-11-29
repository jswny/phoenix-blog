defmodule PhoenixBlog.UserController do
  use PhoenixBlog.Web, :controller
  alias PhoenixBlog.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> PhoenixBlog.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        # |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end