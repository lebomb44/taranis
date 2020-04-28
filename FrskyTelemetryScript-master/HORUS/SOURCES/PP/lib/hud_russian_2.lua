#include "includes/yaapu_inc.lua"
#include "includes/layout_2_inc.lua"

#define HUD_RUSSIAN_R2 20

#define VARIO_X 310
#define VARIO_Y HUD_Y
#define VARIO_H HUD_HEIGHT/2
#define VARIO_W 10

#define LEFTWIDTH   38
#define RIGHTWIDTH  38

#define HUD_WIDTH 158
#define HUD_HEIGHT 90
#define HUD_X (LCD_W-HUD_WIDTH)/2
#define HUD_Y 24
#define HUD_Y_MID 69

-----------------------
-- COMPASS RIBBON
-----------------------
#define YAW_X (LCD_W-140)/2
#define YAW_Y 120
#define YAW_WIDTH 140

#define YAWICON_Y 3
#define YAWTEXT_Y 16
#define YAW_STEPWIDTH 15
#define YAW_SYMBOLS 16
#define YAW_X_MIN (LCD_W-YAW_WIDTH)/2
#define YAW_X_MAX (LCD_W+YAW_WIDTH)/2

#define R2 25


-- model and opentx version
local ver, radio, maj, minor, rev = getVersion()
#ifdef HUDTIMER
local hudDrawTime = 0
local hudDrawCounter = 0
#endif

local function drawHud(myWidget,drawLib,conf,telemetry,status,battery,utils)
#ifdef HUDTIMER
  local hudStart = getTime()
#endif

  local r = -telemetry.roll
  local cx,cy,dx,dy
  local yPos = TOPBAR_Y + TOPBAR_HEIGHT + 8
  -----------------------
  -- artificial horizon
  -----------------------
  -- no roll ==> segments are vertical, offsets are multiples of R2
  if ( telemetry.roll == 0) then
    dx=0
    dy=telemetry.pitch
  else
    -- center line offsets
    dx = math.cos(math.rad(90 - r)) * -telemetry.pitch
    dy = math.sin(math.rad(90 - r)) * telemetry.pitch
  end
  local rollX = math.floor(HUD_X + HUD_WIDTH/2)
  -----------------------
  -- dark color for "ground"
  -----------------------
  -- 140x110
  local minY = HUD_Y
  local maxY = HUD_Y + HUD_HEIGHT
  
  local minX = HUD_X + 1
  local maxX = HUD_X + HUD_WIDTH
  
  local ox = HUD_X + HUD_WIDTH/2 + dx + 5
  local oy = HUD_Y_MID + dy
  local yy = 0
  
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(179, 204, 255))
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x7b, 0x9d, 0xff)) -- default blue
  lcd.drawFilledRectangle(minX,minY,HUD_WIDTH,maxY-minY,CUSTOM_COLOR)
  -- angle of the line passing on point(ox,oy)
  local angle = math.tan(math.rad(-telemetry.roll))
  -- for each pixel of the hud base/top draw vertical black 
  -- lines from hud border to horizon line
  -- horizon line moves with pitch/roll
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(77, 153, 0))
  --lcd.setColor(CUSTOM_COLOR,lcd.RGB(102, 51, 0))
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(0x63, 0x30, 0x00)) --623000 old brown
  if math.abs(telemetry.roll) < 90 then
    if oy > minY and oy < maxY then
      lcd.drawFilledRectangle(minX,oy,HUD_WIDTH,maxY-oy + 1,CUSTOM_COLOR)
    elseif oy <= minY then
      lcd.drawFilledRectangle(minX,minY,HUD_WIDTH,maxY-minY,CUSTOM_COLOR)
    end
  else
    --inverted
    if oy > minY and oy < maxY then
      lcd.drawFilledRectangle(minX,minY,HUD_WIDTH,oy-minY + 1,CUSTOM_COLOR)
    elseif oy >= maxY then
      lcd.drawFilledRectangle(minX,minY,HUD_WIDTH,maxY-minY,CUSTOM_COLOR)
    end
  end
  --
