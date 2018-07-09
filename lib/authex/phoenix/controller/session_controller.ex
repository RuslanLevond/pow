defmodule Authex.Phoenix.SessionController do
  @moduledoc false
  use Authex.Phoenix.Web, :controller

  alias Authex.Authorization.{Plug,
                              Plug.RequireAuthenticated,
                              Plug.RequireNotAuthenticated}
  alias Authex.Phoenix.{ViewHelpers, RouterHelpers}

  plug RequireNotAuthenticated when action in [:new, :create]
  plug RequireAuthenticated when action in [:delete]

  @spec new(Conn.t(), map()) :: Conn.t()
  def new(conn, _params) do
    ViewHelpers.render(conn, "new.html")
  end

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Plug.authenticate_user(user_params)
    |> handle_authentication(conn)
  end

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Plug.clear_authenticated_user()
    |> put_flash(:info, "Signed out successfullly.")
    |> redirect(to: RouterHelpers.after_sign_out_path(conn))
  end

  defp handle_authentication({:ok, conn}, _conn) do
    conn
    |> put_flash(:info, "User successfully signed in.")
    |> redirect(to: RouterHelpers.after_sign_in_path(conn))
  end
  defp handle_authentication({:error, changeset}, conn) do
    conn
    |> put_flash(:error, "Could not sign in user. Please try again.")
    |> ViewHelpers.render("new.html", changeset: changeset)
  end
end
