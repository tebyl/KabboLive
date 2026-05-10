extends RefCounted

# ──── Floor ────
const FLOOR_A        := Color(0.90, 0.84, 0.70)   # even tile — warm sand
const FLOOR_B        := Color(0.82, 0.76, 0.61)   # odd tile  — darker sand
const FLOOR_BLOCKED  := Color(0.58, 0.66, 0.58)   # occupied tile
const FLOOR_OUTLINE  := Color(0.40, 0.32, 0.22, 0.48)
const FLOOR_SHADOW   := Color(0.00, 0.00, 0.00, 0.09)
const PLACEMENT_VALID := Color(0.20, 1.00, 0.35, 0.45)
const PLACEMENT_INVALID := Color(1.00, 0.15, 0.15, 0.45)

# ──── Wood (chair / table shared base) ────
const WOOD_LIGHT     := Color(0.74, 0.52, 0.26)
const WOOD_MID       := Color(0.56, 0.34, 0.14)
const WOOD_DARK      := Color(0.36, 0.18, 0.07)

# ──── Chair ────
const CHAIR_BODY        := Color(0.56, 0.28, 0.12)
const CHAIR_CUSHION     := Color(0.90, 0.62, 0.36)
const CHAIR_CUSHION_HI  := Color(0.96, 0.78, 0.54)
const CHAIR_DARK        := Color(0.34, 0.16, 0.06)
const CHAIR_SLAT        := Color(0.56, 0.28, 0.13)

# ──── Table ────
const TABLE_BODY     := Color(0.62, 0.44, 0.20)
const TABLE_TOP      := Color(0.94, 0.86, 0.68)
const TABLE_RUNNER   := Color(0.82, 0.60, 0.30)
const TABLE_DARK     := Color(0.40, 0.22, 0.08)
const TABLE_APRON    := Color(0.46, 0.24, 0.10)

# ──── Sofa ────
const SOFA_BODY      := Color(0.24, 0.50, 0.40)
const SOFA_DARK      := Color(0.16, 0.34, 0.26)
const SOFA_LIGHT     := Color(0.38, 0.68, 0.54)
const SOFA_CUSHION   := Color(0.30, 0.58, 0.46)
const SOFA_SEAM      := Color(0.20, 0.42, 0.32)
const SOFA_ARM       := Color(0.20, 0.40, 0.30)
const SOFA_ARM_TOP   := Color(0.28, 0.54, 0.40)

# ──── Plant ────
const PLANT_POT      := Color(0.58, 0.28, 0.12)
const PLANT_POT_DARK := Color(0.48, 0.22, 0.08)
const PLANT_POT_RIM  := Color(0.70, 0.36, 0.18)
const PLANT_POT_HI   := Color(0.80, 0.46, 0.24)
const PLANT_SOIL     := Color(0.22, 0.14, 0.08)
const PLANT_STEM     := Color(0.20, 0.44, 0.16)
const PLANT_LEAF_DK  := Color(0.14, 0.48, 0.20)
const PLANT_LEAF     := Color(0.22, 0.62, 0.28)
const PLANT_LEAF_LT  := Color(0.34, 0.78, 0.40)
const PLANT_LEAF_HI  := Color(0.50, 0.90, 0.50)

# ──── Rug ────
const RUG_BODY       := Color(0.48, 0.28, 0.26)
const RUG_FILL       := Color(0.54, 0.32, 0.28)
const RUG_BORDER     := Color(0.82, 0.68, 0.34)
const RUG_BORDER_DIM := Color(0.82, 0.68, 0.34, 0.65)
const RUG_CENTER     := Color(0.86, 0.76, 0.46)
const RUG_CENTER_HI  := Color(0.92, 0.86, 0.62)
const RUG_CROSS      := Color(0.82, 0.68, 0.34, 0.45)

# ──── Bed ────
const BED_FRAME      := Color(0.48, 0.32, 0.18)
const BED_FRAME_DK   := Color(0.32, 0.20, 0.10)
const BED_MATTRESS   := Color(0.86, 0.84, 0.80)
const BED_PILLOW     := Color(0.96, 0.94, 0.90)
const BED_BLANKET    := Color(0.36, 0.52, 0.72)
const BED_BLANKET_HI := Color(0.54, 0.70, 0.90)
const BED_BLANKET_DK := Color(0.26, 0.38, 0.56)

# ──── Lamp ────
const LAMP_BASE      := Color(0.28, 0.22, 0.14)
const LAMP_POLE      := Color(0.40, 0.30, 0.18)
const LAMP_SHADE     := Color(0.90, 0.80, 0.50)
const LAMP_SHADE_HI  := Color(1.00, 0.94, 0.68)
const LAMP_GLOW      := Color(1.00, 0.92, 0.60, 0.55)