-- parallel lines above and below horizon
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(255, 255, 255))
  --
  local hx = math.cos(math.rad(90 - r)) * -(telemetry.pitch%45)
  local hy = math.sin(math.rad(90 - r)) * (telemetry.pitch%45)
  
  --drawLineWithClipping(rollX - hx, HUD_Y_MID + hy,r,50,SOLID,HUD_X,HUD_X + HUD_WIDTH,minY,maxY,CUSTOM_COLOR)
  
  for line=0,4
  do
    --
    local deltax = math.cos(math.rad(90 - r)) * HUD_RUSSIAN_R2 * line
    local deltay = math.sin(math.rad(90 - r)) * HUD_RUSSIAN_R2 * line
    --
    drawLib.drawLineWithClipping(rollX - deltax + hx, HUD_Y_MID + deltay + hy,r,50,DOTTED,HUD_X,HUD_X + HUD_WIDTH,minY,maxY,CUSTOM_COLOR,radio,rev)
    drawLib.drawLineWithClipping(rollX + deltax + hx, HUD_Y_MID - deltay + hy,r,50,DOTTED,HUD_X,HUD_X + HUD_WIDTH,minY,maxY,CUSTOM_COLOR,radio,rev)
  end

  local xx = math.cos(math.rad(r)) * 70 * 0.5
  local yy = math.sin(math.rad(r)) * 70 * 0.5
  --
  local x0 = rollX - xx
  local y0 = HUD_Y_MID - yy
  --
  local x1 = rollX + xx
  local y1 = HUD_Y_MID + yy   
  --
  drawLib.drawLineWithClipping(x0,y0,r + 90,70,SOLID,HUD_X,HUD_X + HUD_WIDTH,minY,maxY,CUSTOM_COLOR,radio,rev)
  drawLib.drawLineWithClipping(x1,y1,r + 90,70,SOLID,HUD_X,HUD_X + HUD_WIDTH,minY,maxY,CUSTOM_COLOR,radio,rev)
  -------------------------------------
  -- hud bitmap
  -------------------------------------
  lcd.drawBitmap(utils.getBitmap("hud_160x90_rus"),(LCD_W-HUD_WIDTH)/2,HUD_Y) --160x90
  -------------------------------------
  -- vario bitmap
  -------------------------------------
  local varioMax = 5
  local varioSpeed = math.min(math.abs(0.1*telemetry.vSpeed),5)
  local varioH = varioSpeed/varioMax*35
  if telemetry.vSpeed > 0 then
    varioY = VARIO_Y + 35 - varioH
  else
    varioY = VARIO_Y + 55
  end
  --00ae10
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(255, 0xce, 0)) --yellow
  -- lcd.setColor(CUSTOM_COLOR,lcd.RGB(00, 0xED, 0x32)) --green
  -- lcd.setColor(CUSTOM_COLOR,lcd.RGB(50, 50, 50)) --dark grey
  lcd.drawFilledRectangle(VARIO_X, varioY, VARIO_W, varioH, CUSTOM_COLOR, 0)  
  -------------------------------------
  -- left and right indicators on HUD
  -------------------------------------
  -- DATA
  -- altitude
  local alt = utils.getMaxValue(telemetry.homeAlt,MINMAX_ALT) * UNIT_ALT_SCALE
  if math.abs(alt) > 999 then
    lcd.setColor(CUSTOM_COLOR,COLOR_GREEN)
    lcd.drawNumber(HUD_X+HUD_WIDTH - 42,HUD_Y_MID-10,alt,CUSTOM_COLOR)
  elseif math.abs(alt) >= 10 then
    lcd.setColor(CUSTOM_COLOR,COLOR_GREEN)
    lcd.drawNumber(HUD_X+HUD_WIDTH - 42,HUD_Y_MID-14,alt,MIDSIZE+CUSTOM_COLOR)
  else
    lcd.setColor(CUSTOM_COLOR,COLOR_GREEN)
    lcd.drawNumber(HUD_X+HUD_WIDTH - 42,HUD_Y_MID-14,alt*10,MIDSIZE+PREC1+CUSTOM_COLOR)
  end
  lcd.setColor(CUSTOM_COLOR,COLOR_GREEN)
  -- telemetry.hSpeed is in dm/s
  local hSpeed = utils.getMaxValue(telemetry.hSpeed,MAX_HSPEED) * 0.1 * UNIT_HSPEED_SCALE
  if (math.abs(hSpeed) >= 10) then
    lcd.drawNumber(HUD_X+44,HUD_Y_MID-14,hSpeed,MIDSIZE+RIGHT+CUSTOM_COLOR)
  else
    lcd.drawNumber(HUD_X+44,HUD_Y_MID-14,hSpeed*10,MIDSIZE+RIGHT+CUSTOM_COLOR+PREC1)
  end
#ifdef HUDTIMER
  hudDrawTime = hudDrawTime + (getTime() - hudStart)
  hudDrawCounter = hudDrawCounter + 1
#endif
  -- min/max arrows
  if status.showMinMaxValues == true then
    drawLib.drawVArrow(HUD_X+50, HUD_Y_MID-9,true,false,utils)
    drawLib.drawVArrow(HUD_X+HUD_WIDTH-57, HUD_Y_MID-9,true,false,utils)
  end
    -- compass ribbon
  drawLib.drawCompassRibbon(YAW_Y,myWidget,conf,telemetry,status,battery,utils,YAW_WIDTH,YAW_X_MIN,YAW_X_MAX,YAW_STEPWIDTH)
end

local function background(myWidget,conf,telemetry,status,utils)
end

return {drawHud=drawHud,background=background}
