@enum(BKStatusBits,
    BK_EMPTY             =  0x00,
    BK_FREE              =  0x01,  # free node
    BK_S                 =  0x02,  # node belongs to search trees S
    BK_T                 =  0x04,  # node belongs to search trees T
    BK_ACTIVE            =  0x08,  # node is active or not
    BK_ORPHAN            =  0x10,  # node originates from orphan
    BK_S_ACTIVE          =  0x0a,  # BK_S | BK_ACTIVE
    BK_T_ACTIVE          =  0x0c,  # BK_T | BK_ACTIVE
)

Base.convert(::Type{BKStatusBits}, x::UInt8) = BKStatusBits(x)

Base.:~(x::BKStatusBits) = ~UInt8(x)

Base.:|(x::UInt8, y::BKStatusBits) = x | UInt8(y)
Base.:|(x::BKStatusBits, y::UInt8) = y | x
Base.:|(x::BKStatusBits, y::BKStatusBits) = UInt8(x) | y

Base.:&(x::UInt8, y::BKStatusBits) = x & UInt8(y)
Base.:&(x::BKStatusBits, y::UInt8) = y & x
Base.:&(x::BKStatusBits, y::BKStatusBits) = UInt8(x) & y

Base.:⊻(x::UInt8, y::BKStatusBits) = x ⊻ UInt8(y)
Base.:⊻(x::BKStatusBits, y::UInt8) = y ⊻ x
Base.:⊻(x::BKStatusBits, y::BKStatusBits) = UInt8(x) ⊻ y

Base.:(==)(x::Integer, y::BKStatusBits) = x == UInt8(y)
Base.:(==)(x::BKStatusBits, y::Integer) = y == x
Base.:(==)(x::BKStatusBits, y::BKStatusBits) = UInt8(x) == y
