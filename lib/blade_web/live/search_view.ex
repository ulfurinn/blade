defmodule BladeWeb.SearchView do
  use BladeWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_, _, socket) do
    socket
    |> assign(:name, Blade.name())
    |> assign_term()
    |> assign_results()
    |> ok()
  end

  @impl Phoenix.LiveView
  def handle_event("search", %{"term" => term}, socket) do
    socket
    |> search(String.trim(term))
    |> noreply()
  end

  defp search(socket, "") do
    socket
    |> assign_term("")
    |> assign_results([])
  end

  defp search(socket, term) do
    socket
    |> assign_term(term)
    |> assign_results(Blade.search(term))
  end

  defp assign_term(socket, term \\ "") do
    assign(socket, :search, %{"term" => term})
  end

  defp assign_results(socket, results \\ []) do
    assign(socket, :results, results)
  end

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}
end
