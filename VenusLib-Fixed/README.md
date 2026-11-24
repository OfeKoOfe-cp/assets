# Venus Lib — Solara-fixed

Fixed copy of `Venus Lib Source.lua` from
`ro0ti/Roblox-Scripting-UI` for use on Solara.

## The bug

The upstream library calls `Drawing.new("Triangle")` for some UI
shapes. Solara's `Triangle` Drawing object requires a **number** for
`Visible`, while the library writes a boolean:

```
init:5056: expected number when setting Visible
```

Traced by wrapping `Drawing.new` and logging the failing property:

```
shape=Triangle prop=Visible val=true err=expected number when setting Visible
```

## The fix

In `drawing:new(shape)`, triangular shapes are mapped to `Square`,
which Solara handles correctly:

```lua
function drawing:new(shape)
    if shape == "Triangle" or shape == "Quad" then shape = "Square" end
    local obj = Drawing.new(shape)
    ...
end
```

Everything else is byte-for-byte upstream.

## Load

```lua
local Venus = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/OfeKoOfe-cp/assets/main/VenusLib-Fixed/Venus%20Lib%20Source.lua"
))()

local W = Venus:Load({
  Name = "My Hub",
  SizeX = 600,
  SizeY = 620,
  Theme = "Midnight",
  Folder = "MyHubNoSave",
  Extension = "json",
})
```

`lib:Load{...}` was verified working on Solara after the patch.
