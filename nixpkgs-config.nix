{
  allowUnfree = true;

  packageOverrides = super: let self = super.pkgs; in with self; rec {

    squirrelsql = super.callPackage ./pkgs/squirrelsql {};

    eclipse-ee-452 = super.eclipses.buildEclipse {
      name = "eclipse-ee-4.5.2";
      description = "Eclipse EE IDE";
      sources = {
        "x86_64-linux" = super.fetchurl {
          url = http://download.eclipse.org/technology/epp/downloads/release/mars/2/eclipse-jee-mars-2-linux-gtk-x86_64.tar.gz;
          sha256 = "0fp2933qs9c7drz98imzis9knyyyi7r8chhvg6zxr7975c6lcmai";
        };
      };
    };

    eclipse-ee-46 = super.eclipses.buildEclipse {
      name = "eclipse-ee-4.6";
      description = "Eclipse EE IDE";
      sources = {
        "x86_64-linux" = super.fetchurl {
          url = https://eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/neon/R/eclipse-jee-neon-R-linux-gtk-x86_64.tar.gz&r=1;
          sha256 = "1wdq02gswli3wm8j1rlzk4c8d0vpb6qgl8mw31mwn2cvx6wy55rs";
          name = "eclipse-jee-neon-R-linux-gtk-x86_64.tar.gz";
        };
      };
    };

    idea-community = buildIdea rec {
      name = "idea-community-${version}";
      version = "2016.3";
      description = "Integrated Development Environment (IDE) by Jetbrains, community edition";
      license = stdenv.lib.licenses.asl20;
      src = fetchurl {
        url = "https://download.jetbrains.com/idea/ideaIC-${version}.tar.gz";
        sha256 = "1bp2a1x8nl5flklf160n7ka5clnb0xx9gwv5zd9li2bsf04zlzf3";
      };
      wmClass = "jetbrains-idea-ce";
    };

    systemToolsEnv = with super; buildEnv {
      name = "systemToolsEnv";
      paths = [
        ctags
        file
        gcc
        git
        gitAndTools.hub
        gnumake
        inetutils
        keychain
        nix-prefetch-scripts
        nix-repl
        nload
        shellcheck
        tmux
        tree
        unzip
        vim_configurable
        wget
        which
        xsel
        zip
      ];
    };

    javaEnv = with super; buildEnv {
      name = "javaEnv";
      paths = [
        openjdk
        maven
        eclipse-ee-46
        # idea.idea-ultimate
        idea.idea-community
        gradle
      ];
    };

    pythonEnv = with super; buildEnv {
      name = "pythonEnv";
      paths = [
        python3
      ];
    };

    awsEnv = with super; buildEnv {
      name = "awsEnv";
      paths = [
        awscli
      ];
    };

    buildTypeScriptEnv = { nodeVersion ? "default" }:
      let
        np = if nodeVersion == "default"
          then super.nodePackages
          else lib.getAttrFromPath [("nodePackages_" + nodeVersion)] super;
        node = if nodeVersion == "default"
          then super.nodejs
          else lib.getAttrFromPath [("nodejs-" + nodeVersion)] super;
      in super.buildEnv {
        name = "typeScriptDevEnv-${nodeVersion}";
        paths = [
          node
          np.typescript
          np.gulp
        ];
      };

    typeScriptEnv = buildTypeScriptEnv { nodeVersion = "4_x"; };

    buildHaskellEnv = { compiler ? "default" }:
      let
        hp = if compiler == "default"
          then super.haskellPackages
          else super.haskell.packages.${compiler};
      in super.buildEnv {
        name = "haskellEnv-${compiler}";
        paths = [
          hp.ghc
          hp.stack
          hp.hdevtools
        ];
      };

    haskellEnv = buildHaskellEnv {};

    haskellEnv-ghc7103 = buildHaskellEnv {
      compiler = "ghc7103";
    };

  };
}
