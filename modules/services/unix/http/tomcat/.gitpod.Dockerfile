FROM gitpod/workspace-full
RUN sudo wget https://apt.puppet.com/puppet-tools-release-bionic.deb && \
    wget https://apt.puppetlabs.com/puppet6-release-bionic.deb && \
    sudo dpkg -i puppet6-release-bionic.deb && \
    sudo dpkg -i puppet-tools-release-bionic.deb && \
    sudo apt-get update && \
    sudo apt-get install -y pdk zsh puppet-agent && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*
RUN sudo usermod -s $(which zsh) gitpod && \
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    echo "plugins=(git gitignore github gem pip bundler python ruby docker docker-compose)" >> /home/gitpod/.zshrc && \
    echo 'PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin"'  >> /home/gitpod/.zshrc && \
    sudo /opt/puppetlabs/puppet/bin/gem install puppet-debugger hub -N && \
    mkdir -p /home/gitpod/.config/puppet && \
    /opt/puppetlabs/puppet/bin/ruby -r yaml -e "puts ({'disabled' => true}).to_yaml" > /home/gitpod/.config/puppet/analytics.yml
RUN rm -f puppet6-release-bionic.deb  puppet-tools-release-bionic.deb
ENTRYPOINT /usr/bin/zsh
