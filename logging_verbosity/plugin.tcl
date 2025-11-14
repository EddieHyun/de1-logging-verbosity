#######################################################################################################################
# Logging Verbosity Plugin for DE1+
# 
# Copyright (C) 2025 Eddie Hyun
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#######################################################################################################################

set plugin_name "logging_verbosity"

namespace eval ::plugins::${plugin_name} {
    # These are shown in the plugin selection page
    variable author "Eddie Hyun"
    variable contact "https://github.com/EddieHyun/de1-logging-verbosity"
    variable version 1.0
    variable description "Change logging verbosity application-wide."
    variable name "Logging Verbosity"

    proc create_ui {} {
        if {[array size ::plugins::logging_verbosity::settings] == 0} {
            # default settings would be: INFO, DEBUG, DEBUG
            array set ::plugins::logging_verbosity::settings {
                file_verbosity $::logging::severity_limit_logfile
                console_verbosity $::logging::severity_limit_console
                android_verbosity $::logging::severity_limit_android
            }
        }
        dui page add logging_settings -namespace [namespace current]::logging_settings -bg_img settings_message.png -type fpdialog
        return "logging_settings"
    }

    proc main {} {
        plugins gui logging_verbosity [create_ui]
        set ::logging::severity_limit_logfile $::plugins::logging_verbosity::settings(file_verbosity)
        set ::logging::severity_limit_console $::plugins::logging_verbosity::settings(console_verbosity)
        set ::logging::severity_limit_android $::plugins::logging_verbosity::settings(android_verbosity)
        msg -ALERT [format "Logging verbosity plugin loaded. Current logging verbosity: f: %s(%d), c: %s(%d), a: %s(%d)" \
            $::logging::severity_to_string($::logging::severity_limit_logfile) $::logging::severity_limit_logfile \
            $::logging::severity_to_string($::logging::severity_limit_console) $::logging::severity_limit_console \
            $::logging::severity_to_string($::logging::severity_limit_android) $::logging::severity_limit_android]
    }
}

namespace eval ::plugins::${plugin_name}::logging_settings {
    proc setup {} {
        set page_name [namespace tail [namespace current]]

        # Headline
        add_de1_text $page_name 1280 300 -text "Logging Verbosity Settings" -font Helv_20_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"

        set y_start 500
        set labels {Warn Notice Info Debug}
        set level_values {4 5 6 7}
        # file
        add_de1_text $page_name 1280 $y_start -text "Logfile" -font Helv_10_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"
        dui add dselector $page_name 1280 [incr y_start 100] -bwidth 1000 -anchor center \
            -variable ::logging::severity_limit_logfile -values $level_values -labels $labels \
            -command check_logging_verbosity

        # console
        add_de1_text $page_name 1280 [incr y_start 130] -text "Console" -font Helv_10_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"
        dui add dselector $page_name 1280 [incr y_start 100] -bwidth 1000 -anchor center \
            -variable ::logging::severity_limit_console -values $level_values -labels $labels \
            -command check_logging_verbosity

        # android
        add_de1_text $page_name 1280 [incr y_start 130] -text "Android (logcat)" -font Helv_10_bold -width 1200 -fill "#444444" -anchor "center" -justify "center"
        dui add dselector $page_name 1280 [incr y_start 100] -bwidth 1000 -anchor center \
            -variable ::logging::severity_limit_android -values $level_values -labels $labels \
            -command check_logging_verbosity

        dui add dbutton $page_name 980 1210 1580 1410 -tags settings_done -label "Done" -label_pos {0.5 0.5} -label_font Helv_10_bold -label_fill "#fAfBff"
    }

    proc check_logging_verbosity {} {
        msg -ALERT [format "Logging verbosity set to f: %s(%d), c: %s(%d), a: %s(%d)" \
            $::logging::severity_to_string($::logging::severity_limit_logfile) $::logging::severity_limit_logfile \
            $::logging::severity_to_string($::logging::severity_limit_console) $::logging::severity_limit_console \
            $::logging::severity_to_string($::logging::severity_limit_android) $::logging::severity_limit_android]
    }

    proc settings_done {} {
        set ::plugins::logging_verbosity::settings(file_verbosity) $::logging::severity_limit_logfile
        set ::plugins::logging_verbosity::settings(console_verbosity) $::logging::severity_limit_console
        set ::plugins::logging_verbosity::settings(android_verbosity) $::logging::severity_limit_android
        save_plugin_settings logging_verbosity
        dui page close_dialog
    }
}
