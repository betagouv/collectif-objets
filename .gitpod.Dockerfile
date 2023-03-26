FROM gitpod/workspace-ruby-3.2
USER gitpod

RUN sudo install-packages libvips42 golang-go redis postgresql postgresql-contrib nodejs npm
RUN go get github.com/mailhog/MailHog

RUN _ruby_version=ruby-3.2.0 \
    && printf "rvm_gems_path=/home/gitpod/.rvm\n" > ~/.rvmrc \
    && bash -lc "rvm reinstall ${_ruby_version} && \
                 rvm use ${_ruby_version} --default" \
    && printf "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc \
    && printf "{ rvm use \$(rvm current); } >/dev/null 2>&1\n" >> "$HOME/.bashrc.d/70-ruby"
