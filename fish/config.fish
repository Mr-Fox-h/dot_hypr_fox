if status is-interactive
  set fish_greeting
  fastfetch --logo-type kitty-direct
  starship init fish | source
end
