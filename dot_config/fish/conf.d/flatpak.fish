# Add Flatpak export paths (system and user) if they exist

set -l flatpak_system /var/lib/flatpak/exports/bin
set -l flatpak_user ~/.local/share/flatpak/exports/bin

if test -d $flatpak_system
    fish_add_path $flatpak_system
end

if test -d $flatpak_user
    fish_add_path $flatpak_user
end
