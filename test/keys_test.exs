defmodule KeysTest do
  alias Waellet.Keys

  use ExUnit.Case
  doctest Waellet.Keys

  test "ae地址编码解码" do
    pubkey = <<154, 136, 169, 185, 17, 143, 195, 48, 6, 179, 203, 155, 156, 18, 26,
      67, 151, 165, 207, 232, 86, 86, 234, 91, 240, 136, 114, 95, 111, 98, 100, 145>>
    ae_addr = "ak_2B4MrTiFWAcrFuaanjpsYvUB1ep5zNzNZmUYyDwnES9jgpsvPF"
    assert ae_addr == Keys.encode_pubkey(pubkey)

    ae_addr2 =
      ae_addr
      |> Keys.decode_addr()
      |> Keys.encode_pubkey()
    assert ae_addr == ae_addr2
  end

end
