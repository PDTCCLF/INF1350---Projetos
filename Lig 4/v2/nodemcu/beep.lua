local buzzer = 7
local function beep(freq,duration)
  pwm.stop(buzzer)
  pwm.setup(buzzer, freq, 512)
  pwm.start(buzzer)
  tmr.create():alarm(duration, tmr.ALARM_SINGLE, function() pwm.stop(buzzer) end)
end

return beep