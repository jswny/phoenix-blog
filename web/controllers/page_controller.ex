defmodule PhoenixBlog.PageController do
  use PhoenixBlog.Web, :controller

  def index(conn, _params) do
    if (logged_in = Addict.Helper.is_logged_in(conn)) do
      %{:email => user} = Addict.Helper.current_user(conn)
      render conn, "index.html", logged_in: logged_in, user: user
    else
      render conn, "index.html", logged_in: logged_in, user: "NONE"
    end
  end
end
