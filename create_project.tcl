# settings
set project_name "dual-rgb-pwm"
set project_dir  "./vivado"
set part_name    "xc7z020clg400-1"
set board_part   "tul.com.tw:pynq-z2:part0:1.0"

set script_dir [file dirname [file normalize [info script]]]
set proj_path  [file normalize [file join $script_dir $project_dir]]

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

add_glob [file join $script_dir rtl *.vhd]
add_glob [file join $script_dir xdc *.xdc] constrs_1
add_glob [file join $script_dir sim *.vhd] sim_1

# BD
source [file join $script_dir bd rgb_pwm_system.tcl]
set bd_file [lindex [get_files -quiet *.bd] 0]

# wrapper: generate + import into project
make_wrapper -files $bd_file -top -import

# set top
set wrapper [lindex [get_files -quiet "*_wrapper.vhd"] 0]
set_property top [file rootname [file tail $wrapper]] [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1