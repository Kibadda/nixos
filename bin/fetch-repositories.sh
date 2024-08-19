NEOVIM_DIR="$HOME/.config/nvim"
if [[ ! -d $NEOVIM_DIR ]]; then
  git clone -b nixos --single-branch git@github.com:Kibadda/rocks.nvim $NEOVIM_DIR
fi

if [[ ! -d $PASSWORD_STORE_DIR ]]; then
  git clone git@github.com:Kibadda/password-store $PASSWORD_STORE_DIR
fi
