{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  # ============================================
  # Home Manager 配置 - 用户级环境
  # ============================================
  
  # Home Manager 版本
  home.stateVersion = "25.11";
  
  # 设置用户名
  home.username = "reyear";
  home.homeDirectory = "/home/reyear";
  
  # ============================================
  # 包管理器配置
  # ============================================
  
  nixpkgs = {
    # 允许使用不稳定源的包
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
    
    # 包覆盖（可以在这里覆盖特定包的版本）
    overlays = [
      # 示例：使用不稳定源的包
      (final: prev: {
        # 可以从不稳定源获取某些包
        # some-package = pkgs-unstable.some-package;
      })
    ];
  };
  
  # ============================================
  # 基础工具和 CLI 工具
  # ============================================
  
  home.packages = with pkgs; [
    # 文件管理
    ranger      # 终端文件管理器
    lf          # 另一个文件管理器
    mc          # Midnight Commander
    fdupes      # 重复文件查找
    ncdu        # 磁盘使用分析
    
    # 文本处理
    bat         # cat 的替代，支持语法高亮
    exa         # ls 的替代
    ripgrep     # grep 的替代
    fd          # find 的替代
    jq          # JSON 处理
    yq          # YAML 处理
    xmlstarlet  # XML 处理
    
    # 网络工具
    httpie      # HTTP 客户端
    curlie      # curl 的现代替代
    wget2       # wget 的升级版
    mtr         # 网络诊断
    bandwhich   # 带宽使用监控
    
    # 系统监控
    htop
    btop
    nvtop
    glances
    procs       # ps 的替代
    bottom      # 系统监控
    
    # 开发工具
    nodejs_22
    python3
    go
    rustup
    gcc
    cmake
    gnumake
    pkg-config
    
    # 容器与虚拟化
    docker
    docker-compose
    podman
    distrobox
    
    # 终端工具
    tmux
    neofetch
    onefetch
    fastfetch
    starship    # 提示符
    zoxide      # 智能 cd
    eza         # exa 的继任者
    
    # 版本控制增强
    git-absorb
    git-interactive-rebase-tool
    delta       # git diff 美化
    lazygit
    
    # 编辑器
    neovim
    helix
    
    # 其他实用工具
    thefuck     # 命令纠正
    tldr        # 简化 man
    cheat       # 命令行备忘
    choose      # 交互式选择
  ];
  
  # ============================================
  # Shell 配置
  # ============================================
  
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    historyIgnore = [ "ls" "cd" "exit" "clear" ];
    
    shellAliases = {
      # 基础别名
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      lt = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
      ps = "procs";
      du = "dust";
      df = "duf";
      top = "btop";
      
      # Nix 相关
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#reyear-nixos";
      nrb = "sudo nixos-rebuild boot --flake /etc/nixos#reyear-nixos";
      ncg = "sudo nix-collect-garbage -d";
      nls = "nix profile list";
      nup = "nix flake update /etc/nixos";
      
      # Git 相关
      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --all";
      
      # 系统管理
      ssn = "sudo systemctl restart network-manager";
      ssnap = "sudo snapper -c root create -d";
      snap = "snapper -c root list";
    };
    
    initExtra = ''
      # 设置主题
      eval "$(starship init bash)"
      
      # 设置历史记录
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      shopt -s histappend
      
      # 设置路径
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/go/bin:$PATH"
      export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
      
      # 设置编辑器
      export EDITOR="nvim"
      export VISUAL="nvim"
      
      # 设置 Nix
      if [ -e /home/reyear/.nix-profile/etc/profile.d/nix.sh ]; then
        . /home/reyear/.nix-profile/etc/profile.d/nix.sh
      fi
      
      # 欢迎信息
      echo "欢迎回来，$USER！"
      echo "系统: $(uname -srm)"
      echo "NixOS: $(nixos-version)"
      echo ""
    '';
  };
  
  # ============================================
  # Git 配置
  # ============================================
  
  programs.git = {
    enable = true;
    userName = "reyear";
    userEmail = "reyearocean@qq.com";
    
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      df = "diff";
      lg = "log --oneline --graph --all";
      last = "log -1 HEAD";
    };
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "diff3";
      color.ui = true;
      core.editor = "nvim";
      credential.helper = "store";
    };
    
    ignores = [
      # 编辑器临时文件
      "*.swp"
      "*.swo"
      "*~"
      ".DS_Store"
      
      # 项目特定
      ".direnv/"
      ".envrc"
      "result"
      "dist/"
      "build/"
      "node_modules/"
      "__pycache__/"
      ".pytest_cache/"
      "*.pyc"
      "*.pyo"
      ".mypy_cache/"
      ".coverage"
      ".tox/"
      ".venv/"
      "venv/"
      "env/"
      ".env"
      ".vagrant/"
      ".vscode/"
      ".idea/"
      "*.iml"
      ".gradle/"
      "target/"
      "Cargo.lock"
      "*.class"
      "*.jar"
      "*.war"
      "*.ear"
      ".settings/"
      ".project"
      ".classpath"
      "bin/"
      ".metadata"
      ".recommenders"
      "tmp/"
      "temp/"
      "logs/"
      "*.log"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"
      "lerna-debug.log*"
      ".npm"
      ".eslintcache"
      ".stylelintcache"
      ".rpt2_cache/"
      ".rts2_cache_cjs/"
      ".rts2_cache_es/"
      ".rts2_cache_umd/"
      ".parcel-cache"
      ".next"
      ".nuxt"
      ".cache"
      ".vuepress/dist"
      ".serverless/"
      ".fusebox/"
      ".dynamodb/"
      ".tern-port"
      ".yarn/cache"
      ".yarn/unplugged"
      ".yarn/build-state.yml"
      ".yarn/install-state.gz"
      ".pnp.*"
    ];
  };
  
  # ============================================
  # 编辑器配置
  # ============================================
  
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    
    # 基础插件配置
    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-commentary
      vim-surround
      vim-repeat
      vim-fugitive
      vim-airline
      vim-airline-themes
    ];
    
    extraConfig = ''
      " 基础设置
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set ignorecase
      set smartcase
      set mouse=a
      set termguicolors
      
      " 主题
      colorscheme desert
      
      " 键映射
      let mapleader = " "
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>Q :q!<CR>
    '';
  };
  
  # ============================================
  # 终端配置
  # ============================================
  
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
        opacity = 0.9;
        startup_mode = "Maximized";
      };
      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono";
          style = "Italic";
        };
        size = 12.0;
      };
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
      };
      key_bindings = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "Key0";
          mods = "Control";
          action = "ResetFontSize";
        }
        {
          key = "Equals";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "Minus";
          mods = "Control";
          action = "DecreaseFontSize";
        }
      ];
    };
  };
  
  # ============================================
  # Starship 提示符
  # ============================================
  
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      format = '''
        $username$hostname$directory$git_branch$git_status$git_state$git_metrics$nix_shell
        $character
      ''';
      
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      
      git_status = {
        style = "bold green";
      };
      
      nix_shell = {
        symbol = "❄ ";
        style = "bold blue";
        format = "[$symbol$state]($style) ";
      };
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };
  
  # ============================================
  # 其他程序配置
  # ============================================
  
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };
  
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  
  # ============================================
  # 服务配置
  # ============================================
  
  services = {
    # SSH 代理转发
    ssh-agent.enable = true;
    
    # GPG 代理
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    
    # 其他用户级服务
    lorri.enable = false;  # 如果需要可以启用
  };
  
  # ============================================
  # 系统级配置覆盖（用于用户级设置）
  # ============================================
  
  # 设置环境变量
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
    SHELL = "${pkgs.bash}/bin/bash";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };
  
  # ============================================
  # 启用 home-manager 管理配置文件
  # ============================================
  
  home.file = {
    # 示例：复制配置文件到 ~/.config
    # ".config/nvim/init.vim".source = ./dotfiles/nvim/init.vim;
    # ".tmux.conf".source = ./dotfiles/tmux.conf;
  };
  
  # ============================================
  # 启用功能模块
  # ============================================
  
  # 启用用户级 systemd 服务管理
  systemd.user.startServices = true;
  
  # 自动垃圾回收
  home.activation = {
    cleanupBeforeActivation = ''
      # 清理旧的 home-manager 世代
      ${pkgs.findutils}/bin/find $HOME/.local/state/home-manager/gcroots -type l -mtime +30 -delete 2>/dev/null || true
    '';
  };
  
  # ============================================
  # 让 home-manager 管理 home 目录
  # ============================================
  
  home.homeDirectory = "/home/reyear";
  
  # 程序路径
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.local/share/nvim/mason/bin"
  ];
}
