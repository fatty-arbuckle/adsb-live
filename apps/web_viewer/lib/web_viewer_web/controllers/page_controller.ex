defmodule WebViewerWeb.PageController do
  use WebViewerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
