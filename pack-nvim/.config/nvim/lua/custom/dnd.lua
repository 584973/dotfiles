-- custom/dnd.lua — Dungeon of Thornwall, a text-adventure D&D game for Neovim
-- Open/close with <leader>dg

local M = {}

-- ── State ──────────────────────────────────────────────────────────────────
local state = {
  game_buf  = nil,
  input_buf = nil,
  game_win  = nil,
  input_win = nil,
  active    = false,

  player        = nil,
  current_room  = nil,
  in_combat     = false,
  current_enemy = nil,
  phase         = "start", -- start | name | class | play | dead
}

-- ── Dice ───────────────────────────────────────────────────────────────────
local function roll(sides) return math.random(1, sides) end

local function roll_dice(str) -- e.g. "2d6", "1d8+3"
  local n, s, b = str:match("(%d+)d(%d+)%+?(-?%d*)")
  n, s = tonumber(n), tonumber(s)
  b = tonumber(b) or 0
  local t = b
  for _ = 1, n do t = t + roll(s) end
  return t
end

-- ── World definition ───────────────────────────────────────────────────────
local ROOMS = {
  town = {
    id   = "town",
    name = "Thornwall Village",
    desc = "A small village encircled by crumbling stone walls. "
        .. "The Rusty Flagon tavern sign creaks in the wind. "
        .. "A blacksmith hammers steel nearby.",
    exits   = { north = "forest", east = "shop" },
  },
  shop = {
    id   = "shop",
    name = "Mira's Emporium",
    desc = "Shelves lined with glowing vials, worn weapons, "
        .. "and curiosities. A gnome woman eyes you over half-moon spectacles.",
    exits = { west = "town" },
    shop  = true,
    wares = {
      { name="Health Potion",  price=15, type="potion",  heal=20 },
      { name="Iron Sword",     price=40, type="weapon",  damage="1d8",  slot="weapon" },
      { name="Leather Armor",  price=30, type="armor",   defense=2,     slot="armor" },
      { name="Steel Shield",   price=25, type="shield",  defense=1,     slot="offhand" },
      { name="Elven Boots",    price=35, type="trinket", dex_bonus=2,   slot="feet" },
    },
  },
  forest = {
    id   = "forest",
    name = "Whisperwood Forest",
    desc = "Ancient oaks tower overhead, their canopy filtering cold moonlight. "
        .. "Something rustles in the underbrush. You tighten your grip.",
    exits          = { south = "town", north = "dungeon_entrance", east = "clearing" },
    enemy_table    = { "goblin", "wolf" },
    encounter_rate = 0.50,
  },
  clearing = {
    id    = "clearing",
    name  = "Moonlit Clearing",
    desc  = "A circular glade with a moss-covered altar at its heart. "
         .. "Strange runes pulse faintly blue. "
         .. "A small chest rests before the altar.",
    exits        = { west = "forest" },
    chest        = { gold = 30, items = { { name="Elixir of Swiftness", type="potion", heal=0, dex_bonus=2 } } },
    chest_looted = false,
  },
  dungeon_entrance = {
    id   = "dungeon_entrance",
    name = "Dungeon Entrance",
    desc = "Iron-banded doors hang open, darkness spilling out like held breath. "
        .. "Claw marks scar the stone frame. The air reeks of rot.",
    exits = { south = "forest", down = "dungeon_b1" },
  },
  dungeon_b1 = {
    id   = "dungeon_b1",
    name = "Dungeon — Level 1",
    desc = "Dripping walls, torchless sconces. "
        .. "Bones crunch underfoot. Something shuffles in the dark.",
    exits          = { up = "dungeon_entrance", north = "dungeon_b2" },
    enemy_table    = { "skeleton", "goblin_shaman" },
    encounter_rate = 0.65,
  },
  dungeon_b2 = {
    id            = "dungeon_b2",
    name          = "The Lich's Throne Room",
    desc          = "A vast hall of black stone. A throne built from skulls looms "
                 .. "at the far end. Cold blue fire burns in braziers. "
                 .. "The Lich turns its empty eye-sockets toward you.",
    exits         = { south = "dungeon_b1" },
    boss          = "lich",
    boss_defeated = false,
  },
}

