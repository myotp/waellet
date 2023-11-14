# 主要的API模块
defmodule Waellet.Keys do
  alias Waellet.Base58

  # 这里，主要参考的是aeserialization/src/aeser_api_encoder.erl的实现，主要是看到了2次hash256做法
  # 我原本已经完成了Base58的本身的实现，这里就是知道额外调用两次hash256并做校验加入即可
  def encode_pubkey(pubkey) do
    pubkey
    |> append_check()
    |> Base58.encode()
    |> encode_with_prefix(:account_pubkey)
  end

  def decode_addr("ak_" <> addr) do
    <<pubkey::binary-32, _check::binary-4>> = Base58.decode(addr)
    pubkey
  end

  defp append_check(bin) do
    <<check::32-bitstring, _::binary>> =
      bin
      |> hash256()
      # 两次hash256
      |> hash256()

    bin <> check
  end

  defp hash256(s), do: :crypto.hash(:sha256, s)

  defp encode_with_prefix(s, :account_pubkey), do: "ak_" <> s
end
