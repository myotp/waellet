defmodule Waellet.Rlp do

  @limit_small 55
  @limit_big  127
  @bytes_offset  128
  @list_offset        192

  def encode(<<x>>) when x <= @limit_big do
    <<x>>
  end

  def encode(bin) when is_binary(bin) do
    bin_size = byte_size(bin)
    case bin_size <= @limit_small do
      true ->
        <<(@bytes_offset + bin_size)::8, bin::binary>>
      false ->
        size_bin = :binary.encode_unsigned(bin_size)
        size_size = byte_size(size_bin)
        offset = @bytes_offset + @limit_small
        <<(offset + size_size)::8,
          size_bin::binary, bin::binary>>
    end
  end

  def encode([]), do: <<@list_offset>>

  def encode(list) when is_list(list) do
    bin =
      list
      |> Enum.map(&encode/1)
      |> :erlang.list_to_binary()

    bin_size = byte_size(bin)
    case bin_size <= @limit_small do
      true ->
        # list内部所有bin序列化之后小于等于55个长度的话，直接偏移量192+N即可
        <<(@list_offset + bin_size)::8, bin::binary>>
      false ->
        # 否则，大于等于56的话，用额外若干字节表示大小
        size_bin = :binary.encode_unsigned(bin_size)
        size_size = byte_size(size_bin)
        offset = @list_offset + @limit_small
        <<(offset + size_size)::8,
          size_bin::binary, bin::binary>>
    end

  end

end
