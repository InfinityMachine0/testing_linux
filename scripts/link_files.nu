#! /usr/bin/env nu

def create_any_link [ start: string, destination: string, fresh_install: int ]: any -> any {
	"\n\n######\nlink\nstart\n" | save -fa /tmp/install_script.log
	$start | save -fa /tmp/install_script.log
	"\n######\ndestination\n" | save -fa /tmp/install_script.log
	$destination | save -fa /tmp/install_script.log

	if $fresh_install == 1 {
		ln -fs $start $destination
	} else {
		doas ln -fs $start $destination
	}
}

#######################################

def copy_any_file [ start: string, destination: string, fresh_install: int ]: any -> any {	
	"\n\n######\ncopy\nstart\n" | save -fa /tmp/install_script.log
	$start | save -fa /tmp/install_script.log
	"\n######\ndestination\n" | save -fa /tmp/install_script.log
	$destination | save -fa /tmp/install_script.log

	if $fresh_install == 1 {
		cp -rf $start $destination
	} else {
		doas cp -rf $start $destination
	}
}

#######################################

def read_from [ file: string, fresh_install: int ]: any -> string {
	"\n\n######\nopen\n" | save -fa /tmp/install_script.log
	$file | save -fa /tmp/install_script.log
	if $fresh_install == 1 {
		return ( open --raw $file )
	} else {
		return ( doas open --raw $file )
	}
}

#######################################

def save_to_file [ file: string, fresh_install: int ]: any -> any {
	"\n######\nsave\n" | save -fa /tmp/install_script.log
	$file | save -fa /tmp/install_script.log
	if $fresh_install == 1 {
		$in | save -f $file
	} else {
		$in | doas save -f $file
	}
}

#######################################

def replace_string [ file: string, find_string: string, replace_string: string, fresh_install: int ]: {
	read_from $file $fresh_install | str replace $find_string $replace_string | save_to_file $file $fresh_install
}

#######################################

def select_platform [ platform: int, fresh_install: int, path_to_git_repo: string ]: any -> any {
	if $platform == 1 {
		create_any_link ( [ $path_to_git_repo, "system/modules/platform/laptop_platform_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/platform/platform_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "system/modules/btrfs/laptop_btrfs_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/btrfs/btrfs_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "home-manager/modules/hyprland/hyprland_laptop_patch.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/moduels/hyprland/hyprland_platform_patch.nix" ] | path join )
		return 
	} else if $platform == 2 {
		create_any_link ( [ $path_to_git_repo, "system/modules/platform/desktop_platform_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/platform/platform_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "system/modules/btrfs/desktop_btrfs_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/btrfs/btrfs_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "home-manager/modules/hyprland/hyprland_desktop_patch.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/moduels/hyprland/hyprland_platform_patch.nix" ] | path join )
		return
	} else if $platform == 3 {
		create_any_link ( [ $path_to_git_repo, "system/modules/platform/virtualbox_platform_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/platform/platform_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "system/modules/btrfs/virtualbox_btrfs_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/btrfs/btrfs_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "home-manager/modules/hyprland/hyprland_virtualbox_patch.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/moduels/hyprland/hyprland_platform_patch.nix" ] | path join )
		return
	} else {
		print "incorrect input data\n"
		exit
	}
}

def select_gpu [ gpu:int, fresh_install: int, path_to_git_repo: string ]: any -> any {
	if $gpu == 1 {
		create_any_link ( [ $path_to_git_repo, "system/modules/gpu/no_gpu_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/gpu/gpu_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "home-manager/modules/hyprland/hyprland_no_nvidia_patch.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/moduels/hyprland/hyprland_gpu_patch.nix" ] | path join )
		return
	} else if $gpu == 2 {
		create_any_link ( [ $path_to_git_repo, "system/modules/gpu/nvidia_gpu_config.nix" ] | path join ) ( [ $path_to_git_repo, "system/moduels/gpu/gpu_config.nix" ] | path join )
		create_any_link ( [ $path_to_git_repo, "home-manager/modules/hyprland/hyprland_nvidia_patch.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/moduels/hyprland/hyprland_gpu_patch.nix" ] | path join )
		return
	} else {
		print "incorrect input data\n"
		exit
	}
}

#######################################

def main [ fresh_install: int = 0 ] any -> any {

	mut path_to_root_temp = "temp"

	if $fresh_install == 1 {
		$path_to_root_temp = "/mnt"
	} else {
		$path_to_root_temp = "/"
	}

	let path_to_root = $path_to_root_temp
	
	#######################################
	
	let git_repo_name = read_from "/mnt/etc/nixos/link_git_repo_name.conf" $fresh_install | str trim
	
	let path_to_git_repo = ( [ $path_to_root, "etc/nixos/", $git_repo_name ] | path join | str trim ) 
	let path_to_thing = ( [ $path_to_root, "etc/nixos" ] | path join | str trim  )
	let path_to_home = ( [ $path_to_root, "home" ] | path join | str trim  )
	
	#######################################
	
	let platform = ( read_from ( [ $path_to_git_repo, "values/platform.conf" ] | path join ) $fresh_install | str trim | into int )
	
	#######################################
	
	let gpu = ( read_from ( [ $path_to_git_repo, "values/gpu.conf" ] | path join ) $fresh_install | str trim | into int )
	
	#######################################
	
	let hostname = ( read_from ( [ $path_to_git_repo, "values/hostname.conf" ] | path join ) $fresh_install | str trim )
	
	let username = ( read_from ( [ $path_to_git_repo, "values/username.conf" ] | path join ) $fresh_install | str trim )
	
	#######################################
	
	let ssh_ports = ( read_from ( [ $path_to_git_repo, "values/ssh_ports.conf" ] | path join ) $fresh_install | str trim )
	
	let tcp_ports = ( read_from ( [ $path_to_git_repo, "values/tcp_ports.conf" ] | path join ) $fresh_install | str trim )
	
	let udp_ports = ( read_from ( [ $path_to_git_repo, "values/udp_ports.conf" ] | path join ) $fresh_install | str trim )
	
	#######################################
	
	let git_username = ( read_from ( [ $path_to_git_repo, "values/git_username.conf" ] | path join ) $fresh_install | str trim )
	
	let git_email = ( read_from ( [ $path_to_git_repo, "values/git_email.conf" ] | path join ) $fresh_install | str trim )
	
	#######################################
	
	select_platform $platform $fresh_install $path_to_git_repo
	
	select_gpu $gpu $fresh_install $path_to_git_repo
	
	#######################################

	copy_any_file ( [ $path_to_git_repo, "home-manager/modules/git/git_names.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/modules/git/secret_git_names.nix" ] | path join ) $fresh_install
	
	replace_string ( [ $path_to_git_repo, "home-manager/modules/git/secret_git_names.nix" ] | path join ) "GIT_USERNAME_REPLACE" $git_username $fresh_install
	
	replace_string ( [ $path_to_git_repo, "home-manager/modules/git/secret_git_names.nix" ] | path join ) "GIT_EMAIL_REPLACE" $git_email $fresh_install

	#######################################

	copy_any_file ( [ $path_to_git_repo, "home-manager/modules/home-path/home-path_config.nix" ] | path join ) ( [ $path_to_git_repo, "home-manager/modules/home-path/secret_home-path_config.nix" ] | path join ) $fresh_install
	
	replace_string ( [ $path_to_git_repo, "home-manager/modules/home-path/secret_home-path_config.nix" ] | path join ) "USERNAME_REPLACE" $username $fresh_install

	#######################################

	copy_system_file "firewall" "firewall_config.nix" "no_edit_firewall_config.nix" $fresh_install $path_to_git_repo $path_to_config
	
	replace_system_string "firewall" "no_edit_firewall_config.nix" "TCP_PORTS_REPLACE" $tcp_ports $fresh_install $path_to_config
	replace_system_string "firewall" "no_edit_firewall_config.nix" "UDP_PORTS_REPLACE" $udp_ports $fresh_install $path_to_config
}