defmodule WaelletRlpTest do
  alias Waellet.Rlp

  use ExUnit.Case
  doctest Waellet.Rlp

  test "测试RLP编码" do
    assert <<0>> == Rlp.encode(<<0>>)
    assert <<1>> == Rlp.encode(<<1>>)
    assert <<2>> == Rlp.encode(<<2>>)
    assert <<127>> == Rlp.encode(<<127>>)
    assert <<128+1, 128>> == Rlp.encode(<<128>>)   # 128 + 1
    assert <<128+2, 0, 0>> == Rlp.encode(<<0, 0>>) # 128 + 2
    assert <<128+2, 1, 2>> == Rlp.encode(<<1, 2>>) # 128 + 2
    assert <<128+3, 1, 2, 3>> == Rlp.encode(<<1, 2, 3>>) # 128 + 3

    assert <<88>> == dup(88, 1) |> Rlp.encode()
    assert <<130, 88, 88>> == dup(88, 2) |> Rlp.encode()
    assert <<128+3, 88, 88, 88>> == dup(88, 3) |> Rlp.encode()
    # 55个字节及以下，直接128偏移量上加进去表示即可
    assert <<183, 88, 88, _::binary-size(53)>> = dup(88, 55) |> Rlp.encode() # 128 + 55
    # 56个字节及以上，额外若干字节表示
    assert <<184, 56, 88, 88, _::binary-size(54)>> = dup(88, 56) |> Rlp.encode() # 128 + 55 + 1
    # 255个字节，刚好额外一个字节还可以装下
    assert <<184, 255, 88, 88, _::binary-size(253)>> = dup(88, 255) |> Rlp.encode() # 128 + 55 + 1
    assert <<185, 2, 37, 88, 88, _::binary-size(547)>> = dup(88, 256 *2 + 37) |> Rlp.encode() # 547 = 512 + 37 - 2

    assert <<192>> == Rlp.encode([])
    assert <<192+1, 88>> == Rlp.encode([<<88>>]) # 192 + 1
    assert <<192+3, 128+2, 88, 88>> == Rlp.encode([<<88, 88>>]) # 192 + 3, 128 + 2
    assert <<192+3, 128+2, 88, 88>> == Rlp.encode([dup(88, 2)]) # 192 + 3, 128 + 2
    assert <<192+3, 128+2, 88, 88>> == Rlp.encode([dup(88, 2)]) # 192 + 3, 128 + 2
    # 当中元素54个，所占最终bin体积为55，也就是<<182, 88...88>>，在192上最大偏移量192+55=247
    assert <<247, 182, 88, 88, _::binary-size(52)>> = Rlp.encode([dup(88, 54)])
    # 当中元素55个，所占最终bin体积为56，也就是<<183, 88...88,88>>，在192上超过最大偏移量55了
    # 用192+55+N来用N表示额外N个字节表示后边的体积数
    assert <<248, 56, 183, 88, 88, _::binary-size(53)>> = Rlp.encode([dup(88, 55)])

    # 元素255个，最终bin体积257=0x01_01，表示大小2字节192+55+2=249
    assert <<249, 1, 1, 184, 255, 88, 88, _::binary-size(253)>> = Rlp.encode([dup(88, 255)])

  end

  defp dup(x, n) when x <= 255 do
    List.duplicate(x, n) |> :erlang.list_to_binary()
  end

end
