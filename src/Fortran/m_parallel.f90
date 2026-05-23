! MIT License

! Copyright (c) 2018-2020 Milan Curcic

! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:

! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.

! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.

module m_parallel
    implicit none
    
    private
    public :: tile_indices

contains

    pure function tile_indices(dims)
        ! Given input global array size, return start and end index
        ! of a parallel 1-d tile that correspond to this image.
        integer, intent(in) :: dims
        integer :: tile_indices(2)
        integer :: offset, tile_size

        tile_size = dims / num_images()

        ! start and end indices assuming equal tile sizes
        tile_indices(1) = (this_image() - 1) * tile_size + 1
        tile_indices(2) = tile_indices(1) + tile_size - 1

        ! if we have any remainder, distribute it to the tiles at the end 
        offset = num_images() - mod(dims, num_images())
        if (this_image() > offset) then
            tile_indices(1) = tile_indices(1) + this_image() - offset - 1
            tile_indices(2) = tile_indices(2) + this_image() - offset
        end if
    end function tile_indices

end module m_parallel
