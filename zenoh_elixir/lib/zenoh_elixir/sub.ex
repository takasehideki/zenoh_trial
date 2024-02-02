defmodule ZenohElixir.Sub do
  def main do
    session = Zenohex.open()
    Session.declare_subscriber(session, "key/expression", fn msg -> sub_callback(msg) end)
  end

  def sub_callback(msg) do
    IO.puts "[sub.ex] " <> msg
  end
end
