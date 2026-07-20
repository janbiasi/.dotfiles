-- auto-exclude AUR packages whose PKGBUILD changed in the last 3 days.
yay.create_autocmd("UpgradeSelect", {
  desc = "skip recently modified AUR upgrades",
  callback = function(event)
    yay.log.info("excluding AUR packages modified in the last 2 days")
    local exclude = {}
    local recent_cutoff = os.time() - (2 * 24 * 60 * 60)
    for _, pkg in ipairs(event.data.upgrades) do
      if pkg.repository == "aur" and pkg.last_modified >= recent_cutoff then
        yay.log.warn("excluding recently modified AUR package: ", pkg.name)
        table.insert(exclude, pkg.name)
      end
    end

    return { exclude = exclude, skip_menu = false }
  end,
})

-- warn (does not exclude) when an AUR package's maintainer changes.
local cache_dir = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")) .. "/yay"
local cache_file = cache_dir .. "/maintainers"

local function load_cache()
  local cache = {}
  local f = io.open(cache_file, "r")
  if not f then return cache end
  for line in f:lines() do
    local name, maintainer = line:match("^([^=]+)=(.*)$")
    if name then
      cache[name] = maintainer
    end
  end
  f:close()
  return cache
end

local function save_cache(cache)
  os.execute('mkdir -p "' .. cache_dir .. '"')
  local f = assert(io.open(cache_file, "w"))
  for name, maintainer in pairs(cache) do
    f:write(name .. "=" .. maintainer .. "\n")
  end
  f:close()
end

yay.create_autocmd("UpgradeSelect", {
  desc = "warn on AUR maintainer changes",
  callback = function(event)
    yay.log.info("checking for AUR maintainer changes")
    local cache = load_cache()
    local dirty = false

    for _, pkg in ipairs(event.data.upgrades) do
      if pkg.repository == "aur" and pkg.maintainer ~= "" then
        local cached = cache[pkg.name]
        if cached == nil then
          -- First time seeing this package: seed the cache silently.
          cache[pkg.name] = pkg.maintainer
          dirty = true
        elseif cached == pkg.maintainer then
          yay.log.debug("match correct: " .. pkg.name .. " " .. pkg.maintainer)
        else
          yay.log.error("new maintainer, double check build files: ", pkg.name,
            "(was: " .. cached .. ", now: " .. pkg.maintainer .. ")")
          cache[pkg.name] = pkg.maintainer
          dirty = true
        end
      end
    end

    if dirty then
      yay.log.info("saving maintainer cache:", cache_file)
      save_cache(cache)
    end

    return { exclude = {}, skip_menu = false }
  end,
})
