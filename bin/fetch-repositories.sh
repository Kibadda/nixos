if [[ ! -d $PASSWORD_STORE_DIR ]]; then
  git clone git@github.com:Kibadda/password-store $PASSWORD_STORE_DIR
fi

if [[ ! -d $NIXVIM_DIR ]]; then
  mkdir -p $NIXVIM_DIR
  git clone git@github.com:Kibadda/nixvim $NIXVIM_DIR
fi

if [[ ! -d $NEOVIM_DIR ]]; then
  mkdir -p $NEOVIM_DIR
  git clone git@github.com:Kibadda/neovim $NEOVIM_DIR
fi
