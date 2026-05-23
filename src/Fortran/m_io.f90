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


module m_io

    use m_parameters
    use m_data_convert
    
    implicit none
    
    private
    public :: read_csv_file, write_csv_file, process_folder, clear_folder

contains

    integer function num_records(filename)
        character(len=*), intent(in) :: filename
        integer :: fileunit
        open(newunit=fileunit, file=filename)
        num_records = 0
        
        do
            read(unit=fileunit, fmt=*, end=1)
            num_records = num_records + 1
        end do
        1 continue
        close(unit=fileunit)
    end function num_records
    
    ! read the power and time values from a raw-data csv file
    subroutine read_csv_file(filename, power, time)
        character(len=*), intent(in) :: filename
        real, allocatable, intent(out) :: power(:)
        character(len=8), allocatable, intent(out) :: time(:)

        integer :: fileunit, ios, n, max_records
        character(len=256) :: line
        character(len=8)   :: tstr
        real :: pwr
        real, allocatable :: temp_power(:)
        character(len=8), allocatable :: temp_time(:)

        ! Maximum possible rows
        max_records = num_records(filename)
        allocate(temp_power(max_records))
        allocate(temp_time(max_records))

        open(newunit=fileunit, file=filename, status='old', action='read')

        n = 0

        do
            read(fileunit, '(A)', iostat=ios) line
            if (ios /= 0) exit

            pwr = extract_power(line)
            tstr = extract_time(line)

            ! keep only daytime values
            if (time_check(tstr, 6, 21)) then
                n = n + 1
                temp_power(n) = pwr
                temp_time(n)  = tstr
            end if
        end do

        close(fileunit)

        ! Trim to actual size
        allocate(power(n))
        allocate(time(n))
        power = temp_power(1:n)
        time  = temp_time(1:n)
        deallocate(temp_power, temp_time)
    end subroutine read_csv_file
    
    ! write power and time values after they have been processed into a clean-data csv file
    subroutine write_csv_file(filename, power, time)
        character(len=*), intent(in) :: filename
        real, intent(in) :: power(:)
        character(len=*), intent(in) :: time(:)

        integer :: fileunit
        integer :: i, n

        n = size(power)

        ! Safety check
        if (size(time) /= n) then
            print *, "Error: power and time arrays have different sizes"
            stop
        end if

        open(newunit=fileunit, file=filename, status='replace', action='write')

        ! Optional header
        write(fileunit, '(A)') 'time,power'

        do i = 1, n
            write(fileunit, '(A,",",F10.3)') trim(time(i)), power(i)
        end do
        close(fileunit)
    end subroutine write_csv_file
    
    subroutine process_one_csv(input_folder, output_folder, filename)
        character(len=*), intent(in) :: input_folder
        character(len=*), intent(in) :: filename
        character(len=*), intent(in) :: output_folder
        character(len=256) :: output_file
        real, allocatable :: power(:)
        character(len=8), allocatable :: time(:)

        output_file = output_folder // "/filtered_" // trim(filename)

        call read_csv_file(input_folder // "/" // filename, power, time)
        call write_csv_file(output_file, power, time)
    end subroutine process_one_csv
    
    
    subroutine process_folder(input_folder, output_folder)
        character(len=*), intent(in) :: input_folder
        character(len=*), intent(in) :: output_folder
        character(len=512) :: output_file
        integer :: unit, ios
        character(len=1024) :: command
        character(len=512) :: filename
        output_file = output_folder // "/filelist.txt" 

        call execute_command_line('mkdir -p ' // output_folder)
        command = 'ls -1 "' // trim(input_folder) // '" > "' // trim(output_file) // '"'
        call execute_command_line(trim(command))
        
        open(newunit=unit, file=trim(output_file), status='old', action='read')
        
        do
            read(unit, '(A)', iostat=ios) filename
            if (ios /= 0) exit

            filename = trim(filename)
            call process_one_csv(input_folder, output_folder, filename)

        end do

        close(unit)
    
    end subroutine process_folder
    
    subroutine clear_folder(folder_name)
        character(len=*), intent(in) :: folder_name
        character(len=1024) :: command
        command = 'rm -rf "' // trim(folder_name) // '"/*'
        call execute_command_line(trim(command))
    end subroutine clear_folder

end module m_io
