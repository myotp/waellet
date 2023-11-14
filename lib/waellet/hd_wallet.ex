defmodule Waellet.HdWallet do
  import Bitwise

  # https://github.com/aeternity/aepp-sdk-python/blob/58ac2d12e0062896a473c254781ee397e3da318e/aeternity/hdwallet.py#L12-L13
  @hardened_offset 0x80000000
  @ae_seed "ed25519 seed"

  # 这里，是从一个具体的12词生成的seed字符串比如
  def seed_to_extended_key(seed) do
    decoded_seed = Base.decode16!(seed, case: :lower)
    hashed_seed = :crypto.mac(:hmac, :sha512, @ae_seed, decoded_seed)
    <<secret_key::binary-32, chain_code::binary-32>> = hashed_seed
    {secret_key, chain_code}
  end

  # 参考 https://github.com/aeternity/aepp-sdk-python/blob/58ac2d12e0062896a473c254781ee397e3da318e/aeternity/hdwallet.py#L139
  # TODO: BIP44 /m/44'/457'/0'/0'/0'
  def derive_path(root_key, []), do: root_key

  def derive_path(key, [i | t]) do
    index = i ||| @hardened_offset
    key = derived_child_key(key, index)
    derive_path(key, t)
  end

  def derived_child_key({secret_key, chain_code}, i) do
    hmac_data = <<0>> <> secret_key <> <<i::big-32>>
    hashed = :crypto.mac(:hmac, :sha512, chain_code, hmac_data)
    <<secret_key::binary-32, chain_code::binary-32>> = hashed
    {secret_key, chain_code}
  end
end
