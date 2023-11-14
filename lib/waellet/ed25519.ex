# https://tools.ietf.org/html/rfc8032
# ed25519的椭圆曲线方程如下:
# y^2=x^3+486662x^2+x,modulop=2^255-19
defmodule Waellet.Ed25519 do
  require Integer
  import Bitwise

  # p of edwards25519 in [RFC7748] (i.e., 2^255 - 19)
  @p (1 <<< 255) - 19

  # d of edwards25519 in [RFC7748] (i.e., -121665/121666)
  @d 37_095_705_934_669_439_343_138_083_508_754_565_189_542_113_879_843_219_016_388_785_533_085_940_283_555

  # order of edwards25519 in [RFC7748]
  @l (1 <<< 252) + 27_742_317_777_372_353_535_851_937_790_883_648_493

  @bx 15_112_221_349_535_400_772_501_151_409_588_531_511_454_012_693_041_857_206_046_113_283_949_847_762_202
  @by 46_316_835_694_926_478_169_428_394_003_475_163_141_307_993_866_256_225_615_783_033_603_165_251_855_960

  # 一些常数的定义[rfc8032] 5.1.  Ed25519ph, Ed25519ctx, and Ed25519
  def p, do: @p
  def l, do: @l
  def bx, do: @bx
  def by, do: @by

  def d do
    (-121_665 * modp_inv(121_666))
    |> mod(@p)
  end

  defdelegate mod(a, b), to: Integer

  # 3. EdDSA Algorithm
  # 公式 a * x^2 + y^2 = 1 + d * x^2 * y^2
  # 其中 a=-1, d=@d
  def left(x, y) do
    (-ppow(x, 2) + ppow(y, 2))
    |> mod(@p)
  end

  def right(x, y) do
    (1 + @d * ppow(x, 2) * ppow(y, 2))
    |> mod(@p)
  end

  def modp_inv(x) do
    pow(x, @p - 2, @p)
  end

  def square_root_candidate(a) do
    y = div(@p + 3, 8)

    ppow(a, y)
    |> mod(@p)
  end

  def ppow(x, n), do: pow(x, n, @p)

  # 二分快速乘方法
  def pow(_, 0, _), do: 1

  def pow(x, n, m) when Integer.is_even(n) do
    half_n = div(n, 2)
    x1 = pow(x, half_n, m)
    mod(x1 * x1, m)
  end

  def pow(x, n, m) when Integer.is_odd(n) do
    half_n = div(n, 2)
    x1 = pow(x, half_n, m)
    mod(x1 * x1 * x, m)
  end

  # 5.1.5.  Key Generation
  def derive_public_key(secret) do
    secret
    |> hash()
    |> take_only_lower_32_bytes()
    |> prune_buffer()
    |> mul({@bx, @by})
    |> encode_point()
  end

  defp hash(x), do: :crypto.hash(:sha512, x)
  defp hashint(x), do: x |> hash() |> :binary.decode_unsigned(:little)

  defp take_only_lower_32_bytes(<<x::little-size(256), _::binary>>), do: x

  defp prune_buffer(x) do
    x0 = x &&& (1 <<< 254) - 8
    x0 ||| 1 <<< 254
  end

  defp mul(x, point) do
    scalarmult(x, point)
  end

  defp scalarmult(0, _pair) do
    {0, 1}
  end

  defp scalarmult(e, p) do
    q = e |> div(2) |> scalarmult(p)
    q = edwards(q, q)

    case e &&& 1 do
      1 -> edwards(q, p)
      _ -> q
    end
  end

  defp edwards({x1, y1}, {x2, y2}) do
    x = (x1 * y2 + x2 * y1) * modp_inv(1 + @d * x1 * x2 * y1 * y2)
    y = (y1 * y2 + x1 * x2) * modp_inv(1 - @d * x1 * x2 * y1 * y2)
    {mod(x, @p), mod(y, @p)}
  end

  defp encode_point({x, y}) do
    val =
      y
      |> band(0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      |> bor((x &&& 1) <<< 255)

    <<val::little-size(256)>>
  end

  def signature(m, sk, pk \\ nil)

  def signature(m, sk, nil) do
    pk = derive_public_key(sk)
    signature(m, sk, pk)
  end

  def signature(m, sk, pk) do
    h = hash(sk)
    a = a_from_hash(h)
    r = hashint(:binary.part(h, 32, 32) <> m)
    bigr = r |> scalarmult({@bx, @by}) |> encode_point
    s = mod(r + hashint(bigr <> pk <> m) * a, @l)
    bigr <> <<s::little-size(256)>>
  end

  def a_from_hash(h) do
    h
    |> take_only_lower_32_bytes()
    |> prune_buffer()
  end
end
