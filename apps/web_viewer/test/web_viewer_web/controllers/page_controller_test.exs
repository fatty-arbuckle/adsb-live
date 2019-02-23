defmodule WebViewerWeb.PageControllerTest do
  use WebViewerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<table id=\"aircraftTable\""
  end
end
