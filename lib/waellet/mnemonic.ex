# 这里，行为表现参考 https://iancoleman.io/bip39/
# 具体定义参考蜜蜂书结构，这里对外统一处理各种错误情况
# 最终生成标准单空格分割字符串
defmodule Waellet.Mnemonic do
  @wordlist "data/words.txt"
            |> Path.expand(__DIR__)
            |> File.read!()
            |> String.split("\n", trim: true)

  @w2i @wordlist
       |> Enum.zip(0..2047)
       |> Map.new()

  @i2w 0..2047
       |> Enum.zip(@wordlist)
       |> Map.new()

  def validate_mnemonic(input) do
    with words <- mnemonic_input_to_words(input),
         12 <- Enum.count(words),
         :ok <- all_words_valid?(words),
         :ok <- valid_mnemonic_checksum?(words) do
      {:ok, Enum.join(words, " ")}
    else
      n when is_integer(n) ->
        {:error, "#{n} words"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp mnemonic_input_to_words(input), do: String.split(input, ~r{\s}, trim: true)

  defp all_words_valid?(words) do
    valid_words = @wordlist |> MapSet.new()

    case Enum.all?(words, fn word -> MapSet.member?(valid_words, word) end) do
      true ->
        :ok

      false ->
        {:error, "Some words not in wordlist"}
    end
  end

  defp valid_mnemonic_checksum?(words) do
    bin =
      words
      |> Enum.map(fn w -> Map.fetch!(@w2i, w) end)
      |> Enum.map(fn x -> <<x::11>> end)
      |> :erlang.list_to_bitstring()

    <<entropy::binary-size(16), checksum::unsigned-size(4)>> = bin

    case :crypto.hash(:sha256, entropy) do
      <<^checksum::unsigned-size(4), _::bitstring>> ->
        :ok

      _ ->
        {:error, "Wrong checksum"}
    end
  end

  # 12助记词原理，总共132个位，前边128位为随机entropy，最后4位为校验和
  # 用户输入11词，能够涵盖11*11=121位，还需要随机生成7bits补足128bits的随机entropy部分
  # 12 words * 11 bits = 132 bits
  # 132 bits = 12 * 11 words
  #         -> 11 words + 11 bits
  #                     -> 7 (random_bits) + 4 (checksum_bits)
  def complete_mnemonic(input) when is_binary(input) do
    words = mnemonic_input_to_words(input)
    11 = Enum.count(words)
    <<_::1, random7bits::7>> = :crypto.strong_rand_bytes(1)

    entropy =
      words
      |> Enum.map(fn word -> Map.fetch!(@w2i, word) end)
      |> Enum.map(fn x -> <<x::11>> end)
      |> List.insert_at(-1, <<random7bits::7>>)
      |> :erlang.list_to_bitstring()

    <<checksum::size(4), _::bitstring>> = :crypto.hash(:sha256, entropy)
    <<w12::11>> = <<random7bits::7, checksum::4>>
    last_word = Map.fetch!(@i2w, w12)
    Enum.join(words ++ [last_word], " ")
  end
end
