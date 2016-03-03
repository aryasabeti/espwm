require('espwm')

MAX_DUTY = 1023

local fade_in = function(p)
  if p.duty >= 1023 then
    return nil
  else
    p.duty = p.duty + 1
    return p
  end
end

local fade_out = function(p)
  if p.duty <= 0 then
    return nil
  else
    p.duty = p.duty - 1
    return p
  end      
end

local triple_blink = function(p)
  if p.reps <= 0 then
    return nil
  elseif p.interval == 50 then
    p.interval = 200
    p.duty = 0
    p.reps = p.reps - 1
  else
    p.interval = 50
    p.duty = MAX_DUTY
  end

  return p
end

local heart_beat = function(p)
  local intervals = {40, 200, 40, 900}

  p.index = p.index + 1
  if p.index > 4 then
    p.index = 1
  end

  p.interval = intervals[p.index]
  p.duty = (p.index % 2) * MAX_DUTY

  return p
end

espwm.init(1, 6) --IO 1, timer 6
espwm.q_pattern({interval=2, duty=0}, fade_in)
espwm.q_pattern({interval=2, duty=MAX_DUTY}, fade_out)
espwm.q_pattern({interval=50, duty=MAX_DUTY, reps=3}, triple_blink)
espwm.q_pattern({interval=2, duty=MAX_DUTY}, fade_out)
espwm.q_pattern({interval=2, duty=0}, fade_in)
espwm.q_pattern({interval=40, duty=MAX_DUTY, index=1}, heart_beat)
