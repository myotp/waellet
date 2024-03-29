defmodule Ed25519Test do
  alias Waellet.Ed25519
  use ExUnit.Case
  doctest Waellet.Ed25519

  test "简单测试几个常数" do
    assert Ed25519.p == 57896044618658097711785492504343953926634992332820282019728792003956564819949
    assert Ed25519.l == 7237005577332262213973186563042994240857116359379907606001950938285454250989
  end

  test "验证order的回来1的关系" do
    p = Waellet.Ed25519.p
    assert 1 == Waellet.Ed25519.pow(13, p-1, p)
    assert 13 == Waellet.Ed25519.pow(13, p, p)

    x = Waellet.Ed25519.pow(13, p-2, p)
    assert 1 = Integer.mod(x * 13, p)
  end

  test "验证base{x,y}满足等式条件" do
    x = Waellet.Ed25519.bx
    y = Waellet.Ed25519.by
    left = Waellet.Ed25519.left(x, y)
    right = Waellet.Ed25519.right(x, y)
    assert left == right
  end

  test "验证我的private key例子" do
    private_key = <<79, 241, 143, 47, 173, 94, 187, 251, 196, 127, 27, 29, 48, 79, 57, 177, 17, 80, 71, 89, 250, 197, 91, 69, 203, 135, 44, 190, 147, 146, 244, 190>>
    expected_pubkey = <<91, 143, 225, 59, 82, 163, 238, 96, 209, 120, 143, 76, 72, 19, 57, 213, 218, 211, 42, 105, 186, 72, 233, 172, 202, 30, 126, 195, 13, 69, 90, 27>>
    assert expected_pubkey == Waellet.Ed25519.derive_public_key(private_key)
  end

  test "验证签名部分" do
    sk1 = <<26, 35, 209, 202, 174, 93, 155, 56, 113, 58, 188, 71, 131, 253, 40, 205, 116, 163, 102, 79, 87, 85, 9, 179, 223, 162, 116, 175, 130, 12, 90, 165>>
    m1 = <<0>>
    m2 = <<1,1>>
    m3 = <<0,1,2,3,4,5,6>>
    b1 = Waellet.Ed25519.signature(m1, sk1)
    b2 = Waellet.Ed25519.signature(m2, sk1)
    b3 = Waellet.Ed25519.signature(m3, sk1)
    e1 = <<235, 73, 48, 250, 117, 163, 116, 136, 74, 181, 217, 214, 43, 217, 146, 74, 41, 8, 161, 94, 86, 77, 19, 29, 194, 184, 90, 147, 221, 126, 187, 11, 182, 81, 122, 46, 105, 21, 41, 162, 94, 28, 108, 199, 126, 50, 115, 110, 188, 164, 32, 157, 229, 86, 52, 207, 150, 180, 184, 50, 246, 207, 4, 3>>
    e2 = <<218, 240, 25, 25, 39, 154, 85, 226, 32, 74, 208, 217, 193, 1, 124, 219, 102, 39, 100, 217, 181, 105, 172, 46, 78, 148, 18, 138, 54, 164, 238, 147, 198, 223, 215, 85, 225, 69, 239, 189, 39, 191, 23, 154, 151, 79, 12, 203, 56, 37, 212, 225, 190, 218, 45, 253, 72, 46, 114, 86, 31, 181, 244, 0>>
    e3 = <<67, 152, 130, 119, 57, 16, 169, 214, 145, 38, 76, 66, 104, 230, 107, 199, 213, 216, 180, 153, 77, 235, 118, 173, 125, 108, 68, 102, 75, 156, 79, 43, 193, 144, 154, 210, 157, 102, 208, 43, 200, 39, 103, 69, 37, 139, 117, 87, 7, 197, 190, 17, 22, 10, 4, 70, 56, 177, 220, 228, 230, 247, 89, 6>>
    assert b1 == e1
    assert b2 == e2
    assert b3 == e3
  end

end
