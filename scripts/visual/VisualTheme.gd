extends RefCounted

# ──── Floor ────
const FLOOR_A        := Color(0.90, 0.84, 0.70)   # even tile — warm sand
const FLOOR_B        := Color(0.82, 0.76, 0.61)   # odd tile  — darker sand
const FLOOR_BLOCKED  := Color(0.58, 0.66, 0.58)   # occupied tile
const FLOOR_OUTLINE  := Color(0.40, 0.32, 0.22, 0.48)
const FLOOR_SHADOW   := Color(0.00, 0.00, 0.00, 0.09)

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
const RUG_BODY       := Color(0.68, 0.20, 0.18)
const RUG_FILL       := Color(0.74, 0.24, 0.20)
const RUG_BORDER     := Color(0.96, 0.80, 0.38)
const RUG_BORDER_DIM := Color(0.96, 0.80, 0.38, 0.65)
const RUG_CENTER     := Color(0.98, 0.88, 0.52)
const RUG_CENTER_HI  := Color(1.00, 0.96, 0.70)
const RUG_CROSS      := Color(0.96, 0.80, 0.38, 0.45)

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
