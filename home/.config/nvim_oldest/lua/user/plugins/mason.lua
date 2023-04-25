local status_ok_mason, mason = pcall(require, "mason")
if not status_ok_mason then
  return
end

mason.setup()
