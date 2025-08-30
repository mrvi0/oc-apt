#!/bin/lua

--[[
oc-htop — Advanced system monitor for OpenComputers
Author: B4DCAT
License: MIT
Requires: GPU+Screen, OpenOS
Optional: Internet Card for manual updates

A powerful system monitoring tool inspired by htop for OpenComputers.
Shows real-time system metrics including memory, energy, disk usage,
and process information with an interactive interface.
]]

local component = require("component")
local computer = require("computer")
local term = require("term")
local unicode = require("unicode")
local event = require("event")
local keyboard = require("keyboard")
local process = require("process")

local gpu = component.gpu

-------------------------
-- Configuration & Colors
-------------------------
local cfg = {
  refresh = 0.5,            -- refresh period (sec)
  minRefresh = 0.1,
  maxRefresh = 5.0,
  barsWidth = 30,           -- width of progress bars
  showHelp = false,         -- help panel visibility
  sort = "pid",             -- pid|name|state
  offset = 0,               -- process list scroll offset
  title = "oc-htop",        -- window title
}

local colors = {
  bg        = 0x000000,
  fg        = 0xFFFFFF,
  dim       = 0xAAAAAA,
  line      = 0x333333,
  barEmpty  = 0x222222,
  good      = 0x00AA00,
  warn      = 0xAAAA00,
  bad       = 0xAA0000,
  accent    = 0x3399FF,
}

------------------
-- Helper Functions
------------------
local function clamp(x, a, b) return math.max(a, math.min(b, x)) end

local function fmtBytes(n)
  if not n then return "?" end
  local units = {"B","KiB","MiB","GiB","TiB"}
  local i = 1
  while n >= 1024 and i < #units do 
    n = n/1024
    i = i + 1 
  end
  return string.format("%.1f %s", n, units[i])
end

local function fmtPct(p)
  if not p then return "?%" end
  return string.format("%.1f%%", p*100)
end

local function fmtTime(sec)
  sec = math.floor(sec or 0)
  local h = math.floor(sec/3600)
  local m = math.floor((sec%3600)/60)
  local s = sec%60
  return string.format("%02d:%02d:%02d", h, m, s)
end

local function wlen(s)
  return unicode.len(s or "") or #(s or "")
end

local function trunc(s, width)
  s = tostring(s or "")
  local len = wlen(s)
  if len <= width then return s end
  return unicode.sub(s, 1, math.max(0, width-1)) .. "…"
end

local function setColors(fg, bg)
  if fg then gpu.setForeground(fg) end
  if bg then gpu.setBackground(bg) end
end

local function drawBar(x, y, width, percent)
  percent = clamp(percent or 0, 0, 1)
  local filled = math.floor(width * percent + 0.5)
  local color = colors.good
  if percent >= 0.85 then 
    color = colors.bad
  elseif percent >= 0.6 then 
    color = colors.warn 
  end
  
  if filled > 0 then
    setColors(nil, color)
    gpu.fill(x, y, filled, 1, " ")
  end
  if width - filled > 0 then
    setColors(nil, colors.barEmpty)
    gpu.fill(x + filled, y, width - filled, 1, " ")
  end
  setColors(colors.fg, colors.bg)
end

----------------------
-- System Metrics
----------------------
local function getEnergy()
  local max = (computer.maxEnergy and computer.maxEnergy()) or 0
  local cur = (computer.energy and computer.energy()) or 0
  if max <= 0 then return nil end
  return cur, max, cur/max
end

local function getMemory()
  local total = computer.totalMemory()
  local free  = computer.freeMemory()
  local used  = total - free
  return used, total, used/total
end

-- CPU Activity: fraction of time spent on drawing/work between frames
local lastDrawTime = computer.uptime()
local lastFrameDur = 0.0

local function startFrameTimer()
  lastDrawTime = computer.uptime()
end

local function endFrameTimer()
  local now = computer.uptime()
  lastFrameDur = now - lastDrawTime
end

local function getActivity()
  -- activity = computation time / refresh period
  return clamp(lastFrameDur / cfg.refresh, 0, 1)
end