-- ── Bestiary ───────────────────────────────────────────────────────────────
local BESTIARY = {
  goblin = {
    name    = "Goblin Scout",
    hp      = 12, max_hp = 12,
    atk     = "1d4+1", def = 0,
    xp      = 20,
    gold    = { 2, 8 },
    loot    = nil,
  },
  wolf = {
    name    = "Dire Wolf",
    hp      = 20, max_hp = 20,
    atk     = "1d6+2", def = 1,
    xp      = 35,
    gold    = { 0, 0 },
    loot    = nil,
  },
  skeleton = {
    name    = "Skeleton Warrior",
    hp      = 18, max_hp = 18,
    atk     = "1d6+1", def = 2,
    xp      = 50,
    gold    = { 5, 15 },
    loot    = { chance=0.30, item={ name="Bone Buckler", type="shield", defense=1, slot="offhand" } },
  },
  goblin_shaman = {
    name    = "Goblin Shaman",
    hp      = 15, max_hp = 15,
    atk     = "1d8",   def = 0,
    xp      = 60,
    gold    = { 8, 20 },
    loot    = { chance=0.40, item={ name="Hex Charm", type="trinket", defense=1, slot="feet" } },
  },
  lich = {
    name    = "Malachar the Lich",
    hp      = 80, max_hp = 80,
    atk     = "2d8+3", def = 4,
    xp      = 500,
    gold    = { 100, 200 },
    loot    = { chance=1.00, item={ name="Staff of Dominion", type="weapon", damage="2d6+3", slot="weapon" } },
    boss    = true,
  },
}

-- ── Classes ────────────────────────────────────────────────────────────────
local CLASSES = {
  warrior = {
    label  = "Warrior",
    desc   = "Strong and durable. Bonus HP and melee damage.",
    hp     = 32, str = 4, dex = 1, int_ = 0,
    atk_die = "1d8",
  },
  mage = {
    label  = "Mage",
    desc   = "Arcane spellcaster. Lower HP, but devastating spells.",
    hp     = 18, str = 0, dex = 1, int_ = 5,
    atk_die = "1d6",
  },
  rogue = {
    label  = "Rogue",
    desc   = "Swift and cunning. High crit chance and dodge.",
    hp     = 22, str = 1, dex = 5, int_ = 1,
    atk_die = "1d6",
    crit_bonus = 0.15,
  },
}

-- ── Highlights ─────────────────────────────────────────────────────────────
local function setup_hl()
  local h = vim.api.nvim_set_hl
  h(0, "DndTitle",  { fg="#f5c842", bold=true })
  h(0, "DndRoom",   { fg="#89b4fa", bold=true })
  h(0, "DndDesc",   { fg="#cdd6f4" })
  h(0, "DndSystem", { fg="#a6e3a1", italic=true })
  h(0, "DndDmg",    { fg="#f38ba8", bold=true })
  h(0, "DndHeal",   { fg="#a6e3a1", bold=true })
  h(0, "DndGold",   { fg="#f9e2af" })
  h(0, "DndDanger", { fg="#f38ba8", bold=true })
  h(0, "DndInput",  { fg="#cba6f7" })
  h(0, "DndSep",    { fg="#45475a" })
  h(0, "DndXP",     { fg="#89dceb" })
end

-- ── Output helpers ─────────────────────────────────────────────────────────
local NS = vim.api.nvim_create_namespace("dnd_hl")

