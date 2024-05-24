--- === HammerspoonShiftIt ===
---
--- Manages windows and positions in MacOS with key binding from ShiftIt.
---
--- Download: [https://github.com/peterkljin/hammerspoon-shiftit/raw/master/Spoons/HammerspoonShiftIt.spoon.zip](https://github.com/peterklijn/hammerspoon-shiftit/raw/master/Spoons/HammerspoonShiftIt.spoon.zip)

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HammerspoonShiftIt"
obj.version = "1.0"
obj.author = "Peter Klijn"
obj.homepage = "https://github.com/peterklijn/hammerspoon-shiftit"
obj.license = "MIT"

obj.mash = { 'ctrl', 'alt', 'cmd' }
obj.mapping = {
  maximum = { { 'alt', 'cmd' }, 'm' },
  switchMaximumMode = { obj.mash, 'm' },
  toggleFullScreen = { obj.mash, 'f' },
  nextScreen = { { 'alt' }, 'tab' },
}

obj.maximumMode = 0

local units = {
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  right95       = { x = 0.05, y = 0.00, w = 0.95, h = 1.00 },
}

function getWindowSizeInRatio(window)
  local screenFrame = window:screen():frame()
  local windowFrame = window:frame()
  return {
      w = windowFrame.w / screenFrame.w,
      h = windowFrame.h / screenFrame.h
  }
end

function move(unit) 
  hs.window.focusedWindow():move(unit, nil, true, 0) 
end

function obj:maximum() 
  if self.maximumMode == 0 then
    move(units.maximum, nil, true, 0)
  else
    move(units.right95, nil, true, 0)
  end
end

function obj:switchMaximumMode() 
  self.maximumMode = (self.maximumMode + 1) % 2
  if self.maximumMode == 0 then
    hs.notify.show("Hammerspoon ShiftIt", "", "Maximum Mode: Full Screen")
  else
    hs.notify.show("Hammerspoon ShiftIt", "", "Maximum Mode: Stage Manager")
  end
end

function obj:toggleFullScreen() hs.window.focusedWindow():toggleFullScreen() end
function obj:nextScreen() 
  local window = hs.window.focusedWindow()
  local size = getWindowSizeInRatio(window)

  local isFullScreen
  if self.maximumMode == 0 then
    isFullScreen = (size.w >= 0.99 and size.h >= 0.99)
  else
    isFullScreen = (size.w >= 0.94 and size.h >= 0.99)
  end
  
  window:moveToScreen(window:screen():next(), true, true, 0) 
  -- If a screen is (almost) full, keep it full
  if isFullScreen then
    obj:maximum()
  end
end

--- HammerspoonShiftIt:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for HammerspoonShiftIt
function obj:bindHotkeys(mapping)

  if (mapping) then
    for k,v in pairs(mapping) do self.mapping[k] = v end
  end

  hs.hotkey.bind(self.mapping.maximum[1], self.mapping.maximum[2], function() self:maximum() end)
  hs.hotkey.bind(self.mapping.switchMaximumMode[1], self.mapping.switchMaximumMode[2], function() self:switchMaximumMode() end)
  hs.hotkey.bind(self.mapping.toggleFullScreen[1], self.mapping.toggleFullScreen[2], function() self:toggleFullScreen() end)
  hs.hotkey.bind(self.mapping.nextScreen[1], self.mapping.nextScreen[2], function() self:nextScreen() end)

  return self
end

return obj