----------------------
-- OpenOS Processes
----------------------
local function collectProcesses()
  local list = {}
  local ok, iter = pcall(process.list)
  if not ok then return list end
  
  for pid in iter do
    local name, state = "?", "?"
    local ok2, info = pcall(process.info, pid)
    if ok2 and type(info) == "table" then
      name = info.command or info.commandline or info.name or info.path or tostring(info)
      state = info.state or (info.dead and "dead") or "running"
    else
      name = tostring(pid)
      state = "running"
    end
    table.insert(list, {pid = pid, name = name, state = state})
  end
  
  -- Sort processes
  table.sort(list, function(a, b)
    if cfg.sort == "name" then
      return tostring(a.name) < tostring(b.name)
    elseif cfg.sort == "state" then
      return tostring(a.state) < tostring(b.state)
    else
      return tonumber(a.pid) < tonumber(b.pid)
    end
  end)
  
  return list
end

------------------
-- UI Drawing
------------------
local function drawHeader(w)
  local uptime = fmtTime(computer.uptime())
  local act = fmtPct(getActivity())
  setColors(colors.bg, colors.accent)
  gpu.fill(1, 1, w, 1, " ")
  setColors(colors.fg, colors.accent)
  local left = string.format(" %s | Uptime %s | Activity %s | %.1f Hz | Sort:%s ",
    cfg.title, uptime, act, 1.0/cfg.refresh, cfg.sort)
  gpu.set(1, 1, trunc(left, w))
  setColors(colors.fg, colors.bg)
end

local function drawBars(w)
  local x = 2
  local y = 3
  
  -- Memory
  local used, total, p = getMemory()
  gpu.set(x, y-1, string.format("Memory  %s / %s", fmtBytes(used), fmtBytes(total)))
  drawBar(x, y, math.min(cfg.barsWidth, math.max(10, w - 4)), p)
  y = y + 2
  
  -- Energy (if available)
  local ecur, emax, ep = getEnergy() or {}
  if emax and emax > 0 then
    gpu.set(x, y-1, string.format("Energy  %s / %s", fmtBytes(ecur), fmtBytes(emax)))
    drawBar(x, y, math.min(cfg.barsWidth, math.max(10, w - 4)), ep)
    y = y + 2
  end
  
  -- Disk space (first available filesystem)
  local fsAddr
  for addr in component.list("filesystem") do 
    fsAddr = addr
    break 
  end
  
  if fsAddr then
    local fs = component.proxy(fsAddr)
    if fs and fs.spaceTotal then
      local st = fs.spaceTotal()
      local su = fs.spaceUsed()
      if st and su then
        local dp = su / st
        gpu.set(x, y-1, string.format("Disk    %s / %s", fmtBytes(su), fmtBytes(st)))
        drawBar(x, y, math.min(cfg.barsWidth, math.max(10, w - 4)), dp)
        y = y + 2
      end
    end
  end
  
  return y
end

