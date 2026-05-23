! BSD 3-Clause License
!
! Copyright (c) 2026, Sorin Cătălin Păștiță, sorincatalinpastita@gmail.com
!
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
!
! 1. Redistributions of source code must retain the above copyright notice, this
!    list of conditions and the following disclaimer.
!
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
!
! 3. Neither the name of the copyright holder nor the names of its
!    contributors may be used to endorse or promote products derived from
!    this software without specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
! DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
! FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
! SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
! CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
! OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module m_parameters

    implicit none
    
    private
    public :: data_raw_path, data_processed_path, output_folder_path, folders, months
    
    character(len=*), parameter :: data_raw_path = "../data/raw"
    character(len=*), parameter :: data_processed_path = "../data/processed"
    character(len=*), parameter :: output_folder_path = "../output"
    character(len=*), parameter :: folders(12) = ['01_jan_2018', '02_feb_2018', '03_mar_2018', &
                                                  '04_apr_2017', '05_may_2017', '06_jun_2017', &
                                                  '07_jul_2017', '08_aug_2017', '09_sep_2017', &
                                                  '10_oct_2017', '11_nov_2017', '12_dec_2017']
    character(len=*), parameter :: months(12) = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', &
                                                 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

contains
    
end module m_parameters