# ──── Bookshelf ────
const SHELF_WOOD     := Color(0.46, 0.30, 0.16)
const SHELF_WOOD_DK  := Color(0.28, 0.18, 0.08)
const SHELF_BOOK_A   := Color(0.70, 0.22, 0.20)
const SHELF_BOOK_B   := Color(0.24, 0.48, 0.76)
const SHELF_BOOK_C   := Color(0.28, 0.58, 0.32)
const SHELF_BOOK_D   := Color(0.78, 0.64, 0.18)

# ──── Desk ────
const DESK_SURFACE   := Color(0.70, 0.52, 0.28)
const DESK_TOP       := Color(0.82, 0.66, 0.40)
const DESK_EDGE      := Color(0.54, 0.38, 0.18)
const DESK_LEG       := Color(0.38, 0.26, 0.12)

# ──── Poster ────
const POSTER_BOARD   := Color(0.86, 0.82, 0.74)
const POSTER_FRAME   := Color(0.26, 0.18, 0.10)
const POSTER_STRIPE_A := Color(0.36, 0.60, 0.88)
const POSTER_STRIPE_B := Color(0.88, 0.52, 0.24)

# ──── Big plant ────
const BIGPLANT_POT   := Color(0.42, 0.30, 0.18)
const BIGPLANT_POT_DK := Color(0.30, 0.20, 0.10)
const BIGPLANT_POT_RIM := Color(0.54, 0.38, 0.22)

# ──── Red rug ────
const RED_RUG_BODY   := Color(0.52, 0.16, 0.14)
const RED_RUG_FILL   := Color(0.60, 0.20, 0.16)
const RED_RUG_BORDER := Color(0.88, 0.50, 0.22)
const RED_RUG_BORDER_DIM := Color(0.88, 0.50, 0.22, 0.65)
const RED_RUG_CENTER := Color(0.94, 0.78, 0.40)
const RED_RUG_CENTER_HI := Color(1.00, 0.90, 0.58)
const RED_RUG_CROSS  := Color(0.88, 0.50, 0.22, 0.45)

# ──── Floor tile ────
const TILE_BASE      := Color(0.72, 0.68, 0.62)
const TILE_GROUT     := Color(0.52, 0.48, 0.44)
const TILE_HI        := Color(0.86, 0.84, 0.78)
const TILE_SHADOW    := Color(0.40, 0.36, 0.32, 0.50)

# ──── Shadows / outlines ────
const SHADOW_SOFT    := Color(0.04, 0.04, 0.06, 0.28)
const SHADOW_MED     := Color(0.04, 0.04, 0.06, 0.42)
const OUTLINE_DARK   := Color(0.07, 0.04, 0.03, 0.68)

# ──── Avatar (player) ────
const AVATAR_SKIN    := Color(0.84, 0.62, 0.44)
const AVATAR_SKIN_HI := Color(0.94, 0.74, 0.56)
const AVATAR_HAIR    := Color(0.18, 0.10, 0.06)
const AVATAR_SHIRT   := Color(0.14, 0.32, 0.72)
const AVATAR_SHIRT_HI:= Color(0.32, 0.56, 0.94)
const AVATAR_PANTS   := Color(0.14, 0.16, 0.30)
const AVATAR_BOOTS   := Color(0.16, 0.09, 0.05)
const AVATAR_COLLAR  := Color(0.88, 0.86, 0.82)
const AVATAR_CHEEK   := Color(0.90, 0.50, 0.42)
const AVATAR_MOUTH   := Color(0.58, 0.26, 0.18)
const AVATAR_EYE     := Color(0.08, 0.06, 0.08)
const AVATAR_SHINE   := Color(1.00, 1.00, 1.00)

# ──── NPC ────
const NPC_BODY       := Color(0.80, 0.38, 0.12)
const NPC_HAIR       := Color(0.05, 0.20, 0.45)
const NPC_BADGE      := Color(0.28, 0.80, 0.92)
const NPC_BADGE_DK   := Color(0.10, 0.50, 0.70)
const NPC_EYE        := Color(0.10, 0.18, 0.40)
const NPC_SHINE      := Color(0.60, 0.90, 1.00)
const NPC_LABEL      := Color(0.70, 0.92, 1.00)
const NPC_BOOTS      := Color(0.12, 0.14, 0.22)
const NPC_PANTS      := Color(0.16, 0.18, 0.34)
