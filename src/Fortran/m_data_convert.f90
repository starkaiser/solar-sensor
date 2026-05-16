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

module m_data_convert

    implicit none
    
    private
    public :: time_check, extract_time, extract_power
    
contains

    pure function extract_power(line) result(pwr)
        character(len=*), intent(in) :: line
        real :: pwr
        integer :: c1, c2, c3, c4
        
        c1 = index(line, ',')
        c2 = c1 + index(line(c1+1:), ',')
        c3 = c2 + index(line(c2+1:), ',')
        c4 = c3 + index(line(c3+1:), ',')

        read(line(c1+1:c2-1), *) pwr
    end function extract_power
    
    pure function extract_time(line) result(tstr)
        character(len=*), intent(in) :: line
        character(len=8) :: tstr
        integer :: c1, c2, c3, c4
        
        c1 = index(line, ',')
        c2 = c1 + index(line(c1+1:), ',')
        c3 = c2 + index(line(c2+1:), ',')
        c4 = c3 + index(line(c3+1:), ',')

        tstr = adjustl(line(c3+1:c4-1))
    end function extract_time

    pure logical function time_check(time) result(ok)
        character(len=*), intent(in) :: time
        integer :: h, m, s
        integer :: ios
        integer :: total_seconds

        ! Parse HH:MM:SS safely
        read(time, '(I2,1X,I2,1X,I2)', iostat=ios) h, m, s

        if (ios /= 0) then
            ok = .false.
            return
        end if

        total_seconds = h*3600 + m*60 + s
        ok = (total_seconds >= 10*3600 .and. total_seconds <= 21*3600)
    end function time_check

end module m_data_convert
