#!/bin/bash
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#  
#  Copyright 2026 HPC-Gridware GmbH
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

stdbuf -o0 -e0 yes "$(cat <<'EOF'

VDD = 0.4998 V ; VPP = 0.4998 V ; C1 = 0 F ; R = 0 Ohm ; C2 = 2.882e-13 F ; Slew1 = 9.0375e-10 S ; Slew2 = 9.0375e-10 S ;

      state = output_rise ; vector = A1&!A2&!A3&!A4 ; active_input = A1 ; active_output = Z ;

      pin               peak             area            width

      VDD               8.80e-05  A      1.40e-13 C      5.55e-09 S

      VPP               -5.79e-07 A      1.36e-16 C      3.80e-09 S

      VSS               8.80e-05  A      1.41e-13 C      5.55e-09 S

      VBB               4.38e-07  A      9.02e-17 C      4.08e-09 S

      state = output_fall ; vector = A1&!A2&!A3&!A4 ; active_input = A1 ; active_output = Z ;

      pin               peak             area            width

      VDD               4.54e-06  A      2.30e-15 C      4.37e-09 S

      VPP               4.57e-07 A      1.40e-16 C      3.93e-09 S

      VSS               5.20e-06  A      1.82e-15 C      4.37e-09 S

      VBB               -3.75e-07 A      9.05e-17 C      4.19e-09 S

EOF

)" | head -n 1000000

echo "--- End of Output ---"
exit 0