local function out(lines, hl)
  local buf = state.game_buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
  vim.bo[buf].modifiable = true
  if type(lines) == "string" then lines = { lines } end
  local top = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_set_lines(buf, top, top, false, lines)
  if hl then
    for i = 1, #lines do
      vim.api.nvim_buf_add_highlight(buf, NS, hl, top + i - 1, 0, -1)
    end
  end
  vim.bo[buf].modifiable = false
  if state.game_win and vim.api.nvim_win_is_valid(state.game_win) then
    local last = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(state.game_win, { last, 0 })
  end
end

local function sep()
  out("  ─────────────────────────────────────────────────────────", "DndSep")
end

local function blank() out("") end

-- ── Room display ────────────────────────────────────────────────────────────
local function show_room(room)
  sep()
  out("  ⚔  " .. room.name, "DndRoom")
  sep()
  out("  " .. room.desc, "DndDesc")
  blank()

  local exits = {}
  for dir in pairs(room.exits or {}) do table.insert(exits, dir) end
  table.sort(exits)
  if #exits > 0 then
    out("  Exits:  " .. table.concat(exits, "  │  "), "DndSystem")
  end
  if room.shop then
    out("  [shop]  Mira's wares are available — type 'shop'", "DndGold")
  end
  if room.chest and not room.chest_looted then
    out("  [chest] A chest sits here — type 'open'", "DndGold")
  end
  if room.boss and not room.boss_defeated then
    out("  ⚠  THE BOSS LURKS HERE — type 'fight' to engage!", "DndDanger")
  end
  blank()
end

-- ── Player status bar ───────────────────────────────────────────────────────
local function status_bar()
  local p = state.player
  local filled = math.max(0, math.floor(p.hp / p.max_hp * 10))
  local bar = string.rep("█", filled) .. string.rep("░", 10 - filled)
  out(string.format(
    "  [%s %s]  HP %d/%d [%s]  Gold %dg  XP %d/%d  Lv %d",
    CLASSES[p.class].label, p.name,
    p.hp, p.max_hp, bar,
    p.gold, p.xp, p.xp_next, p.level
  ), "DndSystem")
end

-- ── Player factory ──────────────────────────────────────────────────────────
local function make_player(name, class_id)
  local c = CLASSES[class_id]
  return {
    name    = name,
    class   = class_id,
    level   = 1,
    xp      = 0,
    xp_next = 100,
    hp      = c.hp + 10,
    max_hp  = c.hp + 10,
    str     = c.str + 3,
    dex     = c.dex + 3,
    int_    = c.int_ + 3,
    gold    = 50,
    atk_die = c.atk_die,
    defense = 0,
    crit_b  = c.crit_bonus or 0,
    inventory = {},
    equipped  = { weapon=nil, armor=nil, offhand=nil, feet=nil },
  }
end

local function gain_xp(amount)
  local p = state.player
  p.xp = p.xp + amount
  out(string.format("  +%d XP", amount), "DndXP")
  if p.xp >= p.xp_next then
    p.level   = p.level + 1
    p.xp_next = math.floor(p.xp_next * 2)
    local gain = roll(8) + 2
    p.max_hp  = p.max_hp + gain
    p.hp      = math.min(p.hp + gain, p.max_hp)
    p.str     = p.str + 1
    p.dex     = p.dex + 1
    blank()
    out("  ✨  LEVEL UP!  You are now level " .. p.level .. "!", "DndXP")
    out(string.format("  Max HP +%d  │  STR +1  │  DEX +1", gain), "DndXP")
  end
end

-- ── Combat helpers ──────────────────────────────────────────────────────────
local function player_hit(enemy)
  local p   = state.player
  local dmg = roll_dice(p.atk_die) + math.floor(p.str / 2)
  local crit = math.random() < (0.05 + p.crit_b)
  if crit then
    dmg = dmg * 2
    out("  💥  CRITICAL HIT!", "DndDmg")
  end
  local net = math.max(1, dmg - enemy.def)
  enemy.hp  = enemy.hp - net
  out(string.format("  You strike %s for %d damage!  (%d HP left)", enemy.name, net, math.max(0,enemy.hp)), "DndDmg")
