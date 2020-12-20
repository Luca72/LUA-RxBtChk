local defaultOptions = {
  { "CellCount", VALUE, 2 }, -- number of cells
  { "Color", COLOR, WHITE },
}

-- Data gathered from commercial lipo sensors
local _lipoPercentListSplit = {
  { { 3, 0 }, { 3.093, 1 }, { 3.196, 2 }, { 3.301, 3 }, { 3.401, 4 }, { 3.477, 5 }, { 3.544, 6 }, { 3.601, 7 }, { 3.637, 8 }, { 3.664, 9 }, { 3.679, 10 }, { 3.683, 11 }, { 3.689, 12 }, { 3.692, 13 } },
  { { 3.705, 14 }, { 3.71, 15 }, { 3.713, 16 }, { 3.715, 17 }, { 3.72, 18 }, { 3.731, 19 }, { 3.735, 20 }, { 3.744, 21 }, { 3.753, 22 }, { 3.756, 23 }, { 3.758, 24 }, { 3.762, 25 }, { 3.767, 26 } },
  { { 3.774, 27 }, { 3.78, 28 }, { 3.783, 29 }, { 3.786, 30 }, { 3.789, 31 }, { 3.794, 32 }, { 3.797, 33 }, { 3.8, 34 }, { 3.802, 35 }, { 3.805, 36 }, { 3.808, 37 }, { 3.811, 38 }, { 3.815, 39 } },
  { { 3.818, 40 }, { 3.822, 41 }, { 3.825, 42 }, { 3.829, 43 }, { 3.833, 44 }, { 3.836, 45 }, { 3.84, 46 }, { 3.843, 47 }, { 3.847, 48 }, { 3.85, 49 }, { 3.854, 50 }, { 3.857, 51 }, { 3.86, 52 } },
  { { 3.863, 53 }, { 3.866, 54 }, { 3.87, 55 }, { 3.874, 56 }, { 3.879, 57 }, { 3.888, 58 }, { 3.893, 59 }, { 3.897, 60 }, { 3.902, 61 }, { 3.906, 62 }, { 3.911, 63 }, { 3.918, 64 } },
  { { 3.923, 65 }, { 3.928, 66 }, { 3.939, 67 }, { 3.943, 68 }, { 3.949, 69 }, { 3.955, 70 }, { 3.961, 71 }, { 3.968, 72 }, { 3.974, 73 }, { 3.981, 74 }, { 3.987, 75 }, { 3.994, 76 } },
  { { 4.001, 77 }, { 4.007, 78 }, { 4.014, 79 }, { 4.021, 80 }, { 4.029, 81 }, { 4.036, 82 }, { 4.044, 83 }, { 4.052, 84 }, { 4.062, 85 }, { 4.074, 86 }, { 4.085, 87 }, { 4.095, 88 } },
  { { 4.105, 89 }, { 4.111, 90 }, { 4.116, 91 }, { 4.12, 92 }, { 4.125, 93 }, { 4.129, 94 }, { 4.135, 95 }, { 4.145, 96 }, { 4.176, 97 }, { 4.179, 98 }, { 4.193, 99 }, { 4.2, 100 } },
}

local function createWidget(zone, options)
  lcd.setColor( CUSTOM_COLOR, options.Color )
  --  the CUSTOM_COLOR is foreseen to have one color that is not radio template related, but it can be used by other widgets as well!
  
  local no_telem_blink = 0
  local isDataAvailable = 0
  local cellPercent = 0
  local cellSum = 0
  local telemetryBitmap = Bitmap.open("/WIDGETS/RxBtChk/img/telemetry.png")
  
  return { zone=zone, options=options, no_telem_blink=no_telem_blink, isDataAvailable=isDataAvailable, 
           cellPercent=cellPercent, cellSum=cellSum, telemetryBitmap=telemetryBitmap }
end

local function updateWidget(widgetToUpdate, newOptions)
  if (widgetToUpdate == nil) then
    return
  end
  widgetToUpdate.options = newOptions
  lcd.setColor( CUSTOM_COLOR, widgetToUpdate.options.Color )
  --  the CUSTOM_COLOR is foreseen to have one color that is not radio template related, but it can be used by other widgets as well!
end

local function backgroundProcessWidget(widgetToProcessInBackground)
  return
end

