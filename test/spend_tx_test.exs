defmodule WaelletSpendTxTest do
  alias Waellet.SpendTx

  use ExUnit.Case
  doctest Waellet.SpendTx

  test "测试SpendTx序列化" do
    pk1 = <<102, 0, 231, 67, 105, 25, 28, 127, 215, 224, 75, 98, 36, 195, 120, 248,
      90, 126, 159, 73, 183, 137, 226, 185, 238, 11, 17, 133, 130, 192, 100, 198>>
    pk2 = <<154, 136, 169, 185, 17, 143, 195, 48, 6, 179, 203, 155, 156, 18, 26, 67,
      151, 165, 207, 232, 86, 86, 234, 91, 240, 136, 114, 95, 111, 98, 100, 145>>
    send_amount = 0.003
    spend_tx = Waellet.SpendTx.spend(pk1, pk2, send_amount, 1, "My test 888")
    bin = Waellet.SpendTx.serialize_to_binary(spend_tx)
    expected_bin =
       <<248, 99, 12, 1, 161, 1, 102, 0, 231, 67, 105, 25, 28, 127, 215, 224, 75, 98,
         36, 195, 120, 248, 90, 126, 159, 73, 183, 137, 226, 185, 238, 11, 17, 133,
         130, 192, 100, 198, 161, 1, 154, 136, 169, 185, 17, 143, 195, 48, 6, 179, 203,
         155, 156, 18, 26, 67, 151, 165, 207, 232, 86, 86, 234, 91, 240, 136, 114, 95,
         111, 98, 100, 145, 135, 10, 168, 123, 238, 83, 128, 0, 134, 20, 2, 70, 47, 96,
      0, 0, 1, 139, 77, 121, 32, 116, 101, 115, 116, 32, 56, 56, 56>>
    assert expected_bin == bin
  end

  test "测试最终生成的网络包数据" do
    pk1 = <<102, 0, 231, 67, 105, 25, 28, 127, 215, 224, 75, 98, 36, 195, 120, 248,
      90, 126, 159, 73, 183, 137, 226, 185, 238, 11, 17, 133, 130, 192, 100, 198>>
    pk2 = <<154, 136, 169, 185, 17, 143, 195, 48, 6, 179, 203, 155, 156, 18, 26, 67,
      151, 165, 207, 232, 86, 86, 234, 91, 240, 136, 114, 95, 111, 98, 100, 145>>

    sk1 = <<26, 35, 209, 202, 174, 93, 155, 56, 113, 58, 188, 71, 131, 253, 40, 205, 116, 163, 102, 79, 87, 85, 9, 179, 223, 162, 116, 175, 130, 12, 90, 165>>

    send_amount = 0.003
    spend_tx = SpendTx.spend(pk1, pk2, send_amount, 1, "My test 888")
    result = SpendTx.prepare_network_data(spend_tx, sk1)
    assert "tx_+K0LAfhCuEBz5+N9cqzG84VPNhLa6U8KvmTAKbhqoIc35+T5LhojHXVUfk9A7/OdTeSse7D0jITK4Vxg2PJF0iSG3mmNu0AFuGX4YwwBoQFmAOdDaRkcf9fgS2Ikw3j4Wn6fSbeJ4rnuCxGFgsBkxqEBmoipuRGPwzAGs8ubnBIaQ5elz+hWVupb8IhyX29iZJGHCqh77lOAAIYUAkYvYAAAAYtNeSB0ZXN0IDg4OK05/As=" == result
  end

end
