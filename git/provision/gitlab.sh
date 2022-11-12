#!/usr/bin/env bash
sudo apt install ca-certificates curl openssh-server tzdata perl -y
debconf-set-selections <<< "postfix postfix/mailname string a4l-git.animals4life.local"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install --assume-yes postfix

cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
sudo bash /tmp/script.deb.sh
sudo EXTERNAL_URL="http://a4l-git.animals4life.local"
sudo apt-get install gitlab-ce
#sudo gitlab-ctl reconfigure
#gitlab-ctl start


#add firewall rules
sudo ufw allow http
sudo ufw allow https
sudo ufw allow OpenSSH


#Git ldap config

cd /etc/gitlab

cat <<EOT>> gitlab.rb
gitlab_rails['ldap_enabled'] = true
#gitlab_rails['prevent_ldap_sign_in'] = false

###! **remember to close this block with 'EOS' below**
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
 main: # 'main' is the GitLab 'provider ID' of this LDAP server
  label: 'LDAP'
  host: 'a4ldc01.animals4life.local'
  port: 389
  uid: 'sAMAccountName'
  bind_dn: 'CN=Administrator,CN=Users,DC=animals4life,DC=local'
  password: 'msx@9797'
  encryption: 'plain' # "start_tls" or "simple_tls" or "plain"
  verify_certificates: true
  smartcard_auth: false
  active_directory: true
  allow_username_or_email_login: false
  block_auto_created_users: false
  base: 'CN=Users,DC=animals4life,DC=local'
  user_filter: '(memberOf=CN=gitlab_users,OU=Groups,DC=animals4life,DC=local)'
EOS

EOT

#### Configure and start gitlab
sudo gitlab-ctl reconfigure
gitlab-ctl start