local function drawProcessTable(w, h, startY)
  local procs = collectProcesses()
  local header = " PID    STATE    NAME"
  setColors(colors.dim, colors.bg)
  gpu.set(1, startY, trunc(header, w))
  setColors(colors.fg, colors.bg)

  local rows = h - startY - 1
  rows = math.max(0, rows)
  local maxNameW = math.max(8, w - 20)

  local i = 0
  for index = 1 + cfg.offset, math.min(#procs, cfg.offset + rows) do
    local p = procs[index]
    i = i + 1
    local lineY = startY + i
    local pid = string.format("%5d", p.pid or 0)
    local state = trunc(p.state or "?", 7)
    local name = trunc(p.name or "?", maxNameW)
    local line = string.format(" %s  %-7s  %s", pid, state, name)
    gpu.set(1, lineY, trunc(line, w))
  end

  -- Scrollbar
  if #procs > rows and rows > 0 then
    local barH = math.max(1, math.floor(rows * rows / #procs))
    local barY = startY + math.floor((rows - barH) * (cfg.offset / math.max(1, #procs - rows)))
    setColors(nil, colors.line)
    gpu.fill(w, startY+1, 1, rows, " ")
    setColors(nil, colors.accent)
    gpu.fill(w, barY+1, 1, barH, " ")
    setColors(colors.fg, colors.bg)
  end

  return procs, rows
end

local function drawFooter(w, h)
  setColors(colors.dim, colors.bg)
  local help = " q:quit  h:help  ↑/↓/PgUp/PgDn:scroll  s:sort  +/-:Hz  g/G:top/bottom  r:reset"
  gpu.set(1, h, trunc(help, w))
  setColors(colors.fg, colors.bg)
end

local function drawHelp(w, h)
  if not cfg.showHelp then return end
  
  local lines = {
    "Controls:",
    "  q — quit",
    "  h — show/hide help",
    "  s — change sorting (pid → name → state)",
    "  + / - — increase/decrease refresh rate",
    "  ↑/↓, PgUp/PgDn, j/k — scroll process list",
    "  g — go to top,  G — go to bottom,  r — reset scroll",
    "",
    "Explanations:",
    "  Activity — approximate load based on frame draw time.",
    "  Energy — internal OC computer buffer (if available).",
    "  Disk — first available filesystem drive.",
  }
  
  local wBox = math.min(w-4, 60)
  local hBox = math.min(h-6, #lines + 2)
  local x = 3
  local y = 4
  
  setColors(colors.fg, colors.line)
  gpu.fill(x, y, wBox, hBox, " ")
  setColors(colors.fg, colors.bg)
  
  for i=1, math.min(#lines, hBox-2) do
    gpu.set(x+1, y+i-1, trunc(lines[i], wBox-2))
  end
end

local function redraw()
  local w, h = gpu.getResolution()
  setColors(colors.fg, colors.bg)
  gpu.fill(1, 1, w, h, " ")
  drawHeader(w)
  local y = drawBars(w)
  setColors(colors.dim, colors.bg)
  gpu.fill(1, y, w, 1, "─") -- separator line
  setColors(colors.fg, colors.bg)
  local _, rows = drawProcessTable(w, h, y+1)
  drawFooter(w, h)
  drawHelp(w, h)
end

--------------------
-- Input Handling
--------------------
local function handleKey(char, code)
  -- Character input
  if char and char > 0 then
    local ch = unicode.lower(string.char(char))
    if ch == 'q' then 
      return false
    elseif ch == 'h' then 
      cfg.showHelp = not cfg.showHelp
    elseif ch == 's' then
      cfg.sort = (cfg.sort == 'pid' and 'name') or (cfg.sort == 'name' and 'state') or 'pid'
    elseif ch == 'g' then 
      cfg.offset = 0
    elseif ch == 'r' then 
      cfg.offset = 0
    end
    
    if ch == '+' or ch == '=' then
      cfg.refresh = clamp(cfg.refresh - 0.1, cfg.minRefresh, cfg.maxRefresh)
    elseif ch == '-' then
      cfg.refresh = clamp(cfg.refresh + 0.1, cfg.minRefresh, cfg.maxRefresh)
    elseif ch == 'k' then
      cfg.offset = math.max(0, cfg.offset - 1)
    elseif ch == 'j' then
      cfg.offset = cfg.offset + 1
    elseif ch == 'G' then
      cfg.offset = 10^9 -- will be corrected during drawing
    end
  end
  
  -- Special keys
  if code then
    if code == keyboard.keys.up then 
      cfg.offset = math.max(0, cfg.offset - 1) 
    end
    if code == keyboard.keys.down then 
      cfg.offset = cfg.offset + 1 
    end
    if code == keyboard.keys.pageUp then 
      cfg.offset = math.max(0, cfg.offset - 10) 
    end
    if code == keyboard.keys.pageDown then 
      cfg.offset = cfg.offset + 10 
    end
  end
  
  return true
end

-----------------
-- Main Loop
-----------------
local function main()
  term.clear()
  local running = true
  
  while running do
    startFrameTimer()
    
    -- Handle events until frame deadline
    local deadline = computer.uptime() + cfg.refresh
    repeat
      local timeout = math.max(0, deadline - computer.uptime())
      local ev = { event.pull(timeout) }
      if #ev > 0 then
        local name = ev[1]
        if name == "key_down" then
          local _, _, ch, code = table.unpack(ev)
          running = handleKey(ch, code)
        elseif name == "interrupted" then
          running = false
        elseif name == "screen_resized" then
          -- Just redraw on resize
        end
      end
    until computer.uptime() >= deadline or not running

    redraw()
    endFrameTimer()
  end
  
  setColors(colors.fg, colors.bg)
  term.clear()
end

-- Run the program with error handling
local ok, err = pcall(main)
if not ok then
  setColors(colors.fg, colors.bg)
  io.stderr:write("oc-htop error: " .. tostring(err) .. "\n")
end 