end

local function enemy_hit()
  local p = state.player
  local e = state.current_enemy
  local dodge = p.dex * 0.03
  if math.random() < dodge then
    out(string.format("  %s swings — you dodge!", e.name), "DndSystem")
    return
  end
  local dmg = roll_dice(e.atk)
  local net = math.max(1, dmg - p.defense)
  p.hp = p.hp - net
  out(string.format("  %s hits you for %d damage!  (%d HP left)", e.name, net, p.hp), "DndDanger")
end

local function start_combat(eid)
  local tmpl = BESTIARY[eid]
  state.current_enemy = {
    id   = eid,
    name = tmpl.name,
    hp   = tmpl.hp, max_hp = tmpl.max_hp,
    atk  = tmpl.atk, def = tmpl.def,
    xp   = tmpl.xp, gold = tmpl.gold,
    loot = tmpl.loot,
    boss = tmpl.boss,
  }
  state.in_combat = true
  sep()
  out(string.format("  ⚔  A wild %s appears!", state.current_enemy.name), "DndDanger")
  out(string.format("  HP: %d  │  Attacks: %s", state.current_enemy.hp, state.current_enemy.atk), "DndDesc")
  sep()
  out("  Combat: [attack]  [spell]  [flee]  [item <name>]", "DndSystem")
end

local function victory()
  local e = state.current_enemy
  local p = state.player
  sep()
  out(string.format("  🏆  You defeated %s!", e.name), "DndSystem")
  local g = math.random(e.gold[1], math.max(e.gold[1], e.gold[2]))
  if g > 0 then
    p.gold = p.gold + g
    out(string.format("  You loot %dg.", g), "DndGold")
  end
  gain_xp(e.xp)
  if e.loot and math.random() < e.loot.chance then
    local it = vim.deepcopy(e.loot.item)
    table.insert(p.inventory, it)
    out(string.format("  You find: %s!", it.name), "DndGold")
  end
  if e.boss then
    blank()
    out("  ╔════════════════════════════════════════════════╗", "DndTitle")
    out("  ║      YOU HAVE CONQUERED THE DUNGEON!           ║", "DndTitle")
    out("  ║      The realm of Thornwall is saved…          ║", "DndTitle")
    out("  ║      …for now.   (type 'restart' to play again)║", "DndTitle")
    out("  ╚════════════════════════════════════════════════╝", "DndTitle")
    ROOMS.dungeon_b2.boss_defeated = true
  end
  state.in_combat     = false
  state.current_enemy = nil
  status_bar()
end

local function player_died()
  sep()
  out("  💀  YOU HAVE DIED.  Your adventure ends here.", "DndDanger")
  out("  Type 'restart' to begin a new life.", "DndSystem")
  state.in_combat     = false
  state.current_enemy = nil
  state.phase         = "dead"
end

-- ── Commands ────────────────────────────────────────────────────────────────
local function do_look()
  show_room(state.current_room)
  status_bar()
end

