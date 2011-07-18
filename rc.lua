-- utils
function log(text)
  print('[awesome-' .. awesome.version .. '] ' .. text)
end

log('============= starting =============')
awesome.spawn('google-chrome')
log('------------- started --------------')
