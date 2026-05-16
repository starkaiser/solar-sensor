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

program solar_sensor_parallel

    use m_parameters
    use m_logger
    use m_io
    use m_parallel

    implicit none
    
    type(logger) :: t
    integer :: i
    integer :: is, ie, indices(2)

    call start_timer(t)
    call clear_folder(data_processed_path)
    
    if (num_images() > size(months)) error stop 'Error: Too many images'
    indices = tile_indices(size(months))
    is = indices(1)
    ie = indices(2)
    
    do i = is, ie
        call process_folder(data_raw_path // "/" // folders(i), data_processed_path // "/" // months(i))
    end do
    
    sync all
    
    print *, "Program finished"

    call stop_timer(t)
    call write_log(t, output_folder_path // "/logfile_parallel.txt", "Solar Sensor Parallel")

end program solar_sensor_parallel
