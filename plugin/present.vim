if !has('nvim-0.5')
  echohl WarningMsg
  echom "Present needs Neovim >= 0.5"
  echohl None
  finish
endif

command! Present lua require("present").present()
command! PresentEnable lua require("present").present(true)
command! PresentDisable lua require("present").present(false)
