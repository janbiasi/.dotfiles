-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
  name      = "workspace-terminal",
  match     = { class = "com\\.mitchellh\\.ghostty" },
  workspace = "1",
})

hl.window_rule({
  name      = "workspace-browser",
  match     = { class = "(brave-origin|firefox)" },
  workspace = "2",
})

hl.window_rule({
  name      = "workspace-editor",
  match     = { class = "(dev\\.zed\\.Zed|code|codium)" },
  workspace = "3",
})

hl.window_rule({
  name      = "workspace-t3code",
  match     = { class = "com.t3tools.T3Code" },
  workspace = "4",
})

hl.window_rule({
  name     = "polkit-agent-surface",
  match    = { class = "^org\\.kde\\.polkit-kde-authentication-agent-1$" },
  rounding = 12,
})

hl.window_rule({
  name      = "workspace-openchamber",
  match     = { class = "(?i)openchamber" },
  workspace = "4",
})

hl.window_rule({
  name      = "workspace-codex",
  match     = { class = "chatgpt" },
  workspace = "4",
})

hl.window_rule({
  name      = "workspace-citrix",
  match     = { class = "(?i)(citrix.*|selfservice|wfica)" },
  workspace = "6",
})

hl.window_rule({
  name      = "workspace-obsidian",
  match     = { class = "^md\\.obsidian\\.Obsidian$" },
  workspace = "8",
})

hl.window_rule({
  name      = "workspace-whatsapp",
  match     = { class = "^brave-web\\.whatsapp\\.com__-Default$" },
  workspace = "9",
})

hl.window_rule({
  name      = "workspace-teams",
  match     = { class = ".*ompifgpmddkgmclendfeacglnodjjndh.*" },
  workspace = "9",
})

local suppressMaximizeRule = hl.window_rule({
  -- Ignore maximize requests from all apps.
  name           = "suppress-maximize-events",
  match          = { class = ".*" },
  suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(false)

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.layer_rule({
  name            = "hide-screen-share-border-from-capture",
  match           = { namespace = "^screen-share-border$" },
  no_screen_share = true,
  no_anim         = true,
})

-- Hyprland-run windowrule
hl.window_rule({
  name  = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move  = "20 monitor_h-120",
  float = true,
})

-- Floating windows

hl.window_rule({
  name           = "float-1password",
  match          = { class = "^com\\.onepassword\\.OnePassword$" },
  float          = true,
  center         = true,
  -- No size rule: the auth prompts share this class and title, and any resize
  -- right after mapping (forced size, restored maximize) animates from the
  -- top-left instead of popping in. The main window restores its own size.
  suppress_event = "maximize",
})

hl.window_rule({
  name   = "float-waypaper",
  match  = { class = "^waypaper$" },
  size   = { 900, 650 },
  float  = true,
  center = true,
})
