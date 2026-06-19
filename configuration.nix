{ config, pkgs, lib, ... }:
{
  # =============================================================================
  # 📋 CONFIGURATION DE BASE
  # =============================================================================
  
  imports = [
    # Module pour la gestion des utilisateurs
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];
  # ---------------------------------------------------------------------------
  # Paramètres système
  # ---------------------------------------------------------------------------
  
  # Localisation (France)
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";
  console.font = "Lat2-Terminus16";
  # Nom de la machine (à personnaliser par PC)
  networking.hostName = "neotechnique";
  networking.hostId = "deadbeef";
  # ---------------------------------------------------------------------------
  # Matériel
  # ---------------------------------------------------------------------------
  
  # Activer le microcode CPU pour Intel/AMD
  hardware.cpu.intel.updateMicrocode = lib.mkDefault (lib.versionAtLeast config.nixpkgs.pkgset "23.11");
  hardware.cpu.amd.updateMicrocode = lib.mkDefault (lib.versionAtLeast config.nixpkgs.pkgset "23.11");
  # Gestion de l'énergie (pour portables)
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.enable = true;
  # =============================================================================
  # 🖥️  ENVIRONNEMENT GRAPHIQUE
  # =============================================================================
  
  # Activer le serveur X
  #services.xserver = {
  #  enable = true;
  #  libinput.enable = true;
  #  libinput.touchpad.tapping = true;
  #  libinput.touchpad.naturalScrolling = true;
  #  desktopManager.gnome.enable = true;
  #  displayManager.gdm.enable = true;
  #  displayManager.defaultSession = "gnome";
  #};

  # Configuration GNOME (simple et éducatif)
  #services.gnome = {
  #  gnome-shell-extensions = with pkgs.gnomeShellExtensions; [
       # Extensions utiles pour l'éducation
  #    appindicator
  #    dash-to-dock
  #    desktop-icons-ng
  #  ];

    # Désactiver les animations pour plus de fluidité
    shellPerformance = {
      animations = false;
      compositing = true;
    };
  };

  # Polices supplémentaires
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    fira-code
  ];

  # =============================================================================
  # 📦 GROUPES D'APPLICATIONS PAR DOMAINE
  # =============================================================================
  
  # Autoriser les paquets non-libres (nécessaire pour certains logiciels)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: 
    builtins.elem (lib.getName pkg) [
      "ltspice" "sketchup" "unity-editor" "meshtastic" 
      "qidi-print" "cura" "prusa-slicer"
    ];
  # ---------------------------------------------------------------------------
  # 🔌 Électro-mécanique
  # ---------------------------------------------------------------------------
  
  # Liste des paquets pour l'électronique et la mécanique
  config.environment.electroMecanique = with pkgs; [
    # 📐 Conception électronique
    kicad                # Suite complète pour la conception de circuits imprimés
    kicad-library-3d     # Bibliothèques 3D pour KiCad
    
    # 🔌 Simulation de circuits
    ltspice              # Simulateur SPICE pour l'électronique (non-libre)
    ngspice              # Alternative libre à LTSpice
    
    # 🏗️ Conception mécanique et 3D
    openscad             # OpenSCAD - Modélisation 3D par code
    free-cad             # FreeCAD - CAO paramétrique 3D
    
    # ⚙️ Impression 3D (Slicers)
    ultimaker-cura       # Cura - Slicer pour imprimantes 3D
    prusa-slicer         # PrusaSlicer - Alternative à Cura
    
    # Note: Qidi Studio n'est pas disponible dans nixpkgs.
    # Alternative: Utiliser PrusaSlicer ou Ultimaker Cura qui supportent la plupart des imprimantes.
    # Pour SketchUp: utiliser la version web ou installer via Wine
    wine-staging         # Pour installer SketchUp si nécessaire
    winetricks           # Pour gérer les dépendances Windows
    
    # 🔧 Outils supplémentaires
    gerbv                # Visualiseur de fichiers Gerber
    geda-gaf             # Suite gEDA pour la conception électronique
    electric             # Éditeur de circuits électriques
  ];
  # ---------------------------------------------------------------------------
  # 💻 Informatique / Développement
  # ---------------------------------------------------------------------------
  
  config.environment.informatique = with pkgs; [
    # 🐍 Python
    python3              # Python 3
    python3Packages.pip  # Gestionnaire de paquets Python
    python3Packages.virtualenv
    python3Packages.pylint
    python3Packages.black
    python3Packages.jupyterlab  # Pour les notebooks éducatifs
    python3Packages.numpy
    python3Packages.pandas
    
    # 🦀 Rust
    rustc                # Compilateur Rust
    cargo                # Gestionnaire de paquets Rust
    cargo-edit           # Pour gérer les dépendances Cargo
    clippy               # Linter Rust
    rustfmt              # Formateur de code Rust
    
    # 🔧 Outils de développement
    git                  # Contrôle de version
    git-lfs              # Pour les gros fichiers
    github-cli           # CLI GitHub (inclut Copilot si configuré)
    gitkraken            # Client Git graphique (via AppImage ou Flatpak)
    
    # ⚡ IDE et éditeurs
    arduino-ide
    vscode               # Visual Studio Code (via flatpak ou package)
    vscodium             # Alternative libre à VS Code
    geany                # Éditeur léger
    
    # 🎮 Développement de jeux (Unity)
    # Note: Unity Editor n'est pas dans nixpkgs par défaut
    # Solution 1: Utiliser la version via Flatpak
    # flatpakBuilder.buildFlatpak {
    #   name = "unity-editor";
    #   json = ./unity-editor.json;
    # };
    # Solution 2: Installer manuellement via .deb ou .rpm
    # Solution 3: Utiliser Godot comme alternative libre
    godot                # Godot Engine - Alternative libre à Unity
    
    # 🤖 Outils IA / Assistance
    # Note: GitHub Copilot nécessite une extension VS Code
    # Speckit: vérifier si disponible, sinon utiliser des alternatives
    
    # 📊 Outils système
    htop
    iotop
    iftop
    nmon
    
    # 🔍 Outils de debugging
    gdb
    valgrind
    strace
    ltrace
  ];
  # ---------------------------------------------------------------------------
  # 🌐 Réseaux et Cybersécurité
  # ---------------------------------------------------------------------------
  
  config.environment.reseaux = with pkgs; [
    # 💬 Communication sécurisée
    element-desktop      # Client Matrix officiel (Element)
    matrix-synapse       # Serveur Matrix (optionnel pour hébergement local)
    
    # 🔍 Analyse réseau
    nmap                 # Scanner de ports (inclut Zenmap)
    wireshark            # Analyseur de paquets réseau
    tcpdump              # Capture de paquets en ligne de commande
    
    # 🛡️ Sécurité réseau
    zenmap               # Interface graphique pour Nmap
    nikto                # Scanner de vulnérabilités web
    sqlmap               # Testeur d'injection SQL
    metasploit-framework # Framework de tests de pénétration
    
    # 🌍 Réseaux maillés (Mesh)
    # Note: LibreMesh n'est pas directement dans nixpkgs
    # Alternative: Installer les paquets nécessaires manuellement
    # meshtastic           # Projet Meshtastic pour communication décentralisée
    # Pour Meshtastic, voir: https://meshtastic.org/
    
    # 🔗 Outils réseau divers
    net-tools            # Outils réseau de base (ifconfig, etc.)
    iproute2             # Outils réseau modernes
    dnsutils             # Outils DNS (dig, nslookup)
    whois
    traceroute
    
    # 📡 Analyse WiFi
    aircrack-ng          # Suite pour l'analyse WiFi
    reaver              # Outils pour tester la sécurité WPS
    wifi-radar           # Scanner WiFi graphique
    
    # 🔒 VPN et anonymat
    openvpn
    wireguard-tools
    tor
    
    # 📋 Outils éducatifs réseau
    gns3                 # Simulateur réseau graphique
    packet-tracer       # Alternative: utiliser GNS3 ou des outils en ligne
  ];
  # ---------------------------------------------------------------------------
  # 🎓 Paquets communs à tous les élèves
  # ---------------------------------------------------------------------------
  
  config.environment.paquetsCommuns = with pkgs; [
    # 🌐 Navigateurs
    firefox              # Navigateur web par défaut
    firefox-esr          # Version ESR pour la stabilité
    
    # 📝 Bureautique
    libreoffice          # Suite bureautique complète
    libreoffice-langpack-fr
    
    # 📧 Communication
    thunderbird          # Client email
    
    # 🎨 Graphisme
    gimp                 # Éditeur d'images
    inkscape             # Éditeur vectoriel
    
    # 🎵 Multimédia
    vlc                  # Lecteur multimédia
    audacious            # Lecteur audio léger
    
    # 📁 Gestion de fichiers
    file-roller          # Archiveur
    nautilus             # Gestionnaire de fichiers GNOME
    
    # 📦 Gestion des applications (interface graphique)
    gnome-software       # Centre logiciel GNOME (comme sur Fedora)
    
    # 🔧 Utilitaires
    gparted              # Éditeur de partitions
    testdisk             # Récupération de données
    
    # 📚 Documentation
    evince               # Lecteur PDF
    okular               # Lecteur de documents universel
    
    # 🎮 Jeux éducatifs
    gcompris             # Suite de jeux éducatifs
    
    # 🔐 Sécurité de base
    keepassxc            # Gestionnaire de mots de passe
    veracrypt            # Chiffrement de disques
    
    # 📊 Outils système
    gnome-calculator
    gnome-characters
    gnome-font-viewer
    gnome-system-monitor
    
    # 🗣️ Support français
    aspell               # Correcteur orthographique
    aspellDicts.fr
    hunspell
    hunspellDicts.fr
    
    # 🖨️ Impression
    cups                 # Système d'impression
    hplip                # Support imprimantes HP
    gutenprint           # Pilotes pour de nombreuses imprimantes
    
    # 💾 Sauvegarde
    deja-dup             # Outil de sauvegarde simple
  ];
  # =============================================================================
  # 👥 GESTION DES UTILISATEURS
  # =============================================================================
  
  # Créer un groupe pour les élèves
  users.groups.eleves = {
    name = "eleves";
    gid = 10000;
  };
  # Créer un groupe pour les formateurs
  users.groups.formateurs = {
    name = "formateurs";
    gid = 10001;
  };
  # ---------------------------------------------------------------------------
  # Modèle de création d'utilisateur élève
  # ---------------------------------------------------------------------------
  # Pour ajouter un élève, décommentez et adaptez:
  #
  # users.users.eleve1 = {
  #   isNormalUser = true;
  #   description = "Élève 1 - Bac Pro CIEL";
  #   uid = 1000;
  #   gid = 10000; # Appartient au groupe eleves
  #   groups = [ "eleves" "networkmanager" "wheel" ];
  #   home = "/home/eleve1";
  #   shell = pkgs.bash;
  #   
  #   # Activer les groupes d'applications pour cet élève
  #   # Exemple: un élève spécialisé en électro-mécanique
  #   environment.systemPackages = 
  #     config.environment.paquetsCommuns ++
  #     config.environment.electroMecanique ++
  #     config.environment.informatique;
  #   
  #   # Configuration spécifique
  #   services.gvfs.enable = true; # Pour le montage automatique des périphériques
  # };
  # Exemple d'utilisateur formateur
  users.users.formateur = {
    isNormalUser = true;
    description = "Formateur - Bac Pro CIEL";
    uid = 1001;
    gid = 10001; # Appartient au groupe formateurs
    groups = [ "formateurs" "wheel" "networkmanager" "docker" ];
    home = "/home/formateur";
    shell = pkgs.bash;
    
    # Accès à tous les paquets pour le formateur
    environment.systemPackages = 
      config.environment.paquetsCommuns ++
      config.environment.electroMecanique ++
      config.environment.informatique ++
      config.environment.reseaux ++
      with pkgs; [
        # Outils supplémentaires pour le formateur
        htop
        iotop
        iftop
        nmon
        gparted
        testdisk
        wireshark
        nmap
        metasploit-framework
        virtualbox
        qemu
        libvirt
      ];
    
    # Autorisations supplémentaires
    services.gvfs.enable = true;
    services.udisk2.enable = true;
    policies.kernelPackages.enableDeadlockDetector = true;
  };
  # =============================================================================
  # 🔧 SERVICES SYSTÈME
  # =============================================================================
  
  # Activer le réseau
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 67 68 ];
  # Service SSH (pour l'administration à distance)
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = true;
    allowUsers = [ "formateur" ];
  };
  # Service VNC (optionnel pour l'assistance)
  services.x11vnc = {
    enable = false; # Activer si nécessaire
    # port = 5900;
    # authFile = "/etc/x11vnc/passwd";
  };
  # Service Samba (partage de fichiers avec Windows)
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
  # Service Cups (impression)
  services.cups = {
    enable = true;
    webInterface = true;
    rawPrinting = true;
  };
  # Service Avahi (découverte réseau)
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  # Service Docker (optionnel pour les formateurs)
  services.docker = {
    enable = true;
    group = "docker";
  };
  # Service Flatpak (pour les applications non disponibles dans nixpkgs)
  services.flatpak = {
    enable = true;
    # Ajouter Flathub (dépôt principal pour les applications Flatpak)
    flathub.enable = true;
    # Autoriser les utilisateurs à installer des applications Flatpak
    enableUserInstallation = true;
    # Mettre à jour automatiquement les applications Flatpak
    autoUpdate = true;
  };
  # GNOME Software (interface graphique pour installer des applications)
  services.gnome.gnome-software = {
    enable = true;
    # Activer le support Flatpak dans GNOME Software
    enableFlatpakSupport = true;
    # Activer le support pour les paquets système (Nix)
    enablePackagekit = true;
    # Cacher les applications snap (non utilisées sur NixOS)
    disableSnap = true;
    # Plugins à activer
    plugins = [ "flatpak" "packagekit" "firmware" ];
  };
  # PackageKit (backend pour GNOME Software)
  services.packagekit.enable = true;
  # =============================================================================
  # 💾 STOCKAGE
  # =============================================================================
  
  # Créer les répertoires partagés
  system.activationScripts.setupSharedDirs = ''
    mkdir -p /srv/samba/public
    mkdir -p /srv/samba/eleves
    chmod -R 777 /srv/samba/public
    chmod -R 770 /srv/samba/eleves
    chown -R root:eleves /srv/samba/eleves
  '';
  # Montage automatique des périphériques
  services.gvfs.enable = true;
  services.udisk2.enable = true;
  # =============================================================================
  # 🔒 SÉCURITÉ
  # =============================================================================
  
  # Mises à jour automatiques
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-23.11";
    dates = "daily";
    times = "03:00";
  };
  # Politique de mots de passe
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
  # Limites des ressources
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
  # =============================================================================
  # 🎨 PERSONNALISATION
  # =============================================================================
  
  # Fond d'écran personnalisé (à placer dans /etc/nixos/wallpaper.jpg)
  services.gnome.gnome-shell.desktopBackground = {
    pictureUri = "file:///etc/nixos/wallpaper.jpg";
    pictureOptions = "zoom";
  };
  # Nom de la distribution personnalisé
  system.stateVersion = "23.11";
  # =============================================================================
  # 📦 CONFIGURATION FLATPAK (pour les applications graphiques)
  # =============================================================================
  
  # Flathub est le dépôt principal pour les applications Flatpak.
  # Il permet d'installer des applications comme:
  # - SketchUp (com.trimble.SketchUp)
  # - Qidi Print (com.qidi.print)
  # - Unity Hub (com.unity.UnityHub)
  # - Discord, Spotify, etc.
  
  # Pour installer une application Flatpak après l'installation:
  # 1. Ouvrir "Logiciels" (GNOME Software) depuis le menu
  # 2. Rechercher l'application souhaitée
  # 3. Cliquer sur "Installer"
  #
  # Ou en ligne de commande:
  # flatpak install flathub com.app.Name
  #
  # Applications recommandées à installer via Flatpak:
  # - com.trimble.SketchUp          # SketchUp (si nécessaire)
  # - com.qidi.print               # Qidi Print (alternative à Qidi Studio)
  # - com.unity.UnityHub           # Unity Hub
  # - com.github.GitKraken         # GitKraken
  # - com.spotify.Client           # Spotify
  # - org.telegram.desktop         # Telegram
  # - com.discordapp.Discord       # Discord
  # - org.gnome.Extensions         # Extensions GNOME
  # =============================================================================
  # 📝 INSTRUCTIONS POUR L'INSTALLATION
  # =============================================================================
  
  # 1. Préparer le disque:
  #    - Créer une partition EFI (512Mo, type EF00)
  #    - Créer une partition swap (2x RAM)
  #    - Créer une partition root (ext4, 30-50Go)
  #    - Créer une partition home (ext4, reste de l'espace)
  #
  # 2. Monter les partitions:
  #    mount /dev/sdXn /mnt
  #    mount /dev/sdXm /mnt/home
  #    mount /dev/sdXp /mnt/boot
  #
  # 3. Générer la configuration:
  #    nixos-generate-config --root /mnt
  #
  # 4. Copier ce fichier dans /mnt/etc/nixos/configuration.nix
  #
  # 5. Installer:
  #    nixos-install
  #
  # 6. Après l'installation, pour chaque élève:
  #    - Créer l'utilisateur avec: useradd -m -G eleves,networkmanager -s /bin/bash eleveX
  #    - Définir le mot de passe: passwd eleveX
  #    - Ajouter les paquets spécifiques dans /etc/nixos/configuration.nix
  #    - Mettre à jour: nixos-rebuild switch
  #
  # 7. Pour installer des applications supplémentaires:
  #    **Via l'interface graphique (recommandé pour les élèves):**
  #    - Ouvrir l'application "Logiciels" (GNOME Software) depuis le menu
  #    - Parcourir ou rechercher l'application souhaitée
  #    - Cliquer sur "Installer"
  #    
  #    **Via la ligne de commande (pour les formateurs):**
  #    - flatpak install flathub org.app.Name
  #    - Ou ajouter manuellement dans configuration.nix
  #    
  #    **Exemples d'installation via Flatpak:**
  #    flatpak install flathub com.trimble.SketchUp      # SketchUp
  #    flatpak install flathub com.unity.UnityHub       # Unity Hub
  #    flatpak install flathub com.github.GitKraken     # GitKraken
  #
  # 8. Pour les logiciels non disponibles dans nixpkgs:
  #    - SketchUp: Installer via Wine ou utiliser la version web
  #    - Qidi Studio: Utiliser PrusaSlicer ou Ultimaker Cura
  #    - Unity: Installer manuellement ou utiliser Godot
  #    - LibreMesh: Suivre les instructions officielles
  # =============================================================================
  # 🔄 CONFIGURATIONS SPÉCIFIQUES PAR MACHINE
  # =============================================================================
  
  # Pour adapter la configuration à chaque machine, créer des fichiers dans:
  # /etc/nixos/machines/
  #
  # Exemple pour une machine spécifique:
  # /etc/nixos/machines/pc-lab1.nix
  #
  # Puis importer dans configuration.nix:
  # imports = [ ./machines/pc-lab1.nix ];
  # =============================================================================
  # ✅ VALIDATION DE LA CONFIGURATION
  # =============================================================================
  
  # Cette configuration a été conçue pour:
  # ✓ Être simple et éducative
  # ✓ Répondre aux besoins du Bac Pro CIEL
  # ✓ Organiser les applications par domaine
  # ✓ Permettre une personnalisation par élève
  # ✓ Fonctionner sur du matériel standard
  # ✓ Inclure les outils nécessaires pour l'électronique, l'informatique et les réseaux
  # Pour tester la configuration:
  # nixos-rebuild dry-activate
  #
  # Pour appliquer les changements:
  # nixos-rebuild switch
  #
  # Pour mettre à jour le système:
  # nix-channel --update
  # nixos-rebuild switch --upgrade
  # =============================================================================
  # 📚 RESSOURCES UTILES
  # =============================================================================
  
  # Documentation NixOS:
  # - https://nixos.org/manual/nixos/stable/
  # - https://nixos.wiki/
  #
  # Recherche de paquets:
  # - https://search.nixos.org/packages
  #
  # Communauté:
  # - Matrix: #nixos:matrix.org
  # - Discord: https://discord.gg/nixos
  # - Forum: https://discourse.nixos.org/
  # =============================================================================
  # ⚠️ NOTES IMPORTANTES
  # =============================================================================
  
  # 1. Certains logiciels (SketchUp, Qidi Studio, Unity) ne sont pas dans nixpkgs.
  #    Des alternatives libres sont proposées.
  #
  # 2. Pour les logiciels propriétaires nécessaires:
  #    - Utiliser Flatpak: flatpak install flathub com.app.Name
  #    - Ou installer via Wine
  #    - Ou créer un package Nix personnalisé
  #
  # 3. La configuration des imprimantes 3D peut nécessiter des pilotes
  #    supplémentaires.
  #
  # 4. Pour Meshtastic et LibreMesh, suivre les instructions officielles
  #    pour l'installation manuelle.
  #
  # 5. Penser à sauvegarder les configurations des élèves avant les
  #    mises à jour majeures.
}