--- This function return the percentage remaining in a single Lipo cel
--- since running on long array found to be very intensive to hrous cpu, we are splitting the list to small lists
local function getCellPercent(cellValue)
  local result = 0;

  for i1, v1 in ipairs(_lipoPercentListSplit) do
    --is the cellVal < last-value-on-sub-list? (first-val:v1[1], last-val:v1[#v1])
    if (cellValue <= v1[#v1][1]) then
      -- cellVal is in this sub-list, find the exact value
      for i2, v2 in ipairs(v1) do
        if v2[1] >= cellValue then
          result = v2[2]
          return result
        end
      end
    end
  end
  -- in case somehow voltage is too high (>4.2), don't return nil
  return 100
end


--- This function returns a table with cels values
local function calculateBatteryData(widget)
  widget.cellSum = getValue("RxBt")
  
  if widget.cellSum == 0 then
    widget.isDataAvailable = false
    return
  end

  --- average of all cells
  widget.cellAvg = widget.cellSum / widget.options.CellCount
  -- mainValue
  widget.isDataAvailable = true
  widget.cellPercent = getCellPercent(widget.cellAvg) -- use batt percentage by average cell voltage
end


--- Zone size: 70x39 1/8th top bar
local function refreshZoneTiny(widget)
  lcd.setColor( CUSTOM_COLOR, widget.options.Color )
  --  the CUSTOM_COLOR is foreseen to have one color that is not radio template related, but it can be used by other widgets as well!
  local cellSumStr = string.format("%2.2fV", widget.cellSum)
  lcd.drawText(widget.zone.x + widget.zone.w, widget.zone.y + 2, cellSumStr, RIGHT + SMLSIZE + CUSTOM_COLOR + widget.no_telem_blink)
  lcd.drawText(widget.zone.x + widget.zone.w, widget.zone.y + 20, widget.cellPercent .. "%", RIGHT + SMLSIZE + CUSTOM_COLOR + widget.no_telem_blink)
  -- draw batt
  lcd.drawRectangle(widget.zone.x, widget.zone.y + 23, 30, 12, CUSTOM_COLOR, 1)
  lcd.drawFilledRectangle(widget.zone.x + 30, widget.zone.y + 26, 3, 6, CUSTOM_COLOR)
  local rect_h = math.floor(30 * widget.cellPercent / 100)
  lcd.drawFilledRectangle(widget.zone.x, widget.zone.y + 24 , rect_h, 10, CUSTOM_COLOR + widget.no_telem_blink)
  -- draw bitmap
  lcd.drawBitmap(widget.telemetryBitmap, widget.zone.x, widget.zone.y)
end

--- Zone size: 160x32 1/8th
local function refreshZoneSmall(widget)
    lcd.drawText (widget.zone.x, widget.zone.y, "only for top panel", SMLSIZE)
end

--- Zone size: 180x70 1/4th  (with sliders/trim) or Zone size: 225x98 1/4th  (no sliders/trim)
local function refreshZoneMedium(widget)
    lcd.drawText (widget.zone.x, widget.zone.y, "only for top panel", SMLSIZE)
end

--- Zone size: 192x152 1/2
local function refreshZoneLarge(widget)
    lcd.drawText (widget.zone.x, widget.zone.y, "only for top panel", SMLSIZE)
end

--- Zone size: 390x172 1/1 or Zone size: 460x252 1/1 (no sliders/trim/topbar)
local function refreshZoneXLarge(widget)
    lcd.drawText (widget.zone.x, widget.zone.y, "only for top panel", SMLSIZE)
end


local function refreshWidget(widgetToRefresh)
  if (widgetToRefresh == nil) then
    return
  end
    
  calculateBatteryData(widgetToRefresh)
    
  if widgetToRefresh.isDataAvailable then
    widgetToRefresh.no_telem_blink = 0
  else
    widgetToRefresh.no_telem_blink = INVERS + BLINK
  end

  if widgetToRefresh.zone.w > 380 and widgetToRefresh.zone.h > 165 then
    refreshZoneXLarge(widgetToRefresh)
  elseif widgetToRefresh.zone.w > 180 and widgetToRefresh.zone.h > 145 then
    refreshZoneLarge(widgetToRefresh)
  elseif widgetToRefresh.zone.w > 170 and widgetToRefresh.zone.h > 65 then
    refreshZoneMedium(widgetToRefresh)
  elseif widgetToRefresh.zone.w > 150 and widgetToRefresh.zone.h > 28 then
    refreshZoneSmall(widgetToRefresh)
  elseif widgetToRefresh.zone.w > 65 and widgetToRefresh.zone.h > 35 then
    refreshZoneTiny(widgetToRefresh)
  end
end

return { name="RxBtChk", options=defaultOptions, create=createWidget, update=updateWidget
  , refresh=refreshWidget, background=backgroundProcessWidget }
