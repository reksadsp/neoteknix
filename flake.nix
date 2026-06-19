{
  description = "Configuration NixOS éducative pour le Bac Pro CIEL - Association";

  # =============================================================================
  # 📥 INPUTS (DÉPENDANCES)
  # =============================================================================
  
  inputs = {
    # Nixpkgs - Version stable (23.11)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Flake-utils pour les utilitaires
    flake-utils.url = "github:numtide/flake-utils";
    
    # Home-manager (optionnel pour la gestion des utilisateurs)
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # =============================================================================
  # 📤 OUTPUTS (CONFIGURATIONS)
  # =============================================================================
  
  outputs = { self, nixpkgs, flake-utils, home-manager, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = nixpkgs.lib;
      in
      {
        # ---------------------------------------------------------------------------
        # 🖥️  CONFIGURATION NIXOS PRINCIPALE
        # ---------------------------------------------------------------------------
        
        nixosConfigurations = {
          # Configuration par défaut (pour une machine générique)
          neoteknix = lib.nixosSystem {
            inherit system pkgs lib;
            
            modules = [
              # Configuration de base
              {
                # =======================================================================
                # 📋 CONFIGURATION SYSTÈME DE BASE
                # =======================================================================

                # ---------------------------------------------------------------------------
                # Paramètres système
                # ---------------------------------------------------------------------------
                time.timeZone = "Europe/Paris";
                i18n.defaultLocale = "fr_FR.UTF-8";
                console.keyMap = "fr";
                console.font = "Lat2-Terminus16";

                networking.hostName = "neoteknix";
                networking.hostId = "userId";

                # ---------------------------------------------------------------------------
                # Matériel
                # ---------------------------------------------------------------------------
                hardware.cpu.intel.updateMicrocode = lib.mkDefault (lib.versionAtLeast config.nixpkgs.pkgset "23.11");
                hardware.cpu.amd.updateMicrocode = lib.mkDefault (lib.versionAtLeast config.nixpkgs.pkgset "23.11");

                powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
                powerManagement.enable = true;

                # Correction du bug DMAR (pour les BIOS problématiques)
                boot.kernelParams = [ "iommu=soft" ];
                # Alternatives (décommentez si nécessaire):
                # boot.kernelParams = [ "intel_iommu=off" ];  # Pour Intel
                # boot.kernelParams = [ "iommu=off" ];       # Dernier recours

                # ---------------------------------------------------------------------------
                # Bootloader
                # ---------------------------------------------------------------------------
                boot.loader.systemd-boot.enable = true;
                boot.loader.efi.canTouchEfiVariables = true;
                boot.supportedFilesystems = [ "ntfs" ];
                boot.initrd.postDeviceCommands = lib.mkAfter "
                  modprobe -a dm_mod
                ";

                # =======================================================================
                # 🖥️  ENVIRONNEMENT GRAPHIQUE
                # =======================================================================

                services.xserver.enable = true;
                # Désactivation de l'interface graphique
                services.xserver.desktopManager.gnome.enable = false;
                services.xserver.displayManager.gdm.enable = false;

                #services.xserver = {
                #  enable = true;
                #  libinput.enable = true;
                #  libinput.touchpad.tapping = true;
                #  libinput.touchpad.naturalScrolling = true;
                #  desktopManager.gnome.enable = true;
                #  displayManager.gdm.enable = true;
                #  displayManager.defaultSession = "gnome";
                #};

                services.gnome = {
                  gnome-shell-extensions = with pkgs.gnomeShellExtensions; [
                    appindicator
                    dash-to-dock
                    desktop-icons-ng
                  ];
                  shellPerformance = {
                    animations = false;
                    compositing = true;
                  };
                  gnome-software = {
                    enable = true;
                    enableFlatpakSupport = true;
                    enablePackagekit = true;
                    disableSnap = true;
                    plugins = [ "flatpak" "packagekit" "firmware" ];
                  };
                };

                services.packagekit.enable = true;

                # Polices supplémentaires
                fonts.packages = with pkgs; [
                  dejavu_fonts
                  liberation_fonts
                  noto-fonts
                  noto-fonts-cjk
                  noto-fonts-emoji
                  fira-code
                ];

                # =======================================================================
                # 📦 GROUPES D'APPLICATIONS PAR DOMAINE
                # =======================================================================

                nixpkgs.config.allowUnfree = true;
                nixpkgs.config.allowUnfreePredicate = pkg: 
                  builtins.elem (lib.getName pkg) [
                    "ltspice" "sketchup" "unity-editor" "meshtastic"
                    "qidi-print" "cura" "prusa-slicer"
                  ];

                # ---------------------------------------------------------------------------
                # 🔌 Électro-mécanique
                # ---------------------------------------------------------------------------
                config.environment.electroMecanique = with pkgs; [
                  # Conception électronique
                  kicad
                  kicad-library-3d
                  
                  # Simulation de circuits
                  ltspice
                  ngspice
                  
                  # Conception mécanique et 3D
                  openscad
                  free-cad
                  
                  # Impression 3D (Slicers)
                  ultimaker-cura
                  prusa-slicer
                  
                  # Outils supplémentaires
                  wine-staging
                  winetricks
                  gerbv
                  geda-gaf
                  electric
                ];

                # ---------------------------------------------------------------------------
                # 💻 Informatique / Développement
                # ---------------------------------------------------------------------------
                config.environment.informatique = with pkgs; [
                  # Python
                  python3
                  python3Packages.pip
                  python3Packages.virtualenv
                  python3Packages.pylint
                  python3Packages.black
                  python3Packages.jupyterlab
                  python3Packages.numpy
                  python3Packages.pandas
                  
                  # Rust
                  rustc
                  cargo
                  cargo-edit
                  clippy
                  rustfmt
                  
                  # Outils de développement
                  git
                  git-lfs
                  github-cli
                  
                  # IDE et éditeurs
                  vscode
                  vscodium
                  arduino-ide
                  geany
                  
                  # Développement de jeux
                  godot
                  
                  # Outils système
                  htop
                  iotop
                  iftop
                  nmon
                  
                  # Debugging
                  gdb
                  valgrind
                  strace
                  ltrace
                ];

                # ---------------------------------------------------------------------------
                # 🌐 Réseaux et Cybersécurité
                # ---------------------------------------------------------------------------
                config.environment.reseaux = with pkgs; [
                  # Communication sécurisée
                  element-desktop
                  
                  # Analyse réseau
                  nmap
                  wireshark
                  tcpdump
                  
                  # Sécurité réseau
                  zenmap
                  nikto
                  sqlmap
                  metasploit-framework
                  
                  # Outils réseau divers
                  net-tools
                  iproute2
                  dnsutils
                  whois
                  traceroute
                  
                  # Analyse WiFi
                  aircrack-ng
                  reaver
                  wifi-radar
                  
                  # VPN et anonymat
                  openvpn
                  wireguard-tools
                  tor
                  
                  # Outils éducatifs réseau
                  gns3
                ];

                # ---------------------------------------------------------------------------
                # 🎓 Paquets communs à tous les élèves
                # ---------------------------------------------------------------------------
                config.environment.paquetsCommuns = with pkgs; [
                  # Navigateurs
                  firefox
                  firefox-esr
                  
                  # Bureautique
                  libreoffice
                  libreoffice-langpack-fr
                  
                  # Communication
                  thunderbird
                  
                  # Graphisme
                  gimp
                  inkscape
                  
                  # Multimédia
                  vlc
                  audacious
                  
                  # Gestion de fichiers
                  file-roller
                  nautilus
                  gnome-software
                  
                  # Utilitaires
                  gparted
                  testdisk
                  
                  # Documentation
                  evince
                  okular
                  
                  # Jeux éducatifs
                  gcompris
                  
                  # Sécurité de base
                  keepassxc
                  veracrypt
                  
                  # Outils système
                  gnome-calculator
                  gnome-characters
                  gnome-font-viewer
                  gnome-system-monitor
                  
                  # Support français
                  aspell
                  aspellDicts.fr
                  hunspell
                  hunspellDicts.fr
                  
                  # Impression
                  cups
                  hplip
                  gutenprint
                  
                  # Sauvegarde
                  deja-dup
                ];

                # =======================================================================
                # 👥 GESTION DES UTILISATEURS
                # =======================================================================

                users.groups.eleves = {
                  name = "eleves";
                  gid = 10000;
                };

                users.groups.formateurs = {
                  name = "formateurs";
                  gid = 10001;
                };

                # Exemple d'utilisateur formateur
                users.users.formateur = {
                  isNormalUser = true;
                  description = "Formateur - Bac Pro CIEL";
                  uid = 1001;
                  gid = 10001;
                  groups = [ "formateurs" "wheel" "networkmanager" "docker" ];
                  home = "/home/formateur";
                  shell = pkgs.bash;
                  
                  environment.systemPackages = 
                    config.environment.paquetsCommuns ++
                    config.environment.electroMecanique ++
                    config.environment.informatique ++
                    config.environment.reseaux ++
                    with pkgs; [
                      htop
                      iotop
                      iftop
                      nmon
                      gparted
                      testdisk
                      wireshark
                      virtualbox
                      qemu
                      libvirt
                    ];
                };

                # =======================================================================
                # 🔧 SERVICES SYSTÈME
                # =======================================================================

                networking.networkmanager.enable = true;
                networking.firewall.enable = true;
                networking.firewall.allowedTCPPorts = [ 22 80 443 ];
                networking.firewall.allowedUDPPorts = [ 53 67 68 ];

                services.openssh = {
                  enable = true;
                  permitRootLogin = "no";
                  passwordAuthentication = true;
                  allowUsers = [ "formateur" ];
                };

                services.samba = {
                  enable = true;
                  security = "user";
                  shares = {
                    public = {
                      path = "/srv/samba/public";
                      "read only" = false;
                      "guest ok" = true;
                      "browseable" = true;
                    };
                    eleves = {
                      path = "/srv/samba/eleves";
                      "read only" = false;
                      "guest ok" = false;
                      "browseable" = true;
                      "valid users" = "@eleves";
                      "write list" = "@eleves";
                    };
                  };
                };

                services.cups = {
                  enable = true;
                  webInterface = true;
                  rawPrinting = true;
                };

                services.avahi = {
                  enable = true;
                  publish = {
                    enable = true;
                    addresses = true;
                    workstation = true;
                  };
                };

                services.docker = {
                  enable = true;
                  group = "docker";
                };

                services.flatpak = {
                  enable = true;
                  flathub.enable = true;
                  enableUserInstallation = true;
                  autoUpdate = true;
                };

                # =======================================================================
                # 💾 STOCKAGE
                # =======================================================================

                system.activationScripts.setupSharedDirs = ''
                  mkdir -p /srv/samba/public
                  mkdir -p /srv/samba/eleves
                  chmod -R 777 /srv/samba/public
                  chmod -R 770 /srv/samba/eleves
                  chown -R root:eleves /srv/samba/eleves
                '';

                services.gvfs.enable = true;
                services.udisk2.enable = true;

                # =======================================================================
                # 🔒 SÉCURITÉ
                # =======================================================================

                system.autoUpgrade = {
                  enable = true;
                  channel = "https://nixos.org/channels/nixos-23.11";
                  dates = "daily";
                  times = "03:00";
                };

                security.policies = {
                  password = {
                    minLength = 8;
                    maxLength = 128;
                    requireDigits = true;
                    requireUppercase = true;
                    requireLowercase = true;
                    requireSpecial = true;
                  };
                };

                security.limits = {
                  nofile = {
                    soft = 4096;
                    hard = 8192;
                  };
                  nproc = {
                    soft = 1024;
                    hard = 2048;
                  };
                };

                # =======================================================================
                # 🎨 PERSONNALISATION
                # =======================================================================

                services.gnome.gnome-shell.desktopBackground = {
                  pictureUri = "file:///etc/nixos/wallpaper.jpg";
                  pictureOptions = "zoom";
                };

                system.stateVersion = "23.11";
              }
            ];
          };

          # ---------------------------------------------------------------------------
          # 🖥️  CONFIGURATIONS POUR PLUSIEURS MACHINES
          # ---------------------------------------------------------------------------
          
          # Exemple: Configuration pour une machine spécifique du labo
          # pc-lab1 = lib.nixosSystem {
          #   inherit system pkgs lib;
          #   modules = [
          #     ./configuration.nix
          #     { networking.hostName = "pc-lab1"; }
          #     { users.users.eleve1 = { ... }; }
          #   ];
          # };
          #
          # pc-lab2 = lib.nixosSystem {
          #   inherit system pkgs lib;
          #   modules = [
          #     ./configuration.nix
          #     { networking.hostName = "pc-lab2"; }
          #   ];
          # };
        };

        # ---------------------------------------------------------------------------
        # 🏠 CONFIGURATION HOME-MANAGER (OPTIONNEL)
        # ---------------------------------------------------------------------------
        
        homeConfigurations = flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs { inherit system; };
          in
          {
            # Exemple de configuration utilisateur avec Home Manager
            # formateur = home-manager.lib.homeManagerConfiguration {
            #   pkgs = pkgs;
            #   username = "formateur";
            #   homeDirectory = "/home/formateur";
            #   configuration = { ... };
            # };
          }
        );
      }
    );

  # =============================================================================
  # 📝 INSTRUCTIONS D'UTILISATION
  # =============================================================================
  #
  # 1. ACTIVER L'UTILISATION DES FLAKES (si ce n'est pas déjà fait):
  #    echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nixos/nixos.conf
  #    sudo systemctl restart nix-daemon
  #
  # 2. CLONER CE DÉPÔT (ou copier ce fichier):
  #    git clone <ton-depot> /etc/nixos
  #    cd /etc/nixos
  #
  # 3. ACTIVER LA CONFIGURATION:
  #    sudo nixos-rebuild switch --flake .#asso-ciel
  #
  # 4. POUR UNE MACHINE SPÉCIFIQUE:
  #    sudo nixos-rebuild switch --flake .#pc-lab1
  #
  # 5. METTRE À JOUR:
  #    sudo nixos-rebuild switch --flake .#asso-ciel --upgrade
  #
  # 6. AJOUTER UNE NOUVELLE MACHINE:
  #    - Dupliquer la configuration asso-ciel dans nixosConfigurations
  #    - Donner un nom unique (ex: pc-lab1)
  #    - Personnaliser le hostname et les utilisateurs
  #    - Appliquer avec: sudo nixos-rebuild switch --flake .#pc-lab1
  #
  # 7. POUR LES ÉLÈVES:
  #    - Ajouter un utilisateur dans nixosConfigurations.<nom>.modules[0].users.users
  #    - Définir ses groupes d'applications
  #    - Exemple:
  #      users.users.eleve1 = {
  #        isNormalUser = true;
  #        groups = [ "eleves" "networkmanager" ];
  #        environment.systemPackages = 
  #          config.environment.paquetsCommuns ++ 
  #          config.environment.electroMecanique;
  #      };
  #
  # =============================================================================
  # 🔧 CORRECTION DU BUG DMAR
  # =============================================================================
  #
  # Si tu vois l'erreur:
  #   "DMAR firmware bug: No firmware reserved region can cover this RMRR"
  #
  # Solutions (déjà configurées dans le flake):
  # 1. iommu=soft (recommandé) - déjà activé
  # 2. Pour Intel: boot.kernelParams = [ "intel_iommu=off" ];
  # 3. Pour AMD: boot.kernelParams = [ "amd_iommu=off" ];
  # 4. Dernier recours: boot.kernelParams = [ "iommu=off" ];
  #
  # =============================================================================
  # 📚 RESSOURCES
  # =============================================================================
  #
  # Documentation Flakes:
  # - https://nixos.wiki/wiki/Flakes
  # - https://zero-to-nix.com/concepts/flakes
  #
  # Documentation NixOS:
  # - https://nixos.org/manual/nixos/stable/
  # - https://nixos.wiki/
  #
  # Exemples de flakes:
  # - https://github.com/nix-community/templates
  # - https://github.com/Misterio77/nix-starter-configs
}
