{ config, lib, pkgs, user, ... }:

{
  environment.systemPackages = with pkgs; [
    javaEnv
  ];

  environment.shellAliases = {
    # TODO: When can we start using SSL with GA's external Nexus?
    mvn = "mvn -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true";
  };

  environment.extraInit = ''
    export JAVA_HOME=$(dirname $(dirname $(readlink -e $(which java))))
  '';

  system.activationScripts = {
    mavenSettings = pkgs.lib.stringAfter [ "users" ]
      ''
      if [ ! -e ~${user.username}/.m2/settings.xml ]; then
        mkdir -p ~${user.username}/.m2
        cat > ~${user.username}/.m2/settings.xml << 'EOF'

      <?xml version="1.0" encoding="UTF-8"?>
      <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
      <proxies>
        <proxy>
          <id>https</id>
          <active>true</active>
          <protocol>https</protocol>
          <host>localhost</host>
          <port>3128</port>
          <nonProxyHosts>localhost</nonProxyHosts>
        </proxy>
        <proxy>
          <id>http</id>
          <active>true</active>
          <protocol>http</protocol>
          <host>localhost</host>
          <port>3128</port>
          <nonProxyHosts>localhost</nonProxyHosts>
        </proxy>
      </proxies>
      <servers>
        <server>
          <id>nexus.gadevs</id>
          <username>username</username>
          <password>password</password>
        </server>
      </servers>
      <mirrors>
        <mirror>
          <id>nexus.gadevs</id>
          <name>GA Nexus</name>
          <url>https://nexus.gadevs.ga./repository/maven-public/</url>
          <mirrorOf>*</mirrorOf>
        </mirror>
      </mirrors>
      </settings>
      EOF

        chown -R ${user.username}.users ~${user.username}/.m2
      fi
      '';
  };

}