local function do_go(dir)
  if not dir or dir == "" then
    out("  Go where?  (n / s / e / w / up / down)", "DndSystem") return
  end
  local abbr = { n="north", s="south", e="east", w="west", u="up", d="down" }
  dir = abbr[dir] or dir
  local nid = state.current_room.exits and state.current_room.exits[dir]
  if not nid then
    out("  You can't go that way.", "DndSystem") return
  end
  state.current_room = ROOMS[nid]
  local r = state.current_room
  show_room(r)
  status_bar()
  if r.enemy_table and math.random() < (r.encounter_rate or 0.5) then
    local eid = r.enemy_table[math.random(#r.enemy_table)]
    vim.defer_fn(function() start_combat(eid) end, 30)
  end
end

local function do_attack()
  if not state.in_combat then
    out("  No enemy nearby.", "DndSystem") return
  end
  local e = state.current_enemy
  player_hit(e)
  if e.hp <= 0 then victory() return end
  enemy_hit()
  if state.player.hp <= 0 then player_died() end
end

local function do_spell()
  if not state.in_combat then
    out("  Cast at what?", "DndSystem") return
  end
  local p = state.player
  if p.class ~= "mage" then
    out("  Only Mages know arcane spells!", "DndSystem") return
  end
  local dmg = roll(8) + roll(8) + p.int_
  local e   = state.current_enemy
  e.hp      = e.hp - dmg
  out(string.format("  🔥  Fireball! You blast %s for %d fire damage!", e.name, dmg), "DndDmg")
  if e.hp <= 0 then victory() return end
  enemy_hit()
  if state.player.hp <= 0 then player_died() end
end

local function do_flee()
  if not state.in_combat then
    out("  Nothing to flee from.", "DndSystem") return
  end
  local p     = state.player
  local chance = 0.35 + p.dex * 0.04
  if math.random() < chance then
    out("  You manage to escape!", "DndSystem")
    state.in_combat     = false
    state.current_enemy = nil
    local exits = state.current_room.exits or {}
    if exits.south then
      state.current_room = ROOMS[exits.south]
      show_room(state.current_room)
    end
  else
    out("  You fail to escape!", "DndSystem")
    enemy_hit()
    if state.player.hp <= 0 then player_died() end
  end
end

local function do_item(name)
  if not name or name == "" then
    out("  Usage:  item <name>", "DndSystem") return
  end
  local p = state.player
  local found, idx
  for i, it in ipairs(p.inventory) do
    if it.name:lower():find(name:lower(), 1, true) then
      found, idx = it, i break
    end
  end
  if not found then
    out("  You don't have that item.", "DndSystem") return
  end
  if found.type == "potion" then
    local h = found.heal or 0
    p.hp = math.min(p.max_hp, p.hp + h)
    local extra = ""
    if found.dex_bonus then
      p.dex  = p.dex + found.dex_bonus
      extra  = string.format("  +%d DEX", found.dex_bonus)
    end
    out(string.format("  You drink %s. +%d HP.%s", found.name, h, extra), "DndHeal")
    table.remove(p.inventory, idx)
  elseif found.slot then
    p.equipped[found.slot] = found
    if found.type == "weapon" then p.atk_die = found.damage end
    -- recalculate defense
    p.defense = 0
    for _, eq in pairs(p.equipped) do
      if eq and eq.defense then p.defense = p.defense + eq.defense end
    end
    out(string.format("  You equip %s.", found.name), "DndSystem")
  else
    out("  You examine the " .. found.name .. " closely. Curious.", "DndDesc")
  end
  status_bar()
end

local function do_inv()
  local p = state.player
  if #p.inventory == 0 then
    out("  Your pack is empty.", "DndSystem") return
  end
  out("  ─── Inventory ───────────────────────────────────────", "DndSep")
  for _, it in ipairs(p.inventory) do
    local d = ""
    if it.damage   then d = d .. "  dmg "  .. it.damage end
    if it.defense  then d = d .. "  def +" .. it.defense end
    if it.heal and it.heal > 0 then d = d .. "  +hp " .. it.heal end
    if it.dex_bonus then d = d .. "  +dex " .. it.dex_bonus end
    out("    • " .. it.name .. d, "DndDesc")
  end
  out(string.format("  Gold: %dg   Defense: %d   Atk die: %s", p.gold, p.defense, p.atk_die), "DndGold")
end

local function do_stats()
  local p = state.player
  sep()
  out(string.format("  %s the %s  (Level %d)", p.name, CLASSES[p.class].label, p.level), "DndRoom")
  out(string.format("  HP:  %d / %d      STR %d  DEX %d  INT %d",
    p.hp, p.max_hp, p.str, p.dex, p.int_), "DndDesc")
  out(string.format("  XP:  %d / %d     Gold %dg   Defense %d",
    p.xp, p.xp_next, p.gold, p.defense), "DndGold")
  local wpn = p.equipped.weapon   and p.equipped.weapon.name   or "Bare fists"
  local arm = p.equipped.armor    and p.equipped.armor.name    or "None"
  out(string.format("  Weapon: %-20s  Armor: %s", wpn, arm), "DndDesc")
  sep()
end

local function do_shop()
  local r = state.current_room
  if not r.shop then
    out("  There's no shop here.", "DndSystem") return
  end
  sep()
  out(string.format("  🛒  Mira's Emporium  —  Your gold: %dg", state.player.gold), "DndGold")
  sep()
  for i, it in ipairs(r.wares) do
    local d = ""
    if it.damage    then d = d .. "  dmg "  .. it.damage end
    if it.defense   then d = d .. "  def +" .. it.defense end
    if it.heal      then d = d .. "  +hp "  .. it.heal end
    if it.dex_bonus then d = d .. "  +dex " .. it.dex_bonus end
    out(string.format("  [%d]  %-22s  %3dg%s", i, it.name, it.price, d), "DndDesc")
  end
  sep()
  out("  Type 'buy <number>' to purchase.", "DndSystem")
end

local function do_buy(arg)
  local r = state.current_room
  if not r.shop then out("  No shop here.", "DndSystem") return end
  local idx  = tonumber(arg)
  local item = idx and r.wares[idx]
  if not item then out("  Buy which item number?", "DndSystem") return end
  local p = state.player
  if p.gold < item.price then
    out(string.format("  You need %dg (you have %dg).", item.price, p.gold), "DndDanger") return
  end
  p.gold = p.gold - item.price
  table.insert(p.inventory, vim.deepcopy(item))
  out(string.format("  Bought %s for %dg.  Remaining: %dg.", item.name, item.price, p.gold), "DndGold")
end

local function do_open()
  local r = state.current_room
  if not r.chest then out("  Nothing to open here.", "DndSystem") return end
  if r.chest_looted then out("  The chest is already empty.", "DndSystem") return end
  r.chest_looted = true
  sep()
  out("  You lift the lid of the chest…", "DndDesc")
  local p = state.player
  if r.chest.gold and r.chest.gold > 0 then
    p.gold = p.gold + r.chest.gold
    out(string.format("  You find %dg!", r.chest.gold), "DndGold")
  end
  for _, it in ipairs(r.chest.items or {}) do
    table.insert(p.inventory, vim.deepcopy(it))
    out("  You find: " .. it.name .. "!", "DndGold")
  end
  sep()
  status_bar()
end

local function do_fight()
  local r = state.current_room
  if not r.boss or r.boss_defeated then
    out("  Nothing to fight here.", "DndSystem") return
  end
  if state.in_combat then return end
  start_combat(r.boss)
end

local function do_help()
  sep()
  out("  ⚔  COMMAND REFERENCE", "DndRoom")
  sep()
  out("  look / l             Describe current room", "DndDesc")
  out("  go <dir>             Move  (n s e w up down)", "DndDesc")
  out("  attack / a           Attack enemy in combat", "DndDesc")
  out("  spell                Cast Fireball  (Mage only)", "DndDesc")
  out("  flee                 Try to escape combat", "DndDesc")
  out("  item <name>          Use or equip an inventory item", "DndDesc")
  out("  inv / i              List inventory & gold", "DndDesc")
  out("  stats                Show character sheet", "DndDesc")
  out("  shop                 Browse wares  (when in shop)", "DndDesc")
  out("  buy <number>         Buy item from shop", "DndDesc")
  out("  open / chest         Open a nearby chest", "DndDesc")
  out("  fight                Engage the boss", "DndDesc")
  out("  roll [sides]         Roll a die  (default d20)", "DndDesc")
  out("  help / ?             Show this help", "DndDesc")
  out("  restart              Start a new game", "DndDesc")
  out("  quit / q             Close the game", "DndDesc")
  sep()
end

-- ── Input dispatch ──────────────────────────────────────────────────────────
local function dispatch(raw)
  raw = raw:match("^%s*(.-)%s*$")
  if raw == "" then return end
  out("  > " .. raw, "DndInput")

  -- Setup phases --
  if state.phase == "name" then
    if #raw < 2 then out("  Name must be at least 2 characters.", "DndSystem") return end
    state.player.name = raw
    blank()
    out("  Choose your class:", "DndSystem")
    for id, cls in pairs(CLASSES) do
      out(string.format("  [%-8s]  %s", id, cls.desc), "DndDesc")
    end
    state.phase = "class"
    return
  end

  if state.phase == "class" then
    local cid = raw:lower()
    if not CLASSES[cid] then
      out("  Type  warrior,  mage,  or  rogue.", "DndSystem") return
    end
    state.player = make_player(state.player.name, cid)
    sep()
    out(string.format("  Welcome, %s the %s!", state.player.name, CLASSES[cid].label), "DndTitle")
    out("  Your adventure begins in Thornwall Village.", "DndDesc")
    sep()
    state.phase        = "play"
    state.current_room = ROOMS.town
    show_room(ROOMS.town)
    status_bar()
    out("  Type 'help' for commands.", "DndSystem")
    return
  end

  if state.phase == "dead" then
    if raw:lower() == "restart" then M.restart()
    else out("  You are dead. Type 'restart'.", "DndDanger") end
    return
  end

  -- Normal / combat commands --
  local parts = vim.split(raw, "%s+", { trimempty = true })
  local cmd   = (parts[1] or ""):lower()
  local arg   = table.concat(vim.list_slice(parts, 2), " ")

  if     cmd=="look"  or cmd=="l"                    then do_look()
  elseif cmd=="go"    or cmd=="move"                 then do_go(arg)
  elseif cmd=="n"     or cmd=="north"                then do_go("north")
  elseif cmd=="s"     or cmd=="south"                then do_go("south")
  elseif cmd=="e"     or cmd=="east"                 then do_go("east")
  elseif cmd=="w"     or cmd=="west"                 then do_go("west")
  elseif cmd=="up"    or cmd=="u"                    then do_go("up")
  elseif cmd=="down"  or cmd=="d"                    then do_go("down")
  elseif cmd=="attack"or cmd=="a"    or cmd=="hit"   then do_attack()
  elseif cmd=="spell" or cmd=="cast" or cmd=="magic" then do_spell()
  elseif cmd=="flee"  or cmd=="run"  or cmd=="esc"   then do_flee()
  elseif cmd=="item"  or cmd=="use"  or cmd=="equip" then do_item(arg)
  elseif cmd=="inv"   or cmd=="i"    or cmd=="inventory" then do_inv()
  elseif cmd=="stats" or cmd=="status" or cmd=="char" then do_stats()
  elseif cmd=="shop"                                 then do_shop()
  elseif cmd=="buy"                                  then do_buy(arg)
  elseif cmd=="open"  or cmd=="chest"                then do_open()
  elseif cmd=="fight"                                then do_fight()
  elseif cmd=="help"  or cmd=="?"    or cmd=="h"     then do_help()
  elseif cmd=="roll"                                 then
    local sides = tonumber(arg) or 20
    out(string.format("  🎲  d%d → %d", sides, roll(sides)), "DndSystem")
  elseif cmd=="restart"                              then M.restart()
  elseif cmd=="quit"  or cmd=="q"    or cmd=="exit"  then M.close()
  else
    out("  Unknown command: '" .. cmd .. "'.  Type 'help'.", "DndSystem")
  end
end

-- ── Title screen ────────────────────────────────────────────────────────────
local function title()
  out("")
  out("  ╔══════════════════════════════════════════════════════╗", "DndTitle")
  out("  ║                                                      ║", "DndTitle")
  out("  ║          D U N G E O N   O F   T H O R N W A L L    ║", "DndTitle")
  out("  ║              A Text Adventure for Neovim             ║", "DndTitle")
  out("  ║                                                      ║", "DndTitle")
  out("  ╚══════════════════════════════════════════════════════╝", "DndTitle")
  out("")
  out("  Survive the dungeon. Defeat the Lich. Claim glory.", "DndDesc")
  out("")
  out("  What is your adventurer's name?", "DndSystem")
end

-- ── Window management ────────────────────────────────────────────────────────
local function open_wins()
  local W      = math.floor(vim.o.columns * 0.82)
  local H      = math.floor(vim.o.lines   * 0.85)
  local inp_h  = 2
  local out_h  = H - inp_h - 1
  local col    = math.floor((vim.o.columns - W) / 2)
  local row    = math.floor((vim.o.lines   - H) / 2)

  -- output buffer (read-only)
  state.game_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.game_buf].modifiable = false
  vim.bo[state.game_buf].bufhidden  = "wipe"

  state.game_win = vim.api.nvim_open_win(state.game_buf, false, {
    relative  = "editor",
    width     = W,        height = out_h,
    row       = row,      col    = col,
    style     = "minimal",border = "rounded",
    title     = " ⚔  Dungeon of Thornwall ",
    title_pos = "center",
  })
  vim.wo[state.game_win].wrap           = true
  vim.wo[state.game_win].number         = false
  vim.wo[state.game_win].relativenumber = false
  vim.wo[state.game_win].cursorline     = false

  -- input buffer
  state.input_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.input_buf].bufhidden = "wipe"
  vim.bo[state.input_buf].buftype   = "nofile"

  state.input_win = vim.api.nvim_open_win(state.input_buf, true, {
    relative  = "editor",
    width     = W,            height = inp_h,
    row       = row + out_h + 1, col = col,
    style     = "minimal",   border = "rounded",
    title     = " › command ",
    title_pos = "left",
  })
  vim.wo[state.input_win].number         = false
  vim.wo[state.input_win].relativenumber = false

  local bo = { buffer = state.input_buf, noremap = true, silent = true }

  -- <CR> submits the current line
  vim.keymap.set("i", "<CR>", function()
    local lines = vim.api.nvim_buf_get_lines(state.input_buf, 0, -1, false)
    local input = table.concat(lines, " ")
    vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, { "" })
    dispatch(input)
  end, bo)

  -- <Esc> closes the game
  vim.keymap.set({ "i", "n" }, "<Esc>", M.close, bo)

  -- Handle window close events
  vim.api.nvim_create_autocmd("WinClosed", {
    buffer  = state.game_buf,
    once    = true,
    callback = function() M.close() end,
  })

  vim.cmd("startinsert")
end

-- ── Public API ───────────────────────────────────────────────────────────────
function M.close()
  state.active = false
  for _, win in ipairs({ state.input_win, state.game_win }) do
    if win and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  state.game_win  = nil ; state.input_win = nil
  state.game_buf  = nil ; state.input_buf = nil
end

function M.restart()
  -- reset world flags
  for _, room in pairs(ROOMS) do
    room.chest_looted = false
    room.boss_defeated = false
  end
  state.in_combat     = false
  state.current_enemy = nil
  state.player        = { name = "" }
  state.phase         = "name"

  -- clear output buffer
  local buf = state.game_buf
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
    vim.bo[buf].modifiable = false
  end

  title()

  -- refocus input
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    vim.api.nvim_set_current_win(state.input_win)
    vim.cmd("startinsert")
  end
end

function M.open()
  if state.active then M.close() return end
  math.randomseed(os.time())
  setup_hl()
  open_wins()
  state.active  = true
  state.player  = { name = "" }
  state.phase   = "name"

  -- reset world
  for _, room in pairs(ROOMS) do
    room.chest_looted  = false
    room.boss_defeated = false
  end

  title()
end

-- ── Keymap ────────────────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>dg", M.open, { desc = "Open DnD game" })

return M
