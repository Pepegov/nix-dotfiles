{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    jetbrains-mono
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      alefragnani.project-manager
      arrterian.nix-env-selector
      bbenoist.nix
      dlasagno.rasi
      edwinsulaiman.jetbrains-rider-dark-theme
      github.vscode-github-actions
      isudox.vscode-jetbrains-keybindings
      jnoortheen.nix-ide
      mkhl.direnv
      ms-azuretools.vscode-containers
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-pylance
      ms-python.vscode-python-envs
      ms-vscode.cmake-tools
      ms-vscode.cpp-devtools
      ms-vscode.cpptools
      ms-vscode.cpptools-extension-pack
      ms-vscode.cpptools-themes
      ms-vscode.vscode-serial-monitor
      pinage404.nix-extension-pack
      tamasfe.even-better-toml
      vscode-arduino.vscode-arduino-community
    ];

    programs.vscode.userSettings = {
      # ---------- THEME ----------
      "workbench.colorTheme" = "JetBrains Rider Dark Theme";
      "workbench.iconTheme" = "vs-seti";

      # ---------- UI (Rider style) ----------
      "workbench.activityBar.location" = "left";
      "workbench.sideBar.location" = "left";
      "workbench.statusBar.visible" = true;

      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "selection";
      "editor.cursorSmoothCaretAnimation" = "on";

      # ---------- Editor behavior (JetBrains-like) ----------
      "editor.tabSize" = 4;
      "editor.insertSpaces" = true;
      "editor.detectIndentation" = false;

      "editor.formatOnSave" = true;
      "editor.formatOnPaste" = true;

      "files.autoSave" = "afterDelay";

      # ---------- Search like Rider ----------
      "search.useIgnoreFiles" = true;
      "search.useGlobalIgnoreFiles" = true;

      # ---------- Terminal ----------
      "terminal.integrated.fontFamily" = "JetBrains Mono";
      "terminal.integrated.defaultProfile.linux" = "zsh";

      # ---------- IntelliSense / Python ----------
      "python.analysis.typeCheckingMode" = "basic";
      "python.analysis.autoImportCompletions" = true;

      # ---------- Nix dev experience ----------
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";

      # ---------- UX tweaks ----------
      "explorer.compactFolders" = false;
      "workbench.editor.enablePreview" = false;
      "breadcrumbs.enabled" = true;
    };

    programs.vscode.keybindings = [
      # ---------- Navigation ----------
      { key = "ctrl+n"; command = "workbench.action.quickOpen"; }
      { key = "shift+shift"; command = "workbench.action.quickOpen"; }

      # Go to file (Rider-style)
      { key = "ctrl+shift+n"; command = "workbench.action.quickOpen"; }

      # Search everywhere
      { key = "ctrl+shift+a"; command = "workbench.action.showCommands"; }

      # ---------- Refactoring ----------
      { key = "ctrl+alt+shift+t"; command = "editor.action.refactor"; }

      # Rename
      { key = "shift+f6"; command = "editor.action.rename"; }

      # ---------- Run / Debug ----------
      { key = "shift+f10"; command = "workbench.action.debug.start"; }

      { key = "shift+f9"; command = "workbench.action.debug.run"; }

      # ---------- Navigation inside code ----------
      { key = "ctrl+b"; command = "editor.action.revealDefinition"; }

      { key = "ctrl+alt+b"; command = "editor.action.goToImplementation"; }

      # ---------- Tabs ----------
      { key = "ctrl+tab"; command = "workbench.action.nextEditor"; }
    ];
  };
}