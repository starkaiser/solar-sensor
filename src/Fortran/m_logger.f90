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

module m_logger

    implicit none
    
    private
    public :: logger, start_timer, stop_timer, write_log
    
    type :: logger
        integer :: tstart  = 0
        integer :: tend    = 0
        integer :: trate   = 0
        real    :: elapsed = 0.0
    end type logger
    
contains

    subroutine start_timer(t)
        type(logger), intent(in out) :: t
        call system_clock(t%tstart, t%trate)
    end subroutine start_timer
    
    subroutine stop_timer(t)
        type(logger), intent(inout) :: t
        call system_clock(t%tend)
        t%elapsed = real(t%tend - t%tstart) / real(t%trate)
    end subroutine stop_timer
    
    subroutine write_log(t, filename, label)
        type(logger), intent(in) :: t
        character(len=*), intent(in) :: filename
        character(len=*), intent(in), optional :: label
        integer :: unit
        character(len=200) :: msg
        integer :: v(8)

        call date_and_time(values=v)

        if (present(label)) then
            write(msg,'(I4.4,"-",I2.2,"-",I2.2,1X,I2.2,":",I2.2,":",I2.2,1X,A,": ",F10.6," seconds")') &
                        v(1), v(2), v(3), v(5), v(6), v(7), trim(label), t%elapsed
        else
        write(msg,'(I4.4,"-",I2.2,"-",I2.2,1X,I2.2,":",I2.2,":",I2.2,1X,A,": ",F10.6," seconds")') &
                        v(1), v(2), v(3), v(5), v(6), v(7), 'Execution time: ', t%elapsed
        end if

        open(newunit=unit, file=filename, status='unknown', &
             action='write', position='append')

        write(unit, '(A)') trim(msg)

        close(unit)

    end subroutine write_log
    
end module m_logger
