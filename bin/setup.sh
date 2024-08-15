NEOVIM_DIR="$HOME/.config/nvim"
if [[ ! -d $NEOVIM_DIR ]]; then
  git clone -b nixos --single-branch git@github.com:Kibadda/nvim $NEOVIM_DIR
fi

PASS_DIR="$HOME/.password-store"
if [[ ! -d $PASS_DIR ]]; then
  git clone git@github.com:Kibadda/password-store $PASS_DIR
fi
