@enum(BKStatusBits,
    BK_EMPTY               =  0x00,
    BK_FREE                =  0x01,  # free node
    BK_S                   =  0x02,  # node belongs to search trees S
    BK_T                   =  0x04,  # node belongs to search trees T
    BK_ACTIVE              =  0x08,  # node is active or not
    BK_SATURATED           =  0x10,  # at least one edge of this node is saturated
    BK_S_ACTIVE            =  0x0a,  # BK_S | BK_ACTIVE
    BK_T_ACTIVE            =  0x0c,  # BK_T | BK_ACTIVE
    BK_S_SATURATED         =  0x12,  # BK_S | BK_SATURATED
    BK_T_SATURATED         =  0x14,  # BK_T | BK_SATURATED
    BK_S_ACTIVE_SATURATED  =  0x1a,  # BK_S | BK_ACTIVE  | BK_SATURATED
    BK_T_ACTIVE_SATURATED  =  0x1c,  # BK_T | BK_ACTIVE  | BK_SATURATED
)

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
