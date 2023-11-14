# 根据PBKDF2算法，生成对应的master key私钥种子
defmodule Waellet.Seed do
  @max_iterations 2048
  @salt "mnemonic"

  def generate(mnemonic) do
    seed = pbkdf2(mnemonic)
    Base.encode16(seed, case: :lower)
  end

  defp pbkdf2(words) do
    iter = 1
    salt = <<@salt::binary, iter::integer-big-32>>
    data = :crypto.mac(:hmac, :sha512, words, salt)
    do_pbkdf2(words, iter + 1, data, data)
  end

  defp do_pbkdf2(_, it_count, _, acc) when it_count > @max_iterations, do: acc

  defp do_pbkdf2(words, it_count, data, acc) do
    new_data = :crypto.mac(:hmac, :sha512, words, data)
    new_acc = :crypto.exor(new_data, acc)
    do_pbkdf2(words, it_count + 1, new_data, new_acc)
  end
end
