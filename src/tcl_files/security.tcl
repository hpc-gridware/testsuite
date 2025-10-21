#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2025 HPC-Gridware GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

###
# @brief get the path to the TLS certificate file
#
# @param hostname  hostname where the certificate is located
# @param component component name (qmaster, execd, qrsh)
# @param user      user owning the certificate (default: daemon certificate)
# @return path to the TLS certificate file
proc get_tls_cert_path {hostname component {user ""}} {
   get_current_cluster_config_array ts_config

   if {$user eq ""} {
      # daemon certificate
      set cert "$ts_config(product_root)/$ts_config(cell)/common/certs/${component}_${hostname}.pem"
   } else {
      # @todo only if we enable caching of user (qrsh) certificates
      set home_dir [get_home_dir_path $user]
      set cert "$home_dir/.ocs/certs/$component.pem"
   }

   return $cert
}

###
# @brief get the directory where the TLS private keys are stored
#
# @return path to the TLS private key directory
proc get_tls_key_dir {} {
   get_current_cluster_config_array ts_config

   return "/var/lib/ocs/$ts_config(commd_port)/private"
}

###
# @brief get the path to the TLS private key file
#
# @param hostname  hostname where the private key is located
# @param component component name (qmaster, execd, qrsh)
# @param user      user owning the private key (default: daemon private key)
# @return path to the TLS private key file
proc get_tls_key_path {hostname component {user ""}} {
   get_current_cluster_config_array ts_config

   if {$user eq ""} {
      # daemon certificate
      set key_dir [get_tls_key_dir]
      set key "$key_dir/${component}_${hostname}.pem"
   } else {
      # @todo only if we enable caching of user (qrsh) certificates
      set home_dir [get_home_dir_path $user]
      set key "$home_dir/.ocs/private/$component.pem"
   }

   return $key
}

###
# @brief get the default lifetime for TLS certificates in seconds
#
# @return default lifetime in seconds (365 days)
proc get_tls_default_lifetime {} {
   return [expr 365 * 24 * 60 * 60]
}

###
# @brief parse one line of the certificate info output
# @param line            line to parse
# @param cert_info_var   name of the array variable to store the info
# @param attrib          attribute name to store the value in the array
proc get_cert_info_parse_line {line cert_info_var attrib} {
   upvar $cert_info_var cert_info
   set pos [string first ":" $line]
   set value [string trim [string range $line [expr $pos + 1] end]]
   set cert_info($attrib) $value
}

###
# @brief get information about a TLS certificate
#
# This procedure uses the openssl command line tool to get information about a TLS certificate
# It parses the output and stores the information in a TCL array, like the following:
#     cert_info(issuer)               = CN = laptop-joga
#     cert_info(lifetime)             = 31536000
#     cert_info(not_after)            = Oct  2 11:34:46 2026 GMT
#     cert_info(not_after_epoch)      = 1790940886
#     cert_info(not_before)           = Oct  2 11:34:46 2025 GMT
#     cert_info(not_before_epoch)     = 1759404886
#     cert_info(public_key_algorithm) = rsaEncryption
#     cert_info(serial_number)        = 1 (0x1)
#     cert_info(signature_algorithm)  = sha256WithRSAEncryption
#     cert_info(subject)              = CN = laptop-joga
#     cert_info(version)              = 3 (0x2)
#
# @param hostname        hostname where the certificate is located
# @param cert_path      path to the certificate file
# @param cert_info_var  name of the array variable to store the info (default: cert_info)
# @param user           user owning the certificate (default: use the CHECK_USER)
# @return 1 if successful, 0 on error
proc get_cert_info {hostname cert_path {cert_info_var "cert_info"} {user ""}} {
   upvar $cert_info_var cert_info
   unset -nocomplain cert_info

   if {$user eq ""} {
      global CHECK_USER
      set user $CHECK_USER
   }

   set ret 1

   # find path to the openssl binary
   set openssl_path [get_binary_path $hostname "openssl"]
   if {$openssl_path eq "openssl"} {
      set ret 0
   }

   # wait for the certificate file to be visible (on NFS)
   if {$ret} {
      if {[wait_for_remote_file $hostname $user $cert_path] < 0} {
         set ret 0
      }
   }

   # get certificate info as text
   if {$ret} {
      set openssl_args "x509 -noout -text -in $cert_path"
      set output [start_remote_prog $hostname $user $openssl_path $openssl_args]
      if {$prg_exit_state != 0} {
         ts_log_severe "Failed to get certificate info from $cert_path on $hostname:\n$output"
         set ret 0
      } else {
         #ts_log_fine $output
      }
   }

   # parse certificate info into TCL array
   if {$ret} {
      foreach line [split $output "\n"] {
         set line [string trim $line]
         switch -glob $line {
            "Version: *" {
               get_cert_info_parse_line $line cert_info "version"
            }
            "Serial Number: *" {
               get_cert_info_parse_line $line cert_info "serial_number"
            }
            "Signature Algorithm: *" {
               get_cert_info_parse_line $line cert_info "signature_algorithm"
            }
            "Issuer: *" {
               get_cert_info_parse_line $line cert_info "issuer"
            }
            "Not Before: *" {
               get_cert_info_parse_line $line cert_info "not_before"
               # convert to epoch time
               set not_before_epoch [clock scan $cert_info(not_before)]
               set cert_info(not_before_epoch) $not_before_epoch
            }
            "Not After : *" {
               get_cert_info_parse_line $line cert_info "not_after"
               # convert to epoch time
               set not_after_epoch [clock scan $cert_info(not_after)]
               set cert_info(not_after_epoch) $not_after_epoch
               # calculate lifetime in seconds
               if {[info exists cert_info(not_before_epoch)]} {
                  set lifetime [expr {$not_after_epoch - $cert_info(not_before_epoch)}]
                  set cert_info(lifetime) $lifetime
               }
            }
            "Subject: *" {
               get_cert_info_parse_line $line cert_info "subject"
            }
            "Public Key Algorithm: *" {
               get_cert_info_parse_line $line cert_info "public_key_algorithm"
            }
            "Signature Algorithm: *" {
               get_cert_info_parse_line $line cert_info "signature_algorithm"
            }
            default {
               # ignore
            }
         }
      }
      #parray cert_info
   }

   if {$ret} {
      ts_log_fine "Successfully got certificate info from $cert_path on $hostname"
   }

   return $ret
}

