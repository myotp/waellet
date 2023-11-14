defmodule Waellet.Base58 do
  @base58_chars "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
  @enc @base58_chars
       |> String.codepoints()
       |> Enum.with_index()
       |> Enum.map(fn {c, i} -> {i, c} end)
       |> Map.new()

  @dec @base58_chars
       |> String.codepoints()
       |> Enum.with_index()
       |> Map.new()

  def encode(bin) do
    :binary.decode_unsigned(bin, :big)
    |> to_digits([])
    |> Enum.map(&@enc[&1])
    |> Enum.join()
  end

  defp to_digits(0, acc), do: acc

  defp to_digits(x, acc) do
    d = div(x, 58)
    r = rem(x, 58)
    to_digits(d, [r | acc])
  end

  def from_digits(digits, acc \\ 0)
  def from_digits([], acc), do: acc
  def from_digits([h | t], acc), do: from_digits(t, acc * 58 + h)

  def decode(s) do
    s
    |> String.codepoints()
    |> Enum.map(&Map.fetch!(@dec, &1))
    |> from_digits()
    |> :binary.encode_unsigned(:big)
  end
end
