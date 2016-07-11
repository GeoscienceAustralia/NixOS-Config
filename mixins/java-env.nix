{ config, lib, pkgs, ... }:

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
}
