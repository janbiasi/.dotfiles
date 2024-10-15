set -q FSH_ABBRS_INITIALIZED; and return

# fs
if type -q eza
  abbr ls 'eza --git --icons --color=always --group-directories-first'
  abbr ll 'eza --git --icons --color=always --group-directories-first -la'
end

# system
if type -q bat
  abbr cat 'bat'
end

# git
abbr --add g 'git'

# neovim
if type -q nvim
  abbr --add vim 'nvim'
  abbr --add vi 'nvim'
  abbr --add v 'nvim'
  abbr --add ovim 'vim'
end 

# no need to run over-and-over
set -g FSH_ABBRS_INITIALIZED true