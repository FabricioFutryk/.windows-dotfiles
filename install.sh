#!/bin/bash

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \

sudo apt install nodejs python3 git docker gh -y

sudo systemctl is-enable --quiet docker || sudo systemctl enable docker
sudo systemctl is-active --quiet docker || sudo systemctl start docker

# Install Bun
curl -fsSL https://bun.sh/install | bash

# Install Oh My Posh for the WSL
sudo /usr/bin/wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

echo eval "$(oh-my-posh init bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/tokyonight_storm.omp.json)" >> $HOME/.bashrc

# Add SSH Authentication to GitHub
ssh-keygen -t ed25519 -C $(git config --get user.email) -f $HOME/.ssh/id_ed25519

eval "$(ssh-agent -s)"
ssh-add $HOME/.ssh/id_ed25519

echo "Enter your Github API Auth Token"
echo -n "Token: "
read -s gh_token

GH_TOKEN=$gh_token $(command -v gh) ssh-key add $HOME/.ssh/id_ed25519.pub -t "Desktop WSL"

ssh -T git@github.com

exit