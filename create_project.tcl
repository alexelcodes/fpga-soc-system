# settings
set project_name "dual-rgb-pwm"
set project_dir  "./vivado"
set part_name    "xc7z020clg400-1"
set board_part   "tul.com.tw:pynq-z2:part0:1.0"
set bd_name      "rgb_pwm_system"
set tested_vivado_version "2025.2"

set script_dir [file dirname [file normalize [info script]]]
set proj_path  [file normalize [file join $script_dir $project_dir]]

# soft Vivado version warning
set current_vivado_version [version -short]
if {[string first $tested_vivado_version $current_vivado_version] == -1} {
    puts "WARNING: This project was tested with Vivado $tested_vivado_version, current version is $current_vivado_version"
    puts "WARNING: The project may require IP upgrade or BD TCL regeneration in this version."
}

# local board files
set_param board.repoPaths [file normalize [file join $script_dir "board_files"]]

create_project $project_name $proj_path -part $part_name -force
set_property board_part $board_part [current_project]
set_property target_language VHDL [current_project]

# add files helper
proc add_glob {pattern {fileset ""}} {
    set files [glob -nocomplain $pattern]
    if {[llength $files] == 0} { return }
    if {$fileset eq ""} {
        add_files -norecurse $files
    } else {
        add_files -fileset $fileset -norecurse $files
    }
}

# sources first, so BD can resolve pl_top
add_glob [file join $script_dir rtl *.vhd]
add_glob [file join $script_dir xdc *.xdc] constrs_1
add_glob [file join $script_dir sim *.vhd] sim_1

# BD
source [file join $script_dir bd "${bd_name}.tcl"]

# get BD file explicitly
set bd_file [get_files -quiet [file join $proj_path "${project_name}.srcs" "sources_1" "bd" $bd_name "${bd_name}.bd"]]
if {$bd_file eq ""} {
    error "Block design file not found for $bd_name"
}

# upgrade IPs if needed
set ips [get_ips -quiet]
if {[llength $ips] > 0} {
    upgrade_ip $ips
}

# generate BD output products
generate_target all $bd_file

# wrapper: generate only (do NOT import, avoids duplicate wrapper)
make_wrapper -files $bd_file -top

# add generated wrapper explicitly
set wrapper_file [file join $proj_path "${project_name}.gen" "sources_1" "bd" $bd_name "hdl" "${bd_name}_wrapper.vhd"]
if {![file exists $wrapper_file]} {
    error "Generated wrapper file not found: $wrapper_file"
}
add_files -norecurse $wrapper_file

# set top explicitly
set_property top "${bd_name}_wrapper" [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1