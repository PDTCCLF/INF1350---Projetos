local buzzer = 7

local frequencias = {
  a = 440,
  b = 494,
  c = 523,
  d = 587,
  e = 659,
  f = 698,
  g = 784,
}

local function beep(notas)
  local nota = table.remove(notas,1)
  local freq,duration = nota[1],nota[2]
  freq = frequencias[freq] or freq
  pwm.stop(buzzer)
  pwm.setup(buzzer, freq, 512)
  pwm.start(buzzer)
  tmr.create():alarm(duration, tmr.ALARM_SINGLE, function()
    pwm.stop(buzzer)
    if #notas > 0 then
      beep(notas)
    end
  end)
end

return beep